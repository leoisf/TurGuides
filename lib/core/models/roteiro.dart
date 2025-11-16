class Roteiro {
  final int id;
  final String nome;
  final double? distanciaTotal;
  final int? tempoEstimado;
  final DateTime? createdAt;

  Roteiro({
    required this.id,
    required this.nome,
    this.distanciaTotal,
    this.tempoEstimado,
    this.createdAt,
  });

  factory Roteiro.fromJson(Map<String, dynamic> json) {
    return Roteiro(
      id: json['id'],
      nome: json['nome'],
      distanciaTotal: json['distancia_total'] != null 
          ? double.tryParse(json['distancia_total'].toString())
          : null,
      tempoEstimado: json['tempo_estimado'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }
}
