import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/model/resposta.dart';

class FormsController extends ChangeNotifier {
  static FormsController instance = FormsController();

  Resposta resposta = Resposta();

  // Future<Resposta> carregaRespostaPorQuestionario(
  //     Questionario questionario) async {
  //   var resposta = await RespostaDAOImpl().selectAll(
  //       Resposta(questionario: questionario),
  //       TipoConsultaDB.PorQuestionario);

  //   if (resposta.length == 0) {
  //     var visita = await VisitaDAOImpl().selectAll(
  //         Visita(questionario: questionario),
  //         TipoConsultaDB.PorQuestionario);

  //     var idResposta = await RespostaDAOImpl().insert(Resposta(
  //         questionario: questionario,
  //         dataCriacao: DateTime.now(),
  //         dataHoraIU: DateTime.now(),
  //         visita: visita[0]));

  //     resposta = await RespostaDAOImpl()
  //         .selectAll(Resposta(id: idResposta), TipoConsultaDB.PorPK);
  //   }

  //   FormsController.instance.resposta = resposta[0];

  //   notifyListeners();

  //   return resposta[0];
  // }
}
