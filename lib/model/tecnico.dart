import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/model/questionario.dart';

class Tecnico {
  int? id;
  String? nomeTecnico;
  int? sequenciaNrVisita;
  List<Questionario>? listQuestionarios;
  List<Estabelecimento>? listEstabelecimentos;

  Tecnico({
    this.id,
    this.nomeTecnico,
    this.sequenciaNrVisita,
    this.listQuestionarios,
    this.listEstabelecimentos,
  });

  Tecnico.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nomeTecnico = json['nomeTecnico'];
    if (json['questionarios'] != null) {
      listQuestionarios = <Questionario>[];
      json['questionarios'].forEach((v) {
        listQuestionarios?.add(Questionario.fromJson(v));
      });
    }
    if (json['estabelecimentos'] != null) {
      listEstabelecimentos = <Estabelecimento>[];
      json['estabelecimentos'].forEach((v) {
        listEstabelecimentos?.add(Estabelecimento.fromJson(v));
      });
    }
    sequenciaNrVisita = json['sequenciaNrVisita'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nomeTecnico'] = nomeTecnico;
    if (listQuestionarios != null) {
      data['questionarios'] = listQuestionarios?.map((v) => v.toJson()).toList();
    }
    data['sequenciaNrVisita'] = sequenciaNrVisita;
    return data;
  }
}
