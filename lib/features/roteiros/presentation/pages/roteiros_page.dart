import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/roteiro.dart';
import '../../../../core/models/atrativo.dart';
import '../../../../core/services/api_service.dart';
import '../../../atrativos/presentation/pages/atrativo_detalhes_page.dart';

enum ModoTransporte {
  aPe('walking', 'A pé', Icons.directions_walk),
  carro('driving', 'Carro', Icons.directions_car),
  bicicleta('bicycling', 'Bicicleta', Icons.directions_bike),
  moto('driving', 'Moto', Icons.two_wheeler),
  transporte('transit', 'Transporte Público', Icons.directions_bus);

  final String apiValue;
  final String label;
  final IconData icon;

  const ModoTransporte(this.apiValue, this.label, this.icon);
}

const LatLng _pracaTiradentes = LatLng(-20.38560413, -43.50367069);

class RoteirosPage extends StatefulWidget {
  const RoteirosPage({super.key});

  @override
  State<RoteirosPage> createState() => _RoteirosPageState();
}

class _RoteirosPageState extends State<RoteirosPage> {
  final ApiService _api = ApiService();
  List<Roteiro> _roteiros = [];
  bool _isLoading = true;
  
  // Roteiro selecionado (exibido no mapa)
  int? _roteiroSelecionadoId;
  List<Atrativo> _pontosSelecionados = [];
  ModoTransporte _modoSelecionado = ModoTransporte.aPe;
  
  // Dados da rota
  double? _distanciaTotal;
  int? _tempoTotal;
  Map<int, Map<String, dynamic>> _trechosInfo = {};
  bool _calculandoRota = false;
  
  // Mapa
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  
  // Controle de expansão
  int? _expandedRoteiroId;

  @override
  void initState() {
    super.initState();
    _loadRoteiros();
  }

