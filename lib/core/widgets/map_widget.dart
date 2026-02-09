import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/atrativo.dart';
import '../services/location_service.dart';

class MapWidget extends StatefulWidget {
  final List<Atrativo> atrativos;
  final Function(LatLng)? onMapTap;
  final Function(Atrativo)? onMarkerTap;
  final Atrativo? selectedAtrativo;
  final double height;
  final LatLng? initialPosition;
  final double initialZoom;
  final bool showPolyline;
  final Color polylineColor;

  const MapWidget({
    super.key,
    this.atrativos = const [],
    this.onMapTap,
    this.onMarkerTap,
    this.selectedAtrativo,
    this.height = 300,
    this.initialPosition,
    this.initialZoom = 15,  // Zoom maior para focar na Praça Tiradentes
    this.showPolyline = false,
    this.polylineColor = const Color(0xFF1976D2),
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Posição padrão: Praça Tiradentes, Ouro Preto, MG
  static const LatLng _defaultPosition = LatLng(-20.38560413, -43.50367069);

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _createPolylines();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final hasPermission = await LocationService.checkAndRequestPermission();
    if (!hasPermission) {
      debugPrint('Permissão de localização não concedida');
    }
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.atrativos != widget.atrativos ||
        oldWidget.showPolyline != widget.showPolyline ||
        oldWidget.polylineColor != widget.polylineColor ||
        oldWidget.selectedAtrativo != widget.selectedAtrativo) {
      _createMarkers();
      _createPolylines();
      
      // Focar no atrativo selecionado
      if (widget.selectedAtrativo != null && _controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              widget.selectedAtrativo!.latitude,
              widget.selectedAtrativo!.longitude,
            ),
            16.0,
          ),
        );
      }
    }
  }

  void _createMarkers() {
    final markers = <Marker>{};
    
    // Criar marcadores invisíveis para todos os pontos (para permitir clique)
    for (var atrativo in widget.atrativos) {
      final isSelected = widget.selectedAtrativo?.id == atrativo.id;
      
      if (isSelected) {
        // Marcador verde visível para o selecionado
        markers.add(
          Marker(
            markerId: MarkerId(atrativo.id.toString()),
            position: LatLng(atrativo.latitude, atrativo.longitude),
            infoWindow: InfoWindow(
              title: atrativo.nome,
              snippet: atrativo.endereco,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            onTap: () {
              if (widget.onMarkerTap != null) {
                widget.onMarkerTap!(atrativo);
              }
            },
          ),
        );
      } else {
        // Marcador invisível (alpha 0) para permitir clique
        markers.add(
          Marker(
            markerId: MarkerId(atrativo.id.toString()),
            position: LatLng(atrativo.latitude, atrativo.longitude),
            alpha: 0.0,  // Invisível
            onTap: () {
              if (widget.onMarkerTap != null) {
                widget.onMarkerTap!(atrativo);
              }
            },
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  void _createPolylines() {
    if (!widget.showPolyline || widget.atrativos.length < 2) {
      setState(() {
        _polylines = {};
      });
      return;
    }

    // Criar polyline conectando todos os pontos do roteiro
    final List<LatLng> pontos = widget.atrativos
        .map((atrativo) => LatLng(atrativo.latitude, atrativo.longitude))
        .toList();

    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('roteiro'),
          points: pontos,
          color: widget.polylineColor,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    
    // Se há um atrativo selecionado, focar nele
    if (widget.selectedAtrativo != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            widget.selectedAtrativo!.latitude,
            widget.selectedAtrativo!.longitude,
          ),
          16.0,
        ),
      );
    }
    // Se não há seleção, manter foco na Praça Tiradentes (posição padrão)
  }

  void _fitMarkersInView() {
    if (widget.atrativos.isEmpty || _controller == null) return;

    if (widget.atrativos.length == 1) {
      // Se há apenas um ponto, centralizar nele
      final atrativo = widget.atrativos.first;
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(atrativo.latitude, atrativo.longitude),
          15.0,
        ),
      );
      return;
    }

    double minLat = widget.atrativos.first.latitude;
    double maxLat = widget.atrativos.first.latitude;
    double minLng = widget.atrativos.first.longitude;
    double maxLng = widget.atrativos.first.longitude;

    for (var atrativo in widget.atrativos) {
      if (atrativo.latitude < minLat) minLat = atrativo.latitude;
      if (atrativo.latitude > maxLat) maxLat = atrativo.latitude;
      if (atrativo.longitude < minLng) minLng = atrativo.longitude;
      if (atrativo.longitude > maxLng) maxLng = atrativo.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition ?? _defaultPosition,
          zoom: widget.initialZoom,
        ),
        markers: _markers,
        polylines: _polylines,
        onTap: widget.onMapTap,
        myLocationEnabled: false, // Desabilitado até permissões serem concedidas
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        compassEnabled: true,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        tiltGesturesEnabled: true,
        zoomGesturesEnabled: true,
        mapType: MapType.normal,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
