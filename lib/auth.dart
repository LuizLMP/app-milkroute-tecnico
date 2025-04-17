import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/services/login_service.dart';
import 'package:milkroute_tecnico/controller/authController.dart';
import 'package:milkroute_tecnico/services/tecnico_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:milkroute_tecnico/constants.dart';

class AuthModel extends ChangeNotifier {
  String errorMessage = "";
  bool _rememberMe = false;
  bool _stayLoggedIn = true;
  bool _useBio = false;
  bool _testMode = false;
  String _apiURLConnection = "";
  User? _user;
  Tecnico? _tecnico;
  LoginService api = LoginService();
  TecnicoService apiTecnico = TecnicoService();
  AuthController _authController = AuthController();

  bool get rememberMe => _rememberMe;

  void handleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("remember_me", value);
    });
  }

  bool get isBioSetup => _useBio;
  bool get isTest => _testMode;

  void handleIsBioSetup(bool value) {
    _useBio = value;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("use_bio", value);
    });
  }

  void switchProductionTestes(bool value) {
    _testMode = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("urlAPI", (value) ? apiURLTest : apiURLProduction);
    });
    notifyListeners();
  }

  bool get stayLoggedIn => _stayLoggedIn;

  void loadSettings() async {
    var _prefs = await SharedPreferences.getInstance();
    switchProductionTestes(false);

    try {
      _useBio = _prefs.getBool("use_bio") ?? false;
    } catch (ex) {
      print(ex);
      _useBio = false;
    }
    try {
      switchProductionTestes(false);
      _apiURLConnection = _prefs.getString("urlAPI") ?? apiURLProduction;
      _testMode = (_prefs.getString("urlAPI") == apiURLTest) ? true : false;
    } catch (ex) {
      _apiURLConnection = apiURLProduction;
      _testMode = false;
    }
    try {
      _rememberMe = _prefs.getBool("remember_me") ?? false;
    } catch (ex) {
      print(ex);
      _rememberMe = false;
    }
    try {
      _stayLoggedIn = _prefs.getBool("stay_logged_in") ?? false;
    } catch (ex) {
      print(ex);
      _stayLoggedIn = false;
    }

    if (_stayLoggedIn) {
      User? _savedUser;
      try {
        String? _saved = _prefs.getString("user_data");
        if (_saved != null) {
          _savedUser = User.fromJson(json.decode(_saved));
        }
      } catch (ex) {
        print("User Not Found: $ex");
      }
      if (!kIsWeb && _useBio) {
        if (await biometrics() && _savedUser != null) {
          _user = _savedUser;
        }
      } else if (_savedUser != null) {
        _user = _savedUser;
      }

      Tecnico _savedTecnico;
      String? _savedTec = _prefs.getString("tecnico_data");

      if (_savedTec != null) {
        try {
          _savedTecnico = Tecnico.fromJson(json.decode(_savedTec));
          _tecnico = _savedTecnico;
        } catch (ex) {
          print("Técnico Not Found: $ex");
        }
      } else {
        _tecnico = await _authController.carregarUserTecnico(_user!);
      }
    }
    notifyListeners();
  }

  Future<bool> biometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
        localizedReason: 'Insira suas digitais para continuar!',
      );
    } catch (ex) {
      print("Erro Biometrics: " +
          ex.toString().substring(ex.toString().indexOf(':') + 1));
    }
    return authenticated;
  }

  User? get user {
    if (_user != null &&
        _user?.expirationToken != null &&
        _user!.expirationToken!
            .isBefore(DateTime.now().add(const Duration(days: 2)))) {
      refreshSession();
    }
    return _user;
  }

  Tecnico? get tecnico => _tecnico;
  User? get usuario => _user;

  Future<bool> newaccoutn(
      {required String cpfCnpj, required String empresa}) async {
    try {
      await api.requestAccount(cpfCnpj, empresa);
      return true;
    } catch (ex) {
      errorMessage = ex.toString().substring(ex.toString().indexOf(":") + 1);
      return false;
    }
  }

  Future<bool> login(
      {required String login,
      required String password,
      required String tenant}) async {
    User? _newUser;

    try {
      _newUser = await api.login(login, password, tenant);
    } catch (ex) {
      errorMessage = ex.toString().substring(ex.toString().indexOf(":") + 1);
      return false;
    }

    if (_newUser?.token == null || _newUser!.token!.isEmpty) {
      errorMessage = "Token inválido ou não fornecido.";
      return false;
    }

    if (_rememberMe) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString("saved_login", _newUser?.login ?? "");
        prefs.setString("saved_empresa", _newUser?.empresa ?? "");
      });
    }

    if (_newUser != null) {
      _user = _newUser;
      SharedPreferences.getInstance().then((prefs) {
        var _save = json.encode(_user?.toJson(), toEncodable: myDateSerializer);
        prefs.setString("user_data", _save);
        prefs.setBool("stay_logged_in", true);
      });
    }

    try {
      _tecnico = await _authController.carregarUserTecnico(user!);
      if (_tecnico == null ||
          _tecnico!.listEstabelecimentos == null ||
          _tecnico!.listEstabelecimentos!.isEmpty) {
        errorMessage = "Não há nenhum Estabelecimento para este Técnico!";
        return false;
      }
    } catch (e) {
      errorMessage = "Erro ao carregar Técnico: ${e.toString()}";
      return false;
    }

    if (_newUser?.token == null || _newUser!.token!.isEmpty) return false;

    if (_tecnico == null ||
        _tecnico!.listEstabelecimentos == null ||
        _tecnico!.listEstabelecimentos!.isEmpty) {
      errorMessage = "Não há nenhum Estabelecimento para este Técnico!";
      return false;
    }

    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    _user = null;
    _tecnico = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user_data", "");
    await prefs.setBool("stay_logged_in", false);

    await _limparDatabase();
    notifyListeners();
  }

  Future<void> _limparDatabase() async {
    return await Connection.clearDB();
  }

  Future<void> refreshSession() async {
    if (_user == null) {
      errorMessage = "Usuário não está logado.";
      return;
    }

    User? _newUser;
    try {
      _newUser = await api.login(
        _user!.login!,
        _user!.password!,
        _user!.empresa!,
      );
    } catch (ex) {
      errorMessage = ex.toString().substring(ex.toString().indexOf(":") + 1);
      return;
    }

    if (_newUser != null) {
      _user = _newUser;

      final prefs = await SharedPreferences.getInstance();
      var _save = json.encode(_user?.toJson(), toEncodable: myDateSerializer);
      await prefs.setString("user_data", _save);
      await prefs.setBool("stay_logged_in", true);

      _tecnico = await _authController.carregarUserTecnico(_user!);
      notifyListeners(); // Adicionado para garantir atualização pós-refresh
    }
  }

  dynamic myDateSerializer(dynamic object) {
    if (object is DateTime) {
      return object.toIso8601String();
    }
    return object;
  }
}
