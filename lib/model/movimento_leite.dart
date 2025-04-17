class MovimentoLeiteProdutor {
  int? id;
  int? codProdutor;
  String? nomePropriedade;
  String? numeroDocumento;
  int? nrMapa;
  DateTime? dataColeta;
  int? quantidade;
  double? media;
  int? ano;
  int? mes;

  MovimentoLeiteProdutor({this.id, this.codProdutor, this.nomePropriedade, this.numeroDocumento, this.nrMapa, this.dataColeta, this.quantidade, this.media, this.ano, this.mes});

  MovimentoLeiteProdutor.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    codProdutor = json['codProdutor'] as int;
    nomePropriedade = json['nomePropriedade'];
    numeroDocumento = json['numeroDocumento'].toString().replaceAll(".", "").replaceAll("-", "");
    nrMapa = json['nrMapa'] as int;
    dataColeta = json['dataColeta'] != null ? DateTime.parse(json['dataColeta']) : DateTime.parse('0001-01-01 00:00:00');

    quantidade = json['quantidade'] as int;
    media = checkDouble(json['media'].toString());
    ano = json['ano'] as int;
    mes = json['mes'] as int;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['codProdutor'] = codProdutor;
    data['nomePropriedade'] = nomePropriedade;
    data['numeroDocumento'] = numeroDocumento;
    data['nrMapa'] = nrMapa;
    data['dataColeta'] = dataColeta;
    data['quantidade'] = quantidade;
    data['media'] = media;
    data['mes'] = mes;
    data['ano'] = ano;

    return data;
  }

  static double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value.toDouble();
    }
  }
}
