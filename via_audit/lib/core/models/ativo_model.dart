class AtivoModel {
  final int id;
  final int escolaId;
  final String descricao;
  final int quantidade;
  final String? nf;
  final String origem; // 'historico', 'extra'
  final String statusChecklist; // 'pendente', 'em_andamento', 'conferido', 'divergente'
  final int unidadesRegistradas;

  AtivoModel({
    required this.id,
    required this.escolaId,
    required this.descricao,
    required this.quantidade,
    this.nf,
    required this.origem,
    required this.statusChecklist,
    required this.unidadesRegistradas,
  });

  factory AtivoModel.fromJson(Map<String, dynamic> json) {
    return AtivoModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      escolaId: json['escolaId'] ?? json['escola_id'] ?? 0,
      descricao: json['descricao'] ?? '',
      quantidade: json['quantidade'] ?? 1,
      nf: json['nf'],
      origem: json['origem'] ?? 'historico',
      statusChecklist: json['statusChecklist'] ?? json['status_checklist'] ?? 'pendente',
      unidadesRegistradas: json['unidadesRegistradas'] ?? json['unidades_registradas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'escolaId': escolaId,
      'descricao': descricao,
      'quantidade': quantidade,
      'nf': nf,
      'origem': origem,
      'statusChecklist': statusChecklist,
      'unidadesRegistradas': unidadesRegistradas,
    };
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'escola_id': escolaId,
      'descricao': descricao,
      'quantidade': quantidade,
      'nf': nf,
      'origem': origem,
      'status_checklist': statusChecklist,
      'unidades_registradas': unidadesRegistradas,
    };
  }
}
