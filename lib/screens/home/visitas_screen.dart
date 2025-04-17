import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/connectivityController.dart';
import 'package:milkroute_tecnico/controller/viewsController.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/questionario_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/visita_dao_impl.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:milkroute_tecnico/screens/app/app_drawer.dart';
import 'package:milkroute_tecnico/screens/home/formulario_screen.dart';
import 'package:milkroute_tecnico/services/pdf_services.dart';
import 'package:milkroute_tecnico/services/visita_service.dart';
import 'package:milkroute_tecnico/widgets/dialogs.dart';
import 'package:milkroute_tecnico/widgets/footer_screen.dart';
import 'package:milkroute_tecnico/widgets/header_screens.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

// ignore: implementation_imports
import 'package:provider/src/provider.dart';
import 'package:pdf/widgets.dart' as pw;

class VisitasScreen extends StatefulWidget {
  const VisitasScreen({super.key});

  @override
  State<VisitasScreen> createState() => _VisitasScreenState();
}

class _VisitasScreenState extends State<VisitasScreen> {
  final ViewsController _propsView = ViewsController();
  VisitaService apiVisita = VisitaService();

  Future<List<Visita>> _carregaVisitas(User user) async {
    List<Visita> listVisitas = [];

    listVisitas = await VisitaDAOImpl().selectSimple(Visita(), TipoConsultaDB.Tudo);

    listVisitas =
        listVisitas.where((element) => element.dataCriacao!.isAfter(GlobalData.firstDayCurrentMonth) && element.dataCriacao!.isBefore(GlobalData.lastDayCurrentMonth)).toList();

    return listVisitas.toList();
  }

  Future<Visita> carregarVisitaOnline(User user, Visita linha) async {
    Visita visitaAPI;
    visitaAPI = await apiVisita.carregarVisitasPorId(user.login!, user.token!, user.empresa!, linha.idWeb!);

    await VisitaDAOImpl().insert(visitaAPI);

    return visitaAPI;
  }

