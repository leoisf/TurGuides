class Agendamento {
  final int id;
  final int turistaId;
  final int guiaId;
  final int roteiroId;
  final DateTime dataAgendamento;
  final String horaInicio;
  final String horaFim;
  final int? duracaoEstimada;
  final double? valor;
  final String status;
  final String? observacoes;

  Agendamento({
    required this.id,
    required this.turistaId,
    required this.guiaId,
    required this.roteiroId,
    required this.dataAgendamento,
    required this.horaInicio,
    required this.horaFim,
    this.duracaoEstimada,
    this.valor,
    required this.status,
    this.observacoes,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      turistaId: json['turista_id'],
      guiaId: json['guia_id'],
      roteiroId: json['roteiro_id'],
      dataAgendamento: DateTime.parse(json['data_agendamento']),
      horaInicio: json['hora_inicio'],
      horaFim: json['hora_fim'],
      duracaoEstimada: json['duracao_estimada'],
      valor: json['valor'] != null ? (json['valor'] as num).toDouble() : null,
      status: json['status'],
      observacoes: json['observacoes'],
    );
  }
}
