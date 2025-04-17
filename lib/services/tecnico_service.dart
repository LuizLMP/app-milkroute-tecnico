import 'dart:convert';

import 'package:milkroute_tecnico/controller/baseConnectionController.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/services/http_provider.dart';

class TecnicoService {
  Future<Tecnico> getTecnico(String login, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    var url = '$apiURL/tecnico/$login';
    final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant});

    if (response.statusCode == 200) {
      var parsed = json.decode(response.body);

      Tecnico tecnico = Tecnico.fromJson(parsed);

      return tecnico;
    } else {
      throw Exception("Erro consultar técnico!");
    }
  }
}
