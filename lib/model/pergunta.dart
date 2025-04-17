import 'package:milkroute_tecnico/model/categoriapergunta.dart';
import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/type/tipo_resposta.dart';

class Pergunta {
  int? id;
  String? descricao;
  String? tipoResposta;
  bool? obrigatorio;
  bool? ativa;
  int? ordem;
  int? tamanhoMaximo;
  List<Opcao>? listOpcoes;
  CategoriaPergunta? categorias;
  TipoPergunta? get tipoPergunta => setTipoPergunta(tipoResposta!);

  Pergunta({this.id, this.descricao, this.tipoResposta, this.obrigatorio, this.ativa, this.ordem, this.tamanhoMaximo, this.listOpcoes, this.categorias});

  Pergunta.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    tipoResposta = json['tipoResposta'];
    obrigatorio = json['obgrigatorio'];
    ativa = json['ativa'];
    ordem = json['ordem'];
    tamanhoMaximo = json['tamanhoMaximo'];
    if (json['opcoes'] != null) {
      listOpcoes = <Opcao>[];
      json['opcoes'].forEach((v) {
        listOpcoes?.add(Opcao.fromJson(v));
      });
    }
    categorias = json['categorias'] != null ? CategoriaPergunta.fromJson(json['categorias']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['descricao'] = descricao;
    data['tipoResposta'] = tipoResposta;
    data['obgrigatorio'] = obrigatorio;
    data['ativa'] = ativa;
    data['ordem'] = ordem;
    data['tamanhoMaximo'] = tamanhoMaximo;
    // if (categorias != null) {
    //   data['perguntas'] = categorias.toJson();
    // }
    if (listOpcoes != null) {
      data['opcoes'] = listOpcoes?.map((v) => v.toJson()).toList();
    }
    return data;
  }

  TipoPergunta? setTipoPergunta(String tipoResposta) {
    switch (tipoResposta) {
      case "EscolhaUma":
        return TipoPergunta.EscolhaUma;
      case "MultiplaEscolha":
        return TipoPergunta.MultiplaEscolha;
      case "Texto":
        return TipoPergunta.Texto;
      case "Combo":
        return TipoPergunta.Combo;
      case "Data":
        return TipoPergunta.Data;
      default:
        return null;
    }
  }
}
