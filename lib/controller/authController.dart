import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/tecnico_dao_impl.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/services/propriedade_service.dart';
import 'package:milkroute_tecnico/services/tecnico_service.dart';
import 'package:milkroute_tecnico/services/visita_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  PropriedadeService apiPropriedade = PropriedadeService();
  TecnicoService apiTecnico = TecnicoService();
  VisitaService apiVisita = VisitaService();
  late Tecnico _tecnico;

  // ignore: missing_return
  Future<Tecnico> carregarUserTecnico(User _user) async {
    Tecnico _newTecnico;
    try {
      // BUSCA NA API

      _newTecnico = await apiTecnico.getTecnico(_user.login!, _user.token!, _user.empresa!);

      // VERIFICA SE JÁ EXISTE TECNICO REGISTRADO
      if (_newTecnico != null) {
        // REGISTRA NO SharedPreferences
        _tecnico = _newTecnico;
        SharedPreferences.getInstance().then((prefs) {
          var _save = json.encode(_tecnico.toJson(), toEncodable: (dynamic object) {
            if (object is DateTime) {
              return object.toIso8601String();
            }
            return object;
          });

          prefs.setString("tecnico_data", _save);
        });

        // SALVA NO SQLITE
        await TecnicoDAOImpl().insert(_newTecnico);

        return _tecnico;
      }
    } catch (ex) {
      print("Erro ao carregar Técnico: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }

    throw Exception("Erro ao carregarUserTecnico");
  }
}
