class Usuario {
  final int id;
  final String nome;
  final String email;
  final String tipo;
  final String? cpf;
  final String? telefone;
  final DateTime? createdAt;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tipo,
    this.cpf,
    this.telefone,
    this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      tipo: json['tipo'],
      cpf: json['cpf'],
      telefone: json['telefone'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
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
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
