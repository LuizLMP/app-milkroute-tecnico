import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';

class Opcao {
  int? id;
  String? descricao;
  String? valorResposta;
  bool? ativa;
  String? color;
  Color? get cor => setColorOpcao(color!);
  Pergunta? pergunta;

  Opcao({this.id, this.descricao, this.valorResposta, this.ativa, this.pergunta, this.color});

  Opcao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    valorResposta = json['valorResposta'];
    ativa = json['ativa'];
    color = json['color'];
    pergunta = json['perguntas'] != null ? Pergunta.fromJson(json['perguntas']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['descricao'] = descricao;
    data['valorResposta'] = valorResposta;
    data['ativa'] = ativa;
    data['color'] = color;
    // if (pergunta != null) {
    //   data['perguntas'] = pergunta.toJson();
    // }
    return data;
  }

  Color setColorOpcao(String color) {
    Color cor;

    switch (color) {
      case "GREEN":
        cor = Colors.green;
        break;
      case "RED":
        cor = Colors.red;
        break;
      case "YELLOW":
        cor = Colors.yellow;
        break;
      case "BLUE":
        cor = Colors.blue;
        break;
      case "GREY":
        cor = Colors.grey;
        break;
      case "BLACK":
        cor = Colors.black;
        break;
      case "WHITE":
        cor = Colors.white;
        break;
      case "PURPLE":
        cor = Colors.purple;
        break;
      case "ORANGE":
        cor = Colors.orange;
        break;
      default:
        cor = Colors.lightBlueAccent;
        break;
    }

    return cor;
  }
}