  Future<bool> _agendarVisita(Visita visita, DateTime? dataVisita, [bool cancelar = false]) async {
    try {
      if (visita != null) {
        if (cancelar) {
          visita.statusVisita = "SOLICITADO";
        } else {
          visita.dataInicio = dataVisita!;
          visita.statusVisita = "CONFIRMADO";
        }

        visita.dataHoraIU = DateTime.now();
        await VisitaDAOImpl().update(visita);

        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print("Erro _finalizarVisita: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double heightSizeToolbar = 70;
    final auth = context.read<AuthModel>();
    final conn = context.watch<ConnectivityProvider>();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: LightColors.kDarkBlue,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          elevation: 0.0,
          centerTitle: true,
          toolbarHeight: heightSizeToolbar,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings,
                color: colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            )
          ],
          title: Stack(
            children: [
              Column(
                children: <Widget>[
                  HeaderScreens(
                    auth: auth,
                    height: heightSizeToolbar,
                    width: width,
                    ordemView: ViewsController.instance.viewId,
                    padding: EdgeInsets.all(8.0), // Add appropriate padding value
                  ),
                ],
              )
            ],
          ),
        ),
        drawer: AppDrawer(),
        body: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: SafeArea(
                bottom: true,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: IconButton(
                            icon: Icon(Icons.help_outlined),
                            iconSize: 26.0,
                            color: colorScheme.primary,
                            onPressed: () {
                              return dialogInfo(
                                context,
                                "Voltar",
                                Text("Guia de ações"),
                                Text("- Pressione uma visita para iniciar.\n" +
                                    "- Segure pressionado para reagendar uma visita.\n" +
                                    "- Pressione e arraste para a direita para cancelar um agendamento.\n" +
                                    "- Pressione e arraste para a esquerda para exportar o relatório de visita em PDF.\n" +
                                    "\n" +
                                    "- Visitas com mais de 90 dias podem ser consultadas apenas no Milkroute Web.\n"),
                              );
                            }),
                        title: Center(child: Text('Visitas', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))),
                        subtitle: Center(child: Text('Relação de visitas', style: TextStyle(fontSize: 15.0))),
                        trailing: IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: () {
                              _showDatePicker(context);
                            }),
                      ),
                      FutureBuilder<List<Visita>>(
                          future: _carregaVisitas(auth.user!),
                          builder: (context, listVisita) {
                            if (listVisita.hasData) {
                              if (listVisita.data!.isNotEmpty) {
                                return Scrollbar(
                                    child: ListView.builder(
                                        physics: const ScrollPhysics(),
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: listVisita.data?.length,
                                        itemBuilder: ((context, index) {
                                          final linha = listVisita.data?[index];
                                          String? statusVisita = linha?.statusVisita;

                                          if (linha!.listRespostas!.isNotEmpty && statusVisita != "FINALIZADO") {
                                            statusVisita = "EM ANDAMENTO";
                                          }

                                          return GestureDetector(
                                            onLongPress: () {
                                              if (linha.statusVisita != "FINALIZADO") {
                                                showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime.now(),
                                                        firstDate: DateTime.now(),
                                                        lastDate: DateTime(DateTime.now().year + 2),
                                                        cancelText: 'Cancelar',
                                                        keyboardType: TextInputType.datetime,
                                                        helpText:
                                                            'Agende uma data para a Visitar ${linha.propriedade!.pessoa!.nomeRazaoSocial!} - ${linha.propriedade!.pessoa!.cidade!.nome!} - ${linha.propriedade!.pessoa!.cidade!.estado!.sigla}')
                                                    .then((pickedDate) async {
                                                  if (pickedDate != null) {
                                                    bool returnSalvaVisita = await _agendarVisita(linha, pickedDate);

                                                    if (returnSalvaVisita) {
                                                      return Navigator.of(context).push(MaterialPageRoute(builder: (context) => VisitasScreen()));
                                                    }
                                                  }
                                                });
                                              }
                                            },
                                            child: (linha.statusVisita == "FINALIZADO")
                                                ? Dismissible(
                                                    key: ValueKey(linha.idAppTecnico),
                                                    direction: DismissDirection.endToStart,
                                                    background: Container(
                                                      alignment: Alignment.centerRight,
                                                      padding: EdgeInsets.only(right: 20.0),
                                                      color: Color.fromARGB(255, 110, 154, 250),
                                                      child: Icon(
                                                        Icons.picture_as_pdf_rounded,
                                                        size: 60.0,
                                                      ),
                                                    ),
                                                    confirmDismiss: (direction) => showDialog(
                                                        context: context,
                                                        builder: (info) => AlertDialog(
                                                              title: Text("Compartilhar o Relatório de Visita?"),
                                                              actions: [
                                                                TextButton(
                                                                  child: Text("Voltar"),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                                TextButton(
                                                                  child: Text("Confirmar"),
                                                                  onPressed: () async {
                                                                    final String nomeArquivo =
                                                                        "Relatório de Visita (${linha.propriedade?.codProdutor} - ${linha.propriedade?.pessoa?.nomeRazaoSocial} [${DateFormat("dd-MM-yyyy").format(linha.dataFinalizacao!)}]";

                                                                    PDFScreen pdf = await PDFService().getRelatorioVisitaPDF(linha, nomeArquivo);

                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) => pdf,
                                                                        ));
                                                                  },
                                                                )
                                                              ],
                                                            )),
                                                    child: cardVisita(auth.user!, linha, conn),
                                                  )
                                                : Dismissible(
                                                    key: ValueKey(linha.idAppTecnico),
                                                    background: Container(
                                                      alignment: Alignment.centerLeft,
                                                      padding: EdgeInsets.only(left: 20.0),
                                                      color: Color.fromARGB(255, 255, 133, 133),
                                                      child: Icon(
                                                        Icons.restore_outlined,
                                                        size: 60.0,
                                                      ),
                                                    ),
                                                    secondaryBackground: Container(
                                                      alignment: Alignment.centerRight,
                                                      padding: EdgeInsets.only(right: 20.0),
                                                      color: Color.fromARGB(255, 110, 154, 250),
                                                      child: Icon(
                                                        Icons.picture_as_pdf_rounded,
                                                        size: 60.0,
                                                      ),
                                                    ),
                                                    confirmDismiss: (direction) {
                                                      if (direction == DismissDirection.startToEnd) {
                                                        return showDialog(
                                                            context: context,
                                                            builder: (info) => AlertDialog(
                                                                  title: Text("Deseja desfazer o agendamento da visita?"),
                                                                  content: Text(
                                                                      "Ao desfazer o agendamento, a Visita será desmarcada sendo necessário definir uma nova data de agendamento!"),
                                                                  actions: [
                                                                    TextButton(
                                                                      child: Text("Voltar"),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                    ),
                                                                    TextButton(
                                                                      child: Text("Confirmar"),
                                                                      onPressed: () async {
                                                                        await _agendarVisita(linha, null, true);

                                                                        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => VisitasScreen()));
                                                                      },
                                                                    )
                                                                  ],
                                                                ));
                                                      } else {
                                                        return showDialog(
                                                            context: context,
                                                            builder: (info) => AlertDialog(
                                                                  title: Text("Compartilhar o Relatório de Visita?"),
                                                                  actions: [
                                                                    TextButton(
                                                                      child: Text("Voltar"),
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                    ),
                                                                    TextButton(
                                                                      child: Text("Confirmar"),
                                                                      onPressed: () async {
                                                                        final String nomeArquivo =
                                                                            "Relatório de Visita (${linha.propriedade?.codProdutor} - ${linha.propriedade?.pessoa?.nomeRazaoSocial} [${DateFormat("dd-MM-yyyy").format(linha.dataFinalizacao!)}]";

                                                                        PDFScreen pdf = await PDFService().getRelatorioVisitaPDF(linha, nomeArquivo);

                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => pdf,
                                                                            ));
                                                                      },
                                                                    )
                                                                  ],
                                                                ));
                                                      }
                                                    },
                                                    child: cardVisita(auth.user!, linha, conn),
                                                  ),
                                          );
                                        })));
                              } else {
                                return Card(
                                    child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Não há nenhuma visita a ser exibida',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ));
                              }
                            } else {
                              return LoaderFeedbackCow(
                                mensagem: "Carregando relação de visitas",
                                size: 60,
                              );
                            }
                          }),
                    ],
                  ),
                )),
          ),
        ),
        bottomNavigationBar: FooterScreens(
          views: _propsView,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
      ),
    );
  }

  pw.Row blockPerguntaResposta({Pergunta? pergunta, RespostaItem? resposta}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.Container(
            alignment: pw.Alignment.topLeft,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(children: [
                  pw.Text("${pergunta?.descricao}: ", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 15)),
                  pw.Text(resposta!.descricao!, style: pw.TextStyle(fontSize: 15)),
                ]),
              ],
            )),
      ],
    );
  }

  Widget cardVisita(User user, Visita linha, ConnectivityProvider conn) {
    print(conn.state);

    if (linha.dataHoraIU == DateTime.parse('0001-01-01 00:00:00') && conn.state == ConnectivityResult.none && linha.statusVisita == "FINALIZADO") {
      return Card(
        color: linha.setColorVisita(linha.statusVisita!).withOpacity(0.5),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () async {
                return dialogInfo(
                  context,
                  "Voltar",
                  Text("Sem sinal de internet"),
                  Text("Apenas as visitas salvas no seu dispositivo podem ser consultadas Offline.\n"),
                );
              },
              leading: CircleAvatar(
                child: (linha.nrVisita == null) ? Icon(Icons.sync_outlined) : Text(linha.nrVisita.toString()),
              ),
              title: Text(
                linha.propriedade!.pessoa!.nomeRazaoSocial.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        "${linha.propriedade?.pessoa?.cidade?.nome} - ${linha.propriedade?.pessoa?.cidade?.estado?.sigla}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Data: '),
                      Text(
                        DateFormat('dd/MM/yyyy').format(linha.dataInicio!).toString(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text('Status: ${linha.statusVisita}')),
                  Row(
                    children: [
                      Text('Motivo: '),
                      Text(
                        linha.questionario!.descricao!.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(children: [
                CircleAvatar(backgroundColor: linha.setColorVisita(linha.statusVisita!), child: Icon(Icons.wifi_off)),
              ]),
            ),
          ],
        ),
      );
    } else {
      return Card(
        color: linha.setColorVisita(linha.statusVisita!),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () async {
                linha.questionario = await QuestionarioDAOImpl().carregarQuestionario(linha.questionario!.id!);

                if (linha.listRespostas!.isEmpty) {
                  linha = await carregarVisitaOnline(user, linha);
                }

                if (linha.statusVisita == "FINALIZADO") {
                  return dialog1Opt(
                    context,
                    "OK",
                    "Visita finalizada!",
                    "Visitas finalizadas estão disponíveis apenas para consulta!",
                    FormularioScreen(
                      visita: linha,
                      questionario: linha.questionario!,
                      propriedade: linha.propriedade!,
                    ),
                  );
                } else {
                  return dialog2Opt(
                    context,
                    "Cancelar",
                    "Iniciar",
                    "Iniciar preenchimento de Questionário",
                    "Deseja iniciar o questionário ${linha.questionario?.descricao} para o produtor(a) ${linha.propriedade?.pessoa?.nomeRazaoSocial}?",
                    "",
                    FormularioScreen(
                      visita: linha,
                      questionario: linha.questionario!,
                      propriedade: linha.propriedade!,
                    ),
                  );
                }
              },
              leading: CircleAvatar(
                child: (linha.nrVisita == null) ? Icon(Icons.sync_outlined) : Text(linha.nrVisita.toString()),
              ),
              title: Text(
                linha.propriedade!.pessoa!.nomeRazaoSocial.toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                children: <Widget>[
                  Row(
                    children: [
                      Text(
                        "${linha.propriedade?.pessoa?.cidade?.nome} - ${linha.propriedade?.pessoa?.cidade?.estado?.sigla}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Data: '),
                      Text(
                        DateFormat('dd/MM/yyyy').format(linha.dataInicio!).toString(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  Align(alignment: Alignment.centerLeft, child: Text('Status: ${linha.statusVisita}')),
                  Row(
                    children: [
                      Text('Motivo: '),
                      Text(
                        linha.questionario!.descricao!.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(children: [
                CircleAvatar(backgroundColor: linha.setColorVisita(linha.statusVisita!), child: Icon(Icons.open_in_new)),
              ]),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showMonthPicker(context: context, initialDate: GlobalData.periodo, firstDate: DateTime.now().subtract(Duration(days: 90)), lastDate: DateTime.now());
    if (picked != null && picked != GlobalData.periodo) {
      setState(() {
        GlobalData.periodo = picked;
        GlobalData.firstDayCurrentMonth = DateTime(GlobalData.periodo.year, GlobalData.periodo.month, 1, 0, 0, 0);
        GlobalData.lastDayCurrentMonth = DateTime(GlobalData.periodo.year, GlobalData.periodo.month + 1, 1, 23, 59, 59).subtract(Duration(days: 1));
      });
    }
  }
}
