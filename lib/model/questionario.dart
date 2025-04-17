import 'package:milkroute_tecnico/model/categoriapergunta.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';

class Questionario {
  int? id;
  String? descricao;
  String? dataInicio;
  String? dataFim;
  String? ultimaAlteracao;
  List<CategoriaPergunta>? listCategorias;
  Tecnico? tecnico;
  String? orientacoes;

  Questionario({this.id, this.descricao, this.dataInicio, this.dataFim, this.ultimaAlteracao, this.listCategorias, this.tecnico});

  Questionario.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    dataInicio = json['dataInicio'];
    dataFim = json['dataFim'];
    ultimaAlteracao = json['ultimaAlteracao'];
    if (json['categorias'] != null) {
      listCategorias = <CategoriaPergunta>[];
      json['categorias'].forEach((v) {
        listCategorias?.add(CategoriaPergunta.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['descricao'] = descricao;
    data['dataInicio'] = dataInicio;
    data['dataFim'] = dataFim;
    data['ultimaAlteracao'] = ultimaAlteracao;
    if (listCategorias != null) {
      data['categorias'] = listCategorias?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
