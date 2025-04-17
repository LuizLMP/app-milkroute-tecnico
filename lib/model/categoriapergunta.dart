import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/questionario.dart';

class CategoriaPergunta {
  int? id;
  String? descricao;
  int? ordem;
  Questionario? questionario;
  List<Pergunta>? listPerguntas;

  CategoriaPergunta({
    this.id,
    this.descricao,
    this.ordem,
    this.questionario,
    this.listPerguntas,
  });

  CategoriaPergunta.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    ordem = json['ordem'];
    if (json['perguntas'] != null) {
      listPerguntas = <Pergunta>[];
      json['perguntas'].forEach((v) {
        listPerguntas?.add(Pergunta.fromJson(v));
      });
    }
    questionario = json['questionario'] != null ? Questionario.fromJson(json['questionario']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['descricao'] = descricao;
    data['ordem'] = ordem;
    if (listPerguntas != null) {
      data['perguntas'] = listPerguntas?.map((v) => v.toJson()).toList();
    }
    // if (questionario != null) {
    //   data['questionario'] = questionario.toJson();
    // }
    return data;
  }
}
