import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/constants.dart';

class ViewsController extends ChangeNotifier {
  // DECLARAÇÃO DE TODAS AS VIEWS DO APP
  static ViewsController instance = ViewsController();

  int viewId = 0;

  List<BottomNavigationBarItem> carregaBottomBar() {
    return telas.map((e) => BottomNavigationBarItem(icon: e.icone!, label: e.label)).toList();
  }

  carregaViews(context, idx) {
    var view = telas.firstWhere(
      (element) => element.ordem == idx,
      orElse: null,
    );

    ViewsController.instance.viewId = view.ordem!;

    notifyListeners();

    return Navigator.of(context).push(MaterialPageRoute(builder: (context) => view.viewScreen!));
  }
}
