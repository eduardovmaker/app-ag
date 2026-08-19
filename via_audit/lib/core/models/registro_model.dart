class RegistroModel {
  final int? id;
  final String? localId;
  final int visitaId;
  final int ativoId;
  final int unidadeNumero;
  final String status; // 'ok', 'avariado', 'nao_encontrado', 'extra'
  final String? patrimonioFisico;
  final String? fotoPath;
  final String? fotoUrl;
  final double? lat;
  final double? lng;
  final String? observacao;
  final bool sincronizado;
  final String criadoEm;

  RegistroModel({
    this.id,
    this.localId,
    required this.visitaId,
    required this.ativoId,
    required this.unidadeNumero,
    required this.status,
    this.patrimonioFisico,
    this.fotoPath,
    this.fotoUrl,
    this.lat,
    this.lng,
    this.observacao,
    this.sincronizado = false,
    required this.criadoEm,
  });

  factory RegistroModel.fromJson(Map<String, dynamic> json) {
    return RegistroModel(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      localId: json['localId'] ?? json['local_id'],
      visitaId: json['visitaId'] ?? json['visita_id'] ?? 0,
      ativoId: json['ativoId'] ?? json['ativo_id'] ?? 0,
      unidadeNumero: json['unidadeNumero'] ?? json['unidade_numero'] ?? 1,
      status: json['status'] ?? 'ok',
      patrimonioFisico: json['patrimonioFisico'] ?? json['patrimonio_fisico'],
      fotoPath: json['fotoPath'] ?? json['foto_path'],
      fotoUrl: json['fotoUrl'] ?? json['foto_url'],
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.parse(json['lng'].toString()) : null,
      observacao: json['observacao'],
      sincronizado: json['sincronizado'] == 1 || json['sincronizado'] == true,
      criadoEm: json['criadoEm'] ?? json['criado_em'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'local_id': localId,
      'visita_id': visitaId,
      'ativo_id': ativoId,
      'unidade_numero': unidadeNumero,
      'status': status,
      'patrimonio_fisico': patrimonioFisico,
      'foto_path': fotoPath,
      'lat': lat,
      'lng': lng,
      'observacao': observacao,
      'sincronizado': sincronizado ? 1 : 0,
      'criado_em': criadoEm,
    };
  }
}
