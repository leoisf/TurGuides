class Usuario {
  final int id;
  final String nome;
  final String email;
  final String tipo; // sempre 'turista' neste app
  final String? cpf;
  final String? telefone;
  final String? dataNascimento;
  final String? lingua;
  final String? perfil;
  final String? matricula; // usado apenas para guias (em outros apps)
  final String? horaTrabalho; // usado apenas para guias (em outros apps)
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    this.cpf,
    this.telefone,
    this.dataNascimento,
    this.lingua,
    this.perfil,
    this.matricula,
    this.horaTrabalho,
    this.createdAt,
    this.updatedAt,
  });

  // Para este app de turista, sempre será turista
  bool get isTurista => true;
  
  // Getters para compatibilidade com outros apps
  bool get isAdmin => false;
  bool get isGuia => false;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      tipo: json['tipo'] ?? 'turista', // default para turista
      cpf: json['cpf'],
      telefone: json['telefone'],
      dataNascimento: json['data_nascimento'],
      lingua: json['lingua'],
      perfil: json['perfil'],
      matricula: json['matricula'],
      horaTrabalho: json['hora_trabalho'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'cpf': cpf,
      'telefone': telefone,
      'data_nascimento': dataNascimento,
      'lingua': lingua,
      'perfil': perfil,
      'matricula': matricula,
      'hora_trabalho': horaTrabalho,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
