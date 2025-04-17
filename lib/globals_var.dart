import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/visita.dart';

class GlobalData {
  static var produtorSelecionado = Propriedade();

  static var cidadeSelecionada = Cidade();

  static Estabelecimento estabelecimentoSelecionado = Estabelecimento();

  static List<Propriedade> listaGlobalAPIPropriedades = [];

  static List<Visita> listaGlobalAPIVisitas = [];

  static var periodo = DateTime.now();

  static var lastSyncDateTime = DateTime.now();

  static var firstDayCurrentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  static var lastDayCurrentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month + 1,
  ).subtract(Duration(days: 1));

  static var firstDayCurrentMonthFix = DateTime(DateTime.now().year, DateTime.now().month, 1);

  static var lastDayCurrentMonthFix = DateTime(DateTime.now().year, DateTime.now().month + 1, 1, 23, 59, 59).subtract(Duration(days: 1));

  static var firstDayLastCurrentMonthFix = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);

  static var lastDayLastCurrentMonthFix = DateTime(DateTime.now().year, DateTime.now().month, 1, 23, 59, 59).subtract(Duration(days: 1));

  String convertDateToCast(IdiomaData tipoDataEntrada, String valorData) {
    switch (tipoDataEntrada) {
      case IdiomaData.PtBR:
        if (valorData.length == 10) {
          return valorData.substring(6, 10) + "-" + valorData.substring(3, 5) + "-" + valorData.substring(0, 2);
        } else {
          return throw Exception('A data não pode ser convertida. Implemente a conversão desejada');
        }

        break;

      case IdiomaData.EnUS:
        if (valorData.length == 10) {
          return valorData.substring(8, 10) + "/" + valorData.substring(5, 7) + "/" + valorData.substring(0, 4);
        } else {
          return throw Exception('A data não pode ser convertida. Implemente a conversão desejada');
        }
        break;

      default:
        return throw Exception('A data não pode ser convertida. Implemente a conversão desejada');
    }
  }
}

enum IdiomaData { PtBR, EnUS }
