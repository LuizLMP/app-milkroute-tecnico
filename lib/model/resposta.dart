import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/visita.dart';

class Resposta {
  String? idAppTecnico;
  int? idWeb;
  DateTime? dataCriacao = DateTime.parse('0001-01-01 00:00:00');
  Questionario? questionario;
  List<RespostaItem>? listRespostaItem;
  Visita? visita;
  DateTime? dataHoraIU = DateTime.parse('0001-01-01 00:00:00');

  Resposta({this.idWeb, this.idAppTecnico, this.dataCriacao, this.questionario, this.listRespostaItem, this.visita, this.dataHoraIU});

  Resposta.fromJson(Map<String, dynamic> json) {
    idAppTecnico = json['idAppTecnico'];
    idWeb = json['id'];
    dataCriacao = json['dataCriacao'] != null ? DateTime.parse(json['dataCriacao']) : DateTime.parse('0001-01-01 00:00:00');
    questionario = json['questionario'] != null ? Questionario.fromJson(json['questionario']) : null;
    if (json['respostaItem'] != null) {
      listRespostaItem = <RespostaItem>[];
      json['respostaItem'].forEach((v) {
        listRespostaItem?.add(RespostaItem.fromJson(v));
      });
    }
    visita = json['visita'] != null ? Visita.fromJson(json['visita']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = idWeb;
    data['idAppTecnico'] = idAppTecnico;
    data['dataCriacao'] = dataCriacao.toString();
    if (questionario != null) {
      data['questionario'] = questionario?.toJson();
    }
    if (listRespostaItem != null) {
      data['respostaItem'] = listRespostaItem?.map((v) => v.toJson()).toList();
    }
    if (visita != null) {
      data['visita'] = visita?.toJson();
    }
    return data;
  }
}
