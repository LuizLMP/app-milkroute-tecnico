import 'package:milkroute_tecnico/controller/baseConnectionController.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:milkroute_tecnico/constants.dart';

class PrePropriedadeService {
  Future<bool> cadastrarProdutor(Map<String, dynamic> produtorData, String tenant) async {
    try {
      String? apiURL = await BaseConectionController.instance.selectBaseConnection();
      Uri url;

      if (apiURL == null) {
        url = Uri.parse(apiURLProduction + '/produtor');
      } else {
        url = Uri.parse(apiURL + '/produtor');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'tenant': tenant,
        },
        body: jsonEncode(produtorData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception("Erro ao cadastrar: ${responseBody['message'] ?? 'Erro desconhecido'}");
      }
    } catch (e) {
      throw Exception(e.toString().substring(e.toString().indexOf(':') + 1));
    }
  }

  Future<Map<String, dynamic>> obterProdutor(String id, String tenant) async {
    try {
      String? apiURL = await BaseConectionController.instance.selectBaseConnection();
      Uri url;

      if (apiURL == null) {
        url = Uri.parse(apiURLProduction + '/produtor/$id');
      } else {
        url = Uri.parse(apiURL + '/produtor/$id');
      }

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'tenant': tenant,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception("Erro ao obter dados: ${responseBody['message'] ?? 'Erro desconhecido'}");
      }
    } catch (e) {
      throw Exception(e.toString().substring(e.toString().indexOf(':') + 1));
    }
  }
}
