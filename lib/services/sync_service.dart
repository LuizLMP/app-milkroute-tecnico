import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/baseConnectionController.dart';
import 'package:milkroute_tecnico/model/anexos_visita.dart';
import 'package:milkroute_tecnico/model/sync.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:milkroute_tecnico/services/http_provider.dart';

class SyncService {
  Future<List<Sync>> getSync(String login, String token, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    List<Sync> listSync = [];
    try {
      var url = '$apiURL/escutaAlteracoes';
      final response = await HttpProvider().getData(url, headers: {
        'Content-type': 'application/json',
        'authorization': token,
        'tenant': tenant,
      }).timeout(Duration(seconds: 10), onTimeout: () {
        return Response('', 404);
      });

      if (response.statusCode == 200) {
        List<dynamic> listResult = json.decode(response.body);

        listSync = listResult.map((e) => Sync.fromJson(e)).toList();

        listSync.sort((a, b) {
          return b.dataHora?.compareTo(a.dataHora ?? DateTime(0)) ?? 0;
        });

        for (Sync elemSync in listSync) {
          elemSync.protocolo = TipoProtocolo.GET;
        }

        return listSync;
      } else {
        throw Exception("Erro consultar pendencias de sincronização!");
      }
    } catch (ex) {
      return listSync;
    }
  }

  Future<bool> postSync(String login, String token, String tenant, dynamic jsonBody) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    var url = '$apiURL/escutaAlteracoes';

    final response = await HttpProvider().postData(
      url,
      headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant},
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      throw Exception("Erro ao consultar pendencias de sincronização!");
    }
  }

  Future<bool> postVisita(String login, String token, String tenant, dynamic jsonBody) async {
    try {
      String? apiURL = await BaseConectionController.instance.selectBaseConnection();
      var url = '$apiURL/visita/v2/$login';

      // print("----- JSON BODY: ");
      // log(jsonBody);

      final response = await HttpProvider().postData(
        url,
        headers: {'Content-type': 'application/json', 'authorization': token, 'tenant': tenant},
        body: jsonBody,
      );

      log(jsonBody);

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode >= 400) {
        return false;
      } else {
        throw Exception("Erro ao consultar pendencias de sincronização!");
      }
    } catch (ex) {
      print("Erro postVisita: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      throw Exception("Erro ao consultar pendencias de sincronização!");
    }
  }

  Future<bool> postAnexosVisita(String login, String token, String tenant, Visita visita, AnexosVisita anexosVisita, List<File> files) async {
    try {
      String? apiURL = await BaseConectionController.instance.selectBaseConnection();
      String tipoArquivo = anexosVisita.tipoArquivo == TipoArquivo.Assinatura ? 'true' : 'false';

      var url = '$apiURL/visita/arquivo/${visita.idWeb}/${anexosVisita.idAppTecnico}/$tipoArquivo';

      var request = MultipartRequest('POST', Uri.parse(url));
      request.headers['authorization'] = token;
      request.headers['tenant'] = tenant;

      for (var file in files) {
        var stream = ByteStream(Stream.castFrom(file.openRead()));
        var length = await file.length();
        var filename = file.path.split('/').last;

        var multipartFile = MultipartFile('file', stream, length, filename: filename);

        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode >= 400) {
        return false;
      } else {
        throw Exception("Erro ao enviar anexos de visitas!");
      }
    } catch (ex) {
      print("Erro postFiles: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      throw Exception("Erro ao enviar anexos de visitas!");
    }
  }
}
