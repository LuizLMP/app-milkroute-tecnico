import 'dart:convert';
import 'package:milkroute_tecnico/controller/baseConnectionController.dart';

import 'package:milkroute_tecnico/model/analise_leite.dart';
import 'package:milkroute_tecnico/model/movimento_leite.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/services/http_provider.dart';

class PropriedadeService {
  Future<List> getListPropriedade(String login, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    List<dynamic> listResult = [];

    try {
      var url = '$apiURL/propriedade/byTecnico/$login';
      final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'charset': 'utf-8', 'authorization': token, 'tenant': tenant});

      if (response.statusCode == 200) {
        listResult = json.decode(response.body);

        List<Propriedade> listPropriedade = listResult.map((e) => Propriedade.fromJson(e)).toList();

        return listPropriedade;
      } else {
        throw Exception("Erro consultar propriedade!");
      }
    } catch (ex) {
      return listResult;
    }
  }

  Future<List> getListPropriedadeByEstabelecimento(String login, String token, String tenant, String codEstabel) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    List<dynamic> listResult = [];

    try {
      var url = '$apiURL/propriedade/byTecnicoEst/v2/$login/$codEstabel';
      final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'charset': 'utf-8', 'authorization': token, 'tenant': tenant});

      if (response.statusCode == 200) {
        listResult = json.decode(response.body);

        List<Propriedade> listPropriedade = listResult.map((e) => Propriedade.fromJson(e)).toList();

        return listPropriedade;
      } else {
        throw Exception("Erro consultar propriedade!");
      }
    } catch (ex) {
      return listResult;
    }
  }

  Future<Propriedade> getPropriedade(String cpfProdutor, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    var url = '$apiURL/propriedade/$cpfProdutor';
    final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant});
    if (response.statusCode == 200) {
      var parsed = json.decode(response.body);

      Propriedade propriedade = Propriedade.fromJson(parsed);

      return propriedade;
    } else {
      throw Exception("Erro consultar propriedade!");
    }
  }

  Future<List<AnaliseLeiteProdutor>> getAnaliseLeiteProdutor(String username, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    List<AnaliseLeiteProdutor> movimentos = [];

    try {
      var url = '$apiURL/analiseleite/$username';
      final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant});
      if (response.statusCode == 200) {
        movimentos = (json.decode(response.body) as List).map((data) => AnaliseLeiteProdutor.fromJson(data)).toList();
        return movimentos;
      } else {
        throw Exception("Erro consultar movimentos!");
      }
    } catch (ex) {
      return movimentos;
    }
  }

  Future<List<MovimentoLeiteProdutor>> getMovimentoLeiteProdutor(String username, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    List<MovimentoLeiteProdutor> movimentos = [];
    try {
      var url = '$apiURL/movimentoleite/$username';
      final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant});
      if (response.statusCode == 200) {
        movimentos = (json.decode(response.body) as List).map((data) => MovimentoLeiteProdutor.fromJson(data)).toList();

        return movimentos;
      } else {
        throw Exception("Erro consultar movimentos!");
      }
    } catch (ex) {
      return movimentos;
    }
  }
}
