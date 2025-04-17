import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/resposta.dart';

class RespostaItem {
  int? idWeb;
  String? idAppTecnico;
  Opcao? opcao;
  String? descricao = "";
  Pergunta? pergunta;
  Resposta? resposta;
  bool? visualizaResposta = false;
  DateTime? dataHoraIU = DateTime.parse('0001-01-01 00:00:00');

  RespostaItem({this.idWeb, this.idAppTecnico, this.opcao, this.descricao, this.pergunta, this.resposta, this.visualizaResposta, this.dataHoraIU});

  RespostaItem.fromJson(Map<String, dynamic> json) {
    idWeb = json['id'];
    idAppTecnico = json['idAppTecnico'];
    opcao = json['opcao'] != null ? Opcao.fromJson(json['opcao']) : null;
    descricao = json['descricao'];
    pergunta = json['pergunta'] != null ? Pergunta.fromJson(json['pergunta']) : null;
    resposta = json['resposta'] != null ? Resposta.fromJson(json['resposta']) : null;
    visualizaResposta = (json['visualizaResposta'] == null) ? true : json['visualizaResposta'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = idWeb;
    data['idAppTecnico'] = idAppTecnico;
    if (opcao != null) {
      data['opcao'] = opcao?.toJson();
    }
    data['descricao'] = descricao;
    if (pergunta != null) {
      data['pergunta'] = pergunta?.toJson();
    }
    data['visualizaResposta'] = visualizaResposta;

    // if (resposta != null) {
    //   data['resposta'] = resposta.toJson();
    // }

    return data;
  }
}
