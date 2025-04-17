import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/baseConnectionController.dart';
import 'package:milkroute_tecnico/model/banco.dart';

class BancoService {
  Future<List<Banco>> obterBancos(String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    Uri url = Uri.parse('${apiURL ?? apiURLProduction}/banco/lista');

    final response = await http.get(url, headers: {'Content-Type': 'application/json', 'charset': 'utf-8', 'authorization': token, 'tenant': tenant});

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((bancoJson) => Banco.fromJson(bancoJson)).toList();
    } else {
      throw Exception("Erro ao obter bancos: ${response.body}");
    }
  }
}