  Future<void> _loadRoteiros() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get(AppConfig.roteiros);
      if (response['success']) {
        final List<dynamic> data = response['data'];
        setState(() {
          _roteiros = data.map((json) => Roteiro.fromJson(json)).toList();
          _isLoading = false;
        });
        
        // Selecionar primeiro roteiro automaticamente
        if (_roteiros.isNotEmpty) {
          _selecionarRoteiro(_roteiros[0].id);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar roteiros: $e')),
        );
      }
    }
  }

  Future<void> _selecionarRoteiro(int roteiroId) async {
    setState(() {
      _roteiroSelecionadoId = roteiroId;
      _calculandoRota = true;
    });

    try {
      final response = await _api.get('${AppConfig.roteiros}/$roteiroId/pontos');
      
      if (response['success']) {
        final List<dynamic> pontosData = response['data'];
        final pontos = pontosData.map((json) => Atrativo.fromJson(json)).toList();
        
        setState(() {
          _pontosSelecionados = pontos;
        });
        
        await _calcularRota();
      }
    } catch (e) {
      debugPrint('Erro ao carregar pontos do roteiro $roteiroId: $e');
      setState(() => _calculandoRota = false);
    }
  }

  Future<void> _calcularRota() async {
    if (_pontosSelecionados.length < 2) {
      setState(() => _calculandoRota = false);
      return;
    }

    try {
      double distanciaTotal = 0;
      int tempoTotal = 0;
      List<LatLng> todosOsPontos = [];
      Map<int, Map<String, dynamic>> trechosInfo = {};

      for (int i = 0; i < _pontosSelecionados.length - 1; i++) {
        final origem = _pontosSelecionados[i];
        final destino = _pontosSelecionados[i + 1];

        final resultado = await _calcularTrecho(origem, destino);
        
        if (resultado != null) {
          distanciaTotal += resultado['distancia'] as double;
          tempoTotal += resultado['tempo'] as int;
          todosOsPontos.addAll(resultado['pontos'] as List<LatLng>);
          
          trechosInfo[i] = {
            'distancia': resultado['distancia'],
            'tempo': resultado['tempo'],
          };
        }
      }

      setState(() {
        _distanciaTotal = distanciaTotal;
        _tempoTotal = tempoTotal;
        _trechosInfo = trechosInfo;
        _calculandoRota = false;
      });

      _criarPolylines(todosOsPontos);
      _criarMarkers();
      _ajustarCamera();
    } catch (e) {
      debugPrint('Erro ao calcular rota: $e');
      setState(() => _calculandoRota = false);
    }
  }

  Future<Map<String, dynamic>?> _calcularTrecho(Atrativo origem, Atrativo destino) async {
    const apiKey = AppConfig.googleMapsApiKey;
    
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origem.latitude},${origem.longitude}&'
      'destination=${destino.latitude},${destino.longitude}&'
      'mode=${_modoSelecionado.apiValue}&'
      'key=$apiKey'
    );

    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          final distancia = leg['distance']['value'] / 1000.0;
          final tempo = leg['duration']['value'] ~/ 60;
          final polylinePoints = _decodePolyline(route['overview_polyline']['points']);
          
          return {
            'distancia': distancia,
            'tempo': tempo,
            'pontos': polylinePoints,
          };
        }
      }
    } catch (e) {
      debugPrint('Erro ao calcular trecho: $e');
    }
    
    return {
      'distancia': _calcularDistanciaEuclidiana(origem, destino),
      'tempo': 15,
      'pontos': [
        LatLng(origem.latitude, origem.longitude),
        LatLng(destino.latitude, destino.longitude),
      ],
    };
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  double _calcularDistanciaEuclidiana(Atrativo a, Atrativo b) {
    const double earthRadius = 6371;
    final dLat = _toRadians(b.latitude - a.latitude);
    final dLon = _toRadians(b.longitude - a.longitude);
    
    final lat1 = _toRadians(a.latitude);
    final lat2 = _toRadians(b.latitude);
    
    final x = dLat * dLat + dLon * dLon * (lat1 * lat1) * (lat2 * lat2);
    final c = 2 * (x / (1 + (1 - x)));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  void _criarPolylines(List<LatLng> pontos) {
    if (pontos.isEmpty) return;

    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('rota'),
          points: pontos,
          color: const Color(0xFF1976D2),
          width: 5,
        ),
      };
    });
  }

  void _criarMarkers() {
    final markers = <Marker>{};
    
    for (int i = 0; i < _pontosSelecionados.length; i++) {
      final atrativo = _pontosSelecionados[i];
      markers.add(
        Marker(
          markerId: MarkerId(atrativo.id.toString()),
          position: LatLng(atrativo.latitude, atrativo.longitude),
          infoWindow: InfoWindow(
            title: '${i + 1}. ${atrativo.nome}',
            snippet: atrativo.endereco,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueGreen : 
            i == _pontosSelecionados.length - 1 ? BitmapDescriptor.hueRed :
            BitmapDescriptor.hueBlue,
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _ajustarCamera() {
    if (_mapController == null || _pontosSelecionados.isEmpty) return;

    double minLat = _pontosSelecionados.first.latitude;
    double maxLat = _pontosSelecionados.first.latitude;
    double minLng = _pontosSelecionados.first.longitude;
    double maxLng = _pontosSelecionados.first.longitude;

    for (var ponto in _pontosSelecionados) {
      if (ponto.latitude < minLat) minLat = ponto.latitude;
      if (ponto.latitude > maxLat) maxLat = ponto.latitude;
      if (ponto.longitude < minLng) minLng = ponto.longitude;
      if (ponto.longitude > maxLng) maxLng = ponto.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void _alterarModoTransporte(ModoTransporte novoModo) {
    setState(() {
      _modoSelecionado = novoModo;
      _calculandoRota = true;
    });
    _calcularRota();
  }

  String _formatTempo(int? minutos) {
    if (minutos == null) return 'N/A';
    final horas = minutos ~/ 60;
    final mins = minutos % 60;
    if (horas > 0) {
      return '${horas}h ${mins}min';
    }
    return '${mins}min';
  }

  Roteiro? get _roteiroSelecionado {
    if (_roteiroSelecionadoId == null) return null;
    try {
      return _roteiros.firstWhere((r) => r.id == _roteiroSelecionadoId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roteiros Turísticos'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          if (_roteiroSelecionado != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _roteiroSelecionadoId = null;
                  _pontosSelecionados = [];
                  _polylines = {};
                  _markers = {};
                  _expandedRoteiroId = null;
                });
              },
              tooltip: 'Limpar seleção',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _roteiros.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Nenhum roteiro encontrado'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRoteiros,
                        child: const Text('Recarregar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // MAPA FIXO NO TOPO
                    SizedBox(
                      height: 300,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _pracaTiradentes,
                              zoom: 14,
                            ),
                            markers: _markers,
                            polylines: _polylines,
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            myLocationButtonEnabled: false,
                            zoomControlsEnabled: true,
                            mapToolbarEnabled: false,
                          ),
                          
                          // Info do roteiro selecionado sobre o mapa
                          if (_roteiroSelecionado != null)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2).withAlpha(230),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.route, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _roteiroSelecionado!.nome,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${_distanciaTotal?.toStringAsFixed(1) ?? "..."} km • ${_formatTempo(_tempoTotal)} • ${_pontosSelecionados.length} pontos',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          // Loading overlay
                          if (_calculandoRota)
                            Container(
                              color: Colors.black.withAlpha(50),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // LISTA DE ROTEIROS (SCROLLÁVEL)
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadRoteiros,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _roteiros.length,
                          itemBuilder: (context, index) {
                            final roteiro = _roteiros[index];
                            final isSelecionado = _roteiroSelecionadoId == roteiro.id;
                            final isExpanded = _expandedRoteiroId == roteiro.id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: isSelecionado 
                                  ? const Color(0xFF1976D2).withAlpha(25)
                                  : null,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isSelecionado
                                          ? const Color(0xFF1976D2)
                                          : Colors.grey,
                                      child: const Icon(
                                        Icons.route,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      roteiro.nome,
                                      style: TextStyle(
                                        fontWeight: isSelecionado
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      isSelecionado && _distanciaTotal != null
                                          ? 'Distância: ${_distanciaTotal!.toStringAsFixed(1)} km\nTempo: ${_formatTempo(_tempoTotal)}'
                                          : 'Toque para ver no mapa',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelecionado)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF1976D2),
                                            size: 20,
                                          ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isExpanded
                                              ? Icons.expand_less
                                              : Icons.chevron_right,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      if (isSelecionado) {
                                        // Se já está selecionado, expandir/colapsar
                                        setState(() {
                                          _expandedRoteiroId = isExpanded ? null : roteiro.id;
                                        });
                                      } else {
                                        // Selecionar e carregar no mapa
                                        _selecionarRoteiro(roteiro.id);
                                        setState(() {
                                          _expandedRoteiroId = null;
                                        });
                                      }
                                    },
                                  ),

                                  // CONTEÚDO EXPANSÍVEL
                                  if (isExpanded && isSelecionado) ...[
                                    const Divider(height: 1),
                                    
                                    // Modos de transporte
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      color: Colors.grey.shade50,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Modo de transporte:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              ModoTransporte.aPe,
                                              ModoTransporte.carro,
                                              ModoTransporte.bicicleta,
                                            ].map((m) => _buildModoButton(m)).toList(),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              ModoTransporte.moto,
                                              ModoTransporte.transporte,
                                            ].map((m) => _buildModoButton(m)).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Cards de informação
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoCard(
                                              icon: Icons.straighten,
                                              label: 'Distância',
                                              value: _distanciaTotal != null
                                                  ? '${_distanciaTotal!.toStringAsFixed(2)} km'
                                                  : 'N/A',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInfoCard(
                                              icon: Icons.access_time,
                                              label: 'Tempo',
                                              value: _formatTempo(_tempoTotal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoCard(
                                              icon: Icons.place,
                                              label: 'Pontos',
                                              value: '${_pontosSelecionados.length} locais',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInfoCard(
                                              icon: _modoSelecionado.icon,
                                              label: 'Modo',
                                              value: _modoSelecionado.label,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Lista de pontos
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pontos do Roteiro',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ...List.generate(_pontosSelecionados.length, (i) {
                                            final atrativo = _pontosSelecionados[i];
                                            final trechoInfo = _trechosInfo[i];
                                            
                                            return Column(
                                              children: [
                                                ListTile(
                                                  dense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                  leading: CircleAvatar(
                                                    radius: 16,
                                                    backgroundColor: i == 0
                                                        ? const Color(0xFF4CAF50)
                                                        : i == _pontosSelecionados.length - 1
                                                            ? Colors.red
                                                            : const Color(0xFF2196F3),
                                                    child: Text(
                                                      '${i + 1}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    atrativo.nome,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  subtitle: atrativo.endereco != null
                                                      ? Text(
                                                          atrativo.endereco!,
                                                          style: const TextStyle(fontSize: 12),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        )
                                                      : null,
                                                  trailing: const Icon(Icons.chevron_right, size: 16),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => AtrativoDetalhesPage(
                                                          atrativo: atrativo,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                if (trechoInfo != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 48, bottom: 8),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.arrow_downward,
                                                          size: 14,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                        const SizedBox(width: 6),
                                                        Text(
                                                          '${trechoInfo['distancia'].toStringAsFixed(2)} km • ${_formatTempo(trechoInfo['tempo'])}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildModoButton(ModoTransporte modo) {
    final selecionado = _modoSelecionado == modo;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          onPressed: () => _alterarModoTransporte(modo),
          style: ElevatedButton.styleFrom(
            backgroundColor: selecionado
                ? const Color(0xFF1976D2)
                : Colors.white,
            foregroundColor: selecionado
                ? Colors.white
                : Colors.black87,
            elevation: selecionado ? 3 : 1,
            padding: const EdgeInsets.symmetric(vertical: 8),
            minimumSize: const Size(0, 36),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(modo.icon, size: 16),
              const SizedBox(height: 2),
              Text(
                modo.label,
                style: const TextStyle(fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50).withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
