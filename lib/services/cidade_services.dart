import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/baseConnectionController.dart';
import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/services/http_provider.dart';

class CidadeService {
  Future<List> getListCidadesAll(String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    List<dynamic> listResult = [];

    try {
      var url = '$apiURL/cidade/lista';
      final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'charset': 'utf-8', 'authorization': token, 'tenant': tenant});

      if (response.statusCode == 200) {
        listResult = json.decode(response.body);

        List<Cidade> listCidades = listResult.map((e) => Cidade.fromJson(e)).toList();

        return listCidades;
      } else {
        throw Exception("Erro consultar lista de cidades!");
      }
    } catch (ex) {
      return listResult;
    }
  }

  Future<List<Cidade>> obterCidadePorCodMunIBGE(String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    Uri url = Uri.parse('${apiURL ?? apiURLProduction}/cidade/{codigoMunIbge}');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'tenant': tenant,
    });

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((cidadeJson) => Cidade.fromJson(cidadeJson)).toList();
    } else {
      throw Exception("Erro ao obter cidades: ${response.body}");
    }
  }
}
