class Disponibilidade {
  final int? id;
  final int guiaId;
  final int diaSemana; // 0=Domingo, 1=Segunda, ..., 6=Sábado
  final String horaInicio;
  final String horaFim;
  final bool? ativo;
  final DateTime? createdAt;

  Disponibilidade({
    this.id,
    required this.guiaId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFim,
    this.ativo,
    this.createdAt,
  });

  factory Disponibilidade.fromJson(Map<String, dynamic> json) {
    return Disponibilidade(
      id: json['id'],
      guiaId: json['guia_id'],
      diaSemana: json['dia_semana'],
      horaInicio: json['hora_inicio'],
      horaFim: json['hora_fim'],
      ativo: json['ativo'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'guia_id': guiaId,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'ativo': ativo,
    };
  }
}
