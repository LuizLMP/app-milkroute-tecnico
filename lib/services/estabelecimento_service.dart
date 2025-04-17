import 'dart:convert';
import 'package:milkroute_tecnico/controller/baseConnectionController.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/services/http_provider.dart';

class EstabelecimentoService {
  Future<List<Estabelecimento>> getEstabelecimento(String codProdutor, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    var url = '$apiURL/propriedade/$codProdutor/estabelecimentos';
    final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant});

    if (response.statusCode == 200) {
      List<Estabelecimento> estabelecimento = (json.decode(response.body) as List).map((data) => Estabelecimento.fromJson(data)).toList();

      return estabelecimento;
    } else {
      throw Exception("Erro consultar Lista de Estabelecimentos na API!");
    }
  }
}
