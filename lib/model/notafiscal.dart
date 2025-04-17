import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/constants.dart';

class NotaFiscal {
  int? id;
  int? codProdutor;
  String? nomePropriedade;
  String? nrNotaFiscal;
  String? serie;
  String? especie;
  DateTime? dataEmissao;
  String? chaveAcesso;
  String? danfePdf;
  String? statusNfe;
  DateTime? dataCancelamento;
  Color? get corStatus => setColorNF(statusNfe);
  Icon? get iconeStatus => setIconNF(statusNfe);
  double? quantidadeTotal;
  double? valorTotal;
  double? valorFunrural;
  double? valorLiquido;

  NotaFiscal({
    this.id,
    this.codProdutor,
    this.nomePropriedade,
    this.nrNotaFiscal,
    this.serie,
    this.especie,
    this.dataEmissao,
    this.chaveAcesso,
    this.danfePdf,
    this.statusNfe,
    this.dataCancelamento,
    this.quantidadeTotal,
    this.valorTotal,
    this.valorFunrural,
    this.valorLiquido,
  });

  NotaFiscal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    codProdutor = json['codProdutor'];
    nomePropriedade = json['nomePropriedade'];
    nrNotaFiscal = json['nrNotaFiscal'];
    serie = json['serie'];
    especie = json['especie'];
    dataEmissao = json['dataEmissao'] != null ? DateTime.parse(json['dataEmissao']) : DateTime.parse('0000-00-00 00:00:00');
    chaveAcesso = json['chaveAcesso'];
    danfePdf = json['danfePdf'];
    statusNfe = json['statusNfe'];
    dataCancelamento = json['dataCancelamento'] != null ? DateTime.parse(json['dataCancelamento']) : DateTime.parse('0000-00-00 00:00:00');
    quantidadeTotal = json['quantidadeTotal'];
    valorTotal = json['valorTotal'];
    valorFunrural = json['valorFunrural'];
    valorLiquido = json['valorLiquido'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['codProdutor'] = codProdutor;
    data['nomePropriedade'] = nomePropriedade;
    data['nrNotaFiscal'] = nrNotaFiscal;
    data['serie'] = serie;
    data['especie'] = especie;
    data['dataEmissao'] = dataEmissao;
    data['chaveAcesso'] = chaveAcesso;
    data['danfePdf'] = danfePdf;
    data['statusNfe'] = statusNfe;
    data['dataCancelamento'] = dataCancelamento;
    data['quantidadeTotal'] = quantidadeTotal;
    data['valorTotal'] = valorTotal;
    data['valorFunrural'] = valorFunrural;
    data['valorLiquido'] = valorLiquido;
    return data;
  }

  Color setColorNF(statusNF) {
    Color cor;

    switch (statusNF) {
      case "AUTORIZADO":
        cor = Colors.green;
        break;
      case "CANCELADO":
        cor = Colors.red;
        break;
      case "PENDENTE":
        cor = Colors.yellow;
        break;
      default:
        cor = Colors.white;
        break;
    }

    return cor;
  }

  Icon setIconNF(statusNF) {
    var icone;

    switch (statusNF) {
      case "AUTORIZADO":
        icone = Icons.thumb_up;
        break;
      case "CANCELADO":
        icone = Icons.do_disturb_alt_rounded;
        break;
      case "PENDENTE":
        icone = Icons.access_time_filled;
        break;
      default:
        icone = Icons.question_mark_outlined;
        break;
    }

    return Icon(
      icone,
      color: LightColors.kDarkBlue,
    );
  }
}
