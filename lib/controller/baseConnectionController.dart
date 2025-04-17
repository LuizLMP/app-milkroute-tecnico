import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseConectionController extends ChangeNotifier {
  static BaseConectionController instance = BaseConectionController();

  late String urlAPI;

  Future<String?> selectBaseConnection() async {
    var _prefs = await SharedPreferences.getInstance();

    urlAPI = _prefs.getString("urlAPI")!;

    notifyListeners();

    return _prefs.getString("urlAPI");
  }
}
