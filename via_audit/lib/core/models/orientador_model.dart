class OrientadorModel {
  final int id;
  final String nome;
  final String? email;
  final int totalEscolas;
  final int escolasVisitadas;

  OrientadorModel({
    required this.id,
    required this.nome,
    this.email,
    required this.totalEscolas,
    required this.escolasVisitadas,
  });

  factory OrientadorModel.fromJson(Map<String, dynamic> json) {
    return OrientadorModel(
      id: json['orientadorId'] ?? json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'],
      totalEscolas: json['totalEscolas'] ?? 0,
      escolasVisitadas: json['escolasVisitadas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'totalEscolas': totalEscolas,
      'escolasVisitadas': escolasVisitadas,
    };
  }
}
