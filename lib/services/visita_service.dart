import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/controller/baseConnectionController.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:milkroute_tecnico/services/http_provider.dart';

class VisitaService {
  Future<List<Visita>> carregarVisitasPorTecnico(
    String login,
    String token,
    String tenant,
    DateTime dataInicio,
    DateTime dataFim,
    bool vo, [
    String? statusVisita,
  ]) async {
    BaseConectionController.instance.selectBaseConnection();

    String dataInicioAPI = DateFormat("dd-MM-yyyy").format(DateTime.parse(dataInicio.toString()));
    String dataFimAPI = DateFormat("dd-MM-yyyy").format(DateTime.parse(dataFim.toString()));

    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    String url;
    String voURL = vo ? 'byUsernameVO' : 'byUsername';

    switch (statusVisita) {
      case "AGENDADO":
        url = '$apiURL/visita/$voURL/$login/$dataInicioAPI/$dataFimAPI/AGENDADO';
        break;
      case "FINALIZADO":
        url = '$apiURL/visita/$voURL/$login/$dataInicioAPI/$dataFimAPI/FINALIZADO';
        break;
      case "SOLICITADO":
        url = '$apiURL/visita/$voURL/$login/$dataInicioAPI/$dataFimAPI/SOLICITADO';
        break;
      default:
        url = '$apiURL/visita/$voURL/$login/$dataInicioAPI/$dataFimAPI';
        break;
    }

    //var url = apiURL + '/visita/byUsernameVO/' + login + '/' + dataInicioAPI + '/' + dataFimAPI;
    final response = await HttpProvider().getData(url, headers: {
      'Content-type': 'application/json',
      'authorization': token,
      'tenant': tenant,
    });
    if (response.statusCode == 200) {
      List<dynamic> listResult = json.decode(response.body);

      List<Visita> listVisita = listResult.map((e) => Visita.fromJson(e)).toList();

      return listVisita;
    } else {
      throw Exception("Erro consultar propriedade!");
    }
  }

  Future<List<Visita>> carregarVisitasPorPropriedade(String idPropriedade, String token, String tenant, String dataInicio, String dataFim) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    var url = '$apiURL/visita/byPropriedade/$idPropriedade/$dataInicio/$dataFim';
    final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant});

    if (response.statusCode == 200) {
      List<Visita> movimentos = (json.decode(response.body) as List).map((data) => Visita.fromJson(data)).toList();
      return movimentos;
    } else {
      throw Exception("Erro consultar movimentos!");
    }
  }

  Future<Visita> carregarVisitasPorId(String login, String token, String tenant, int idVisita) async {
    try {
      String? apiURL = await BaseConectionController.instance.selectBaseConnection();
      String url = '$apiURL/visita/byId/$idVisita';
      final response = await HttpProvider().getData(url, headers: {
        'Content-type': 'application/json',
        'authorization': token,
        'tenant': tenant,
      });
      if (response.statusCode == 200) {
        var parsed = json.decode(response.body);

        Visita visita = Visita.fromJson(parsed);

        return visita;
      } else {
        throw Exception("Erro ao retornar visita pela API!");
      }
    } catch (ex) {
      print("Erro postFiles: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      throw Exception("Erro ao consultar visita!");
    }
  }
}
