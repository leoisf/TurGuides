class Agendamento {
  final int? id;
  final int turistaId;
  final int guiaId;
  final int? roteiroId;
  final String dataAgendamento;
  final String horaInicio;
  final String horaFim;
  final int? duracaoEstimada;
  final double? valor;
  final String status; // pendente, confirmado, cancelado, concluido
  final String? observacoes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Campos adicionais para exibição
  final String? turistaNome;
  final String? guiaNome;
  final String? guiaEmail;
  final String? guiaTelefone;
  final String? roteiroNome;

  Agendamento({
    this.id,
    required this.turistaId,
    required this.guiaId,
    this.roteiroId,
    required this.dataAgendamento,
    required this.horaInicio,
    required this.horaFim,
    this.duracaoEstimada,
    this.valor,
    this.status = 'pendente',
    this.observacoes,
    this.createdAt,
    this.updatedAt,
    this.turistaNome,
    this.guiaNome,
    this.guiaEmail,
    this.guiaTelefone,
    this.roteiroNome,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      turistaId: json['turista_id'],
      guiaId: json['guia_id'],
      roteiroId: json['roteiro_id'],
      dataAgendamento: json['data_agendamento'],
      horaInicio: json['hora_inicio'],
      horaFim: json['hora_fim'],
      duracaoEstimada: json['duracao_estimada'],
      valor: json['valor'] != null ? double.tryParse(json['valor'].toString()) : null,
      status: json['status'] ?? 'pendente',
      observacoes: json['observacoes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      turistaNome: json['turista_nome'],
      guiaNome: json['guia_nome'],
      guiaEmail: json['guia_email'],
      guiaTelefone: json['guia_telefone'],
      roteiroNome: json['roteiro_nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'turista_id': turistaId,
      'guia_id': guiaId,
      'roteiro_id': roteiroId,
      'data_agendamento': dataAgendamento,
      'hora_inicio': horaInicio,
      'hora_fim': horaFim,
      'duracao_estimada': duracaoEstimada,
      'valor': valor,
      'status': status,
      'observacoes': observacoes,
    };
  }
}
