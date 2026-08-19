class EscolaModel {
  final int id;
  final String nome;
  final String cidade;
  final String estado;
  final String? codigo;
  final double? lat;
  final double? lng;
  final String dataVisitaAgendada;
  final String status; // 'pendente', 'em_andamento', 'concluida'
  final int totalAtivos;
  final int ativosConferidos;
  double? distanciaKm;

  EscolaModel({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.estado,
    this.codigo,
    this.lat,
    this.lng,
    required this.dataVisitaAgendada,
    required this.status,
    required this.totalAtivos,
    required this.ativosConferidos,
    this.distanciaKm,
  });

  factory EscolaModel.fromJson(Map<String, dynamic> json) {
    return EscolaModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nome: json['nome'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      codigo: json['codigo'],
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.parse(json['lng'].toString()) : null,
      dataVisitaAgendada: json['dataVisitaAgendada'] ?? json['data_visita_agendada'] ?? '',
      status: json['status'] ?? 'pendente',
      totalAtivos: json['totalAtivos'] ?? json['total_ativos'] ?? 0,
      ativosConferidos: json['ativosConferidos'] ?? json['ativos_conferidos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cidade': cidade,
      'estado': estado,
      'codigo': codigo,
      'lat': lat,
      'lng': lng,
      'dataVisitaAgendada': dataVisitaAgendada,
      'status': status,
      'totalAtivos': totalAtivos,
      'ativosConferidos': ativosConferidos,
    };
  }

  Map<String, dynamic> toSqliteMap() {
    return {
      'id': id,
      'nome': nome,
      'cidade': cidade,
      'estado': estado,
      'lat': lat,
      'lng': lng,
      'status': status,
      'data_visita_agendada': dataVisitaAgendada,
      'total_ativos': totalAtivos,
      'ativos_conferidos': ativosConferidos,
    };
  }
}
