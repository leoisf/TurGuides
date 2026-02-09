import 'package:flutter/foundation.dart';

class Atrativo {
  final int id;
  final String placeId;
  final String nome;
  final double latitude;
  final double longitude;
  final String? endereco;
  final String? enderecoCompleto;
  final double? rating;
  final int? userRatingsTotal;
  final List<String>? fotos;
  final List<String>? tipos;

  Atrativo({
    required this.id,
    required this.placeId,
    required this.nome,
    required this.latitude,
    required this.longitude,
    this.endereco,
    this.enderecoCompleto,
    this.rating,
    this.userRatingsTotal,
    this.fotos,
    this.tipos,
  });

  factory Atrativo.fromJson(Map<String, dynamic> json) {
    // Debug: ver fotos recebidas
    if (json['fotos'] != null) {
      debugPrint('🖼️ Fotos recebidas para ${json['nome']}:');
      debugPrint('   Total: ${json['fotos'].length}');
      if (json['fotos'].length > 0) {
        debugPrint('   Primeira: ${json['fotos'][0]}');
      }
    }
    
    return Atrativo(
      id: json['id'],
      placeId: json['place_id'],
      nome: json['nome'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      endereco: json['endereco'],
      enderecoCompleto: json['endereco_completo'],
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      userRatingsTotal: json['user_ratings_total'],
      fotos: json['fotos'] != null 
          ? List<String>.from(json['fotos'].map((f) => f is String ? f : f['url'] ?? f['photo_reference'] ?? ''))
          : null,
      tipos: json['tipos'] != null
          ? List<String>.from(json['tipos'])
          : null,
    );
  }
}
