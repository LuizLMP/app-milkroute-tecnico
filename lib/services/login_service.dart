import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/baseConnectionController.dart';
import 'package:milkroute_tecnico/model/user.dart';

class LoginService {
  Future<User?> login(String login, String password, String tenant, [String username = "Técnico sem nome"]) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    Uri url;

    if (apiURL == null) {
      url = Uri.parse('$apiURLProduction/login');
    } else {
      url = Uri.parse('$apiURL/login');
    }

    final response = await http.post(url, body: jsonEncode({"username": login, "password": password}), headers: {'Content-type': 'application/json', 'tenant': tenant});

    if (response.statusCode == 200) {
      final Map<String, String> res = response.headers;
      if (res.containsKey('authorization')) {
        return User(username, login, password, tenant, res.putIfAbsent('authorization', () => ''),
            DateTime.parse(res.putIfAbsent('expirationdate', () => DateTime.now().toIso8601String())));
      }
    } else {
      throw Exception("Erro ao validar seu acesso. Verifique se seu LOGIN ou SENHA foram informados corretamente!");
    }
    return null;
  }

  Future<bool> requestAccount(String cpfCnpj, String tenant) async {
    String? apiURL = await BaseConectionController.instance.selectBaseConnection();
    var url = Uri.parse('$apiURL/propriedade/resetPassword/$cpfCnpj');

    final response = await http.get(url, headers: {'Content-type': 'application/json', 'tenant': tenant});

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Erro ao recuperar Senha, favor entrar em contato com o administrador da empresa!");
    }
  }
}
