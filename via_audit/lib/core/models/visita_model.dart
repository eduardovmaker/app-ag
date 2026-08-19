class VisitaModel {
  final int id;
  final int orientadorId;
  final int escolaId;
  final String status; // 'em_andamento', 'concluida'
  final String iniciadaEm;
  final String? concluidaEm;
  final String? assinaturaUrl;
  final String? observacaoGeral;
  final bool sincronizado;

  VisitaModel({
    required this.id,
    required this.orientadorId,
    required this.escolaId,
    required this.status,
    required this.iniciadaEm,
    this.concluidaEm,
    this.assinaturaUrl,
    this.observacaoGeral,
    this.sincronizado = true,
  });

  factory VisitaModel.fromJson(Map<String, dynamic> json) {
    return VisitaModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      orientadorId: json['orientadorId'] ?? json['orientador_id'] ?? 0,
      escolaId: json['escolaId'] ?? json['escola_id'] ?? 0,
      status: json['status'] ?? 'em_andamento',
      iniciadaEm: json['iniciadaEm'] ?? json['iniciada_em'] ?? '',
      concluidaEm: json['concluidaEm'] ?? json['concluida_em'],
      assinaturaUrl: json['assinaturaUrl'] ?? json['assinatura_url'],
      observacaoGeral: json['observacaoGeral'] ?? json['observacao_geral'],
      sincronizado: json['sincronizado'] == 1 || json['sincronizado'] == true,
    );
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'orientador_id': orientadorId,
      'escola_id': escolaId,
      'status': status,
      'iniciada_em': iniciadaEm,
      'concluida_em': concluidaEm,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }
}
