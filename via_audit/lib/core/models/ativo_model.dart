class AtivoModel {
  final int id;
  final int escolaId;
  final String descricao;
  final int quantidade;
  final String? nf;
  final String origem; // 'historico', 'extra'
  final String statusChecklist; // 'pendente', 'em_andamento', 'conferido', 'divergente'
  final int unidadesRegistradas;
  final int qtdOk;
  final int qtdAvariado;
  final int qtdNaoEncontrado;
  final int qtdExtra;

  AtivoModel({
    required this.id,
    required this.escolaId,
    required this.descricao,
    required this.quantidade,
    this.nf,
    required this.origem,
    required this.statusChecklist,
    required this.unidadesRegistradas,
    this.qtdOk = 0,
    this.qtdAvariado = 0,
    this.qtdNaoEncontrado = 0,
    this.qtdExtra = 0,
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
      qtdOk: json['qtdOk'] ?? json['qtd_ok'] ?? 0,
      qtdAvariado: json['qtdAvariado'] ?? json['qtd_avariado'] ?? 0,
      qtdNaoEncontrado: json['qtdNaoEncontrado'] ?? json['qtd_nao_encontrado'] ?? 0,
      qtdExtra: json['qtdExtra'] ?? json['qtd_extra'] ?? 0,
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
      'qtdOk': qtdOk,
      'qtdAvariado': qtdAvariado,
      'qtdNaoEncontrado': qtdNaoEncontrado,
      'qtdExtra': qtdExtra,
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
