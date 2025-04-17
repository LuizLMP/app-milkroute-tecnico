import 'dart:convert';
import 'package:milkroute_tecnico/controller/baseConnectionController.dart';
import 'package:milkroute_tecnico/model/notafiscal.dart';
import 'package:milkroute_tecnico/services/http_provider.dart';

class NotaFiscalService {
  Future<List<NotaFiscal>> getListaNotasFiscais(String cpfProdutor, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    var url = '$apiURL/notafiscal/$cpfProdutor';
    final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant});
    if (response.statusCode == 200) {
      List<NotaFiscal> movimentos = (json.decode(response.body) as List).map((data) => NotaFiscal.fromJson(data)).toList();
      return movimentos;
    } else {
      throw Exception("Erro consultar Lista de Notas Fiscais!");
    }
  }

  Future<NotaFiscal> getDANFE(String chaveNF, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    var url = '$apiURL/danfe/$chaveNF';
    final response = await HttpProvider().getData(url, headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant});
    if (response.statusCode == 200) {
      var parsed = json.decode(response.body);

      NotaFiscal notafiscal = NotaFiscal.fromJson(parsed);

      return notafiscal;
    } else {
      throw Exception("Erro consultar Nota Fiscal!");
    }
  }
}
