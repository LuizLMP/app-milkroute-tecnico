import 'package:milkroute_tecnico/screens/home/analises_produtor_screen.dart';

class AnaliseLeiteProdutor {
  int? id;
  int? codProdutor;
  String? nomePropriedade;
  String? codEstabel;
  int? codRota;
  String? denominacaoRota;
  String? codigo;
  DateTime? data;
  double? gordura;
  double? proteina;
  double? lactose;
  double? solidosTotais;
  double? esd;
  double? ccs;
  double? cbt;
  String? redutase;
  double? nu;
  double? acidez;
  double? cri;
  String? observacoes;

  AnaliseLeiteProdutor(
      {this.id,
      this.codProdutor,
      this.nomePropriedade,
      this.codEstabel,
      this.codRota,
      this.denominacaoRota,
      this.codigo,
      this.data,
      this.gordura,
      this.proteina,
      this.lactose,
      this.solidosTotais,
      this.esd,
      this.ccs,
      this.cbt,
      this.redutase,
      this.nu,
      this.acidez,
      this.cri,
      this.observacoes});

  AnaliseLeiteProdutor.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int;
    codProdutor = json['codProdutor'] as int;
    nomePropriedade = json['nomePropriedade'];
    codEstabel = json['codEstabel'];
    codRota = json['codRota'] as int;
    denominacaoRota = json['denominacaoRota'];
    codigo = json['codigo'];
    data = json['data'] != null
        ? DateTime.parse(json['data'])
        : DateTime.parse('0001-01-01 00:00:00');
    gordura = json['gordura'];
    proteina = json['proteina'] as double;
    lactose = json['lactose'] as double;
    solidosTotais = json['solidosTotais'] as double;
    esd = json['esd'] as double;
    cbt = json['cbt'] as double;
    ccs = json['ccs'] as double;
    redutase = json['redutase'];
    nu = json['nu'];
    acidez = json['acidez'] ?? 0.0;
    cri = json['cri'] ?? 0.0;
    observacoes = json['observacoes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['id'] = id;
    dataMap['codProdutor'] = codProdutor;
    dataMap['nomePropriedade'] = nomePropriedade;
    dataMap['codEstabel'] = codEstabel;
    dataMap['codRota'] = codRota;
    dataMap['denominacaoRota'] = denominacaoRota;
    dataMap['codigo'] = codigo;
    dataMap['data'] = data
        ?.toIso8601String(); // Corrigido para serializar a data corretamente
    dataMap['gordura'] = gordura;
    dataMap['proteina'] = proteina;
    dataMap['lactose'] = lactose;
    dataMap['solidosTotais'] = solidosTotais;
    dataMap['esd'] = esd;
    dataMap['cbt'] = cbt;
    dataMap['ccs'] = ccs;
    dataMap['redutase'] = redutase;
    dataMap['nu'] = nu;
    dataMap['acidez'] = acidez;
    dataMap['cri'] = cri;
    dataMap['observacoes'] = observacoes;

    return dataMap;
  }
}
