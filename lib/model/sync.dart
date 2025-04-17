import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/cidade_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/pessoa_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/propriedade_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/questionario_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/tecnico_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/visita_dao_impl.dart';
import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/model/pessoa.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/model/visita.dart';

class Sync<T> {
  int? id;
  String? nomeTabela;
  String? operacao;
  DateTime? dataHora = DateTime.parse('0001-01-01 00:00:00');
  bool? sync;
  TipoProtocolo? protocolo;
  T? get tipoMethodSync => setMethodTipo(nomeTabela!);
  T? get tipoParamsSync => setParamsTipo(nomeTabela!);
  dynamic? dadosSync;

  Sync({this.id, this.nomeTabela, this.operacao, this.dataHora, this.sync, this.protocolo, this.dadosSync});

  Sync.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nomeTabela = json['nomeTabela'];
    operacao = json['operacao'];
    dataHora = json['dataHora'] != null ? DateTime.parse(json['dataHora']) : DateTime.parse('0001-01-01 00:00:00');
    sync = json['sync'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nomeTabela'] = nomeTabela;
    data['operacao'] = operacao;
    data['dataHora'] = dataHora.toString();
    data['sync'] = sync;
    return data;
  }

  T? setMethodTipo(String entidade) {
    var obj;
    switch (entidade) {
      case "Visita":
        obj = VisitaDAOImpl();
        break;
      case "Questionario":
        obj = QuestionarioDAOImpl();
        break;
      case "Propriedade":
        obj = PropriedadeDAOImpl();
        break;
      case "Pessoa":
        obj = PessoaDAOImpl();
        break;
      case "Cidade":
        obj = CidadeDAOImpl();
        break;
      case "Tecnico":
        obj = TecnicoDAOImpl();
        break;
      default:
        return null;
    }

    return obj;
  }

  T? setParamsTipo(String entidade) {
    var obj;
    switch (entidade) {
      case "Visita":
        obj = Visita();
        break;
      case "Questionario":
        obj = Questionario();
        break;
      case "Propriedade":
        obj = Propriedade();
        break;
      case "Pessoa":
        obj = Pessoa();
        break;
      case "Cidade":
        obj = Cidade();
        break;
      case "Tecnico":
        obj = Tecnico();
        break;
      default:
        return null;
    }

    return obj;
  }
}
