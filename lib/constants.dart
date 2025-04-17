import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/model/views.dart';
import 'package:milkroute_tecnico/screens/home/produtores_screen.dart';
import 'package:milkroute_tecnico/screens/home/select_formulario_screen.dart';
import 'package:milkroute_tecnico/screens/home/home_screen.dart';
import 'package:milkroute_tecnico/screens/home/visitas_screen.dart';

enum AlertAction {
  cancel,
  discard,
  disagree,
  agree,
}

enum TipoProtocolo {
  GET,
  POST,
}

const String dateFormatAPI = "yyyy-MM-dd HH:mm:ss";
const String dateFormatPtBr = "dd/MM/yyyy HH:mm:ss";
const String apiURLTest = "http://...";
const String apiURLProduction = "http://...";

List<Views> telas = [
  Views(
      viewScreen: HomeScreen(
        restorationId: '0',
      ),
      label: 'Inicio',
      ordem: 0,
      icone: Icon(Icons.home)),
  Views(viewScreen: ProdutoresScreen(), label: 'Produtores', ordem: 1, icone: Icon(Icons.person_pin_rounded)),
  Views(viewScreen: SelectFormularioScreen(), label: 'Nova Visita', ordem: 2, icone: Icon(Icons.calendar_today)),
  // Views(viewScreen: RotasScreen(), label: 'Rotas', ordem: 3, icone: Icon(Icons.map_outlined)),
  Views(viewScreen: VisitasScreen(), label: 'Visitas', ordem: 3, icone: Icon(Icons.fact_check_outlined)),
];

final dbName = "milkroute_tecnico.db";

const bool devMode = false;
const double textScaleFactor = 1.0;

class LightColors {
  static Map<int, Color> color = {
    50: Color.fromRGBO(3, 50, 73, .1),
    100: Color.fromRGBO(3, 50, 73, .2),
    200: Color.fromRGBO(3, 50, 73, .3),
    300: Color.fromRGBO(3, 50, 73, .4),
    400: Color.fromRGBO(3, 50, 73, .5),
    500: Color.fromRGBO(3, 50, 73, .6),
    600: Color.fromRGBO(3, 50, 73, .7),
    700: Color.fromRGBO(3, 50, 73, .8),
    800: Color.fromRGBO(3, 50, 73, .9),
    900: Color.fromRGBO(3, 50, 73, 1),
  };

  static const Color kLightYellow = Color(0xFFFFF9EC);
  static const Color kLightYellow2 = Color(0xFFFFE4C7);
  static const Color kDarkYellow = Color(0xFFF9BE7C);
  static const Color kPalePink = Color(0xFFFED4D6);

  static const Color kRed = Color(0xFFE46472);
  static const Color kLavender = Color(0xFFD5E4FE);
  static const Color kBlue = Color(0xFF6488E4);
  static const Color kLightGreen = Color(0xFFD9E6DC);
  static const Color kGreen = Color(0xFF309397);

  static const Color kLightBlue = Color(0xFF8abed7);
  static const Color kLightBlue2 = Color(0xFF1574a3);
  static const Color kDarkBlue = Color(0xFF033249);
  static MaterialColor mDarkblue = MaterialColor(0xFF033249, color);
}
