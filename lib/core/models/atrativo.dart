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
  });

  factory Atrativo.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
