import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/viewsController.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/estabelecimento_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/propriedade_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/questionario_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/tecnico_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/visita_dao_impl.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/utils.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:milkroute_tecnico/screens/app/app_drawer.dart';
import 'package:milkroute_tecnico/screens/home/formulario_screen.dart';
import 'package:milkroute_tecnico/services/visita_service.dart';
import 'package:milkroute_tecnico/widgets/dialogs.dart';
import 'package:milkroute_tecnico/widgets/footer_screen.dart';
import 'package:milkroute_tecnico/widgets/header_screens.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectFormularioScreen extends StatefulWidget {
  const SelectFormularioScreen({super.key, this.propriedade});

  final Propriedade? propriedade;

  @override
  _SelectFormularioScreenState createState() => _SelectFormularioScreenState();
}

class _SelectFormularioScreenState extends State<SelectFormularioScreen> with TickerProviderStateMixin {
  late String valProdutoSelecionado;
  final ViewsController _propsView = ViewsController();
  VisitaService apiVisita = VisitaService();

  TabController? _tabController;
  Estabelecimento? _estabelecimento;

  Future<List<Visita>> _carregarVisitasAgendadas(User user) async {
    // var listVisita = await VisitaDAOImpl().selectAll(Visita(), TipoConsultaDB.Tudo);
    var listVisita = await VisitaDAOImpl().selectSimple(Visita(), TipoConsultaDB.Tudo);

    for (Visita visita in listVisita) {
      List<Propriedade> listPropriedade = [];
      List<Questionario> listQuestionario = [];
      listPropriedade = await PropriedadeDAOImpl().selectSimple(visita.propriedade!, TipoConsultaDB.Tudo);
      listQuestionario = await QuestionarioDAOImpl().selectSimple(visita.questionario!, TipoConsultaDB.Tudo);

      visita.propriedade = listPropriedade[0];
      visita.questionario = listQuestionario[0];
    }

    return listVisita;
    // return listVisita.where((elem) => elem.statusVisita == "AGENDADO").toList();
  }

  Future<List<Propriedade>> _carregaPropriedades() async {
    var list = await PropriedadeDAOImpl().selectSimple(Propriedade(), TipoConsultaDB.Tudo);

    return list.toList();
  }

  Future<Propriedade?> _carregaFullPropriedade(Propriedade propriedade) async {
    return await PropriedadeDAOImpl().carregarPropriedade(propriedade.id!);
  }

  Future<List<Map<Visita, Questionario>>> _carregaQuestionarioPorVisitaProdutor(User user, Propriedade propriedade, [int tipoVisita = 0]) async {
    List<Map<Visita, Questionario>> listQuestionarios = [];

    final tecnico = await TecnicoDAOImpl().selectAll(Tecnico(), TipoConsultaDB.Tudo);

    if (tecnico.isNotEmpty) {
      if (tipoVisita == 0) {
        final listVisitas = await _carregarVisitasAgendadas(user);

        var listVisitasFiltradas = listVisitas
            .where((elem) =>
                elem.propriedade?.codigoNomeProdutor == propriedade.codigoNomeProdutor &&
                tecnico[0].listQuestionarios!.any((tecnicoQuest) => tecnicoQuest.id == elem.questionario?.id))
            .toList();

        for (Visita visita in listVisitasFiltradas) {
          if (visita.listRespostas!.isNotEmpty) {
            visita.statusVisita = "EM ANDAMENTO";
          }

          listQuestionarios.add({visita: visita.questionario!});
        }
      } else {
        for (Questionario questionario in tecnico[0].listQuestionarios!) {
          listQuestionarios.add({Visita(): questionario});
        }
      }
    }

    return listQuestionarios.toList();
  }

  Future<Estabelecimento?> _carregaEstabelecimento() async {
    SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
    String? codEstabel = sharedPrefs.getString('estabelecimento');

    return await EstabelecimentoDAOImpl().carregarEstabelecimento(codEstabel!);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final _auth = context.read<AuthModel>();
    final double heightSizeToolbar = 70;

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
                    auth: _auth,
                    height: heightSizeToolbar,
                    width: width,
                    ordemView: ViewsController.instance.viewId,
                  ),
                ],
              )
            ],
          ),
          bottom: TabBar(
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.5),
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                child: Center(child: Text('Visita agendada', style: TextStyle(fontSize: 18.0))),
              ),
              Tab(
                child: Center(child: Text('Visita imprevista', style: TextStyle(fontSize: 18.0))),
              )
            ],
          ),
        ),
        drawer: AppDrawer(),
        body: Scaffold(
          resizeToAvoidBottomInset: false,
          body: TabBarView(controller: _tabController, children: [
            SingleChildScrollView(
              child: SafeArea(
                  bottom: true,
                  child: Column(
                    children: <Widget>[
                      Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Column(children: <Widget>[
                            Column(
                              children: [
                                Text(
                                  'Nova Visita Agendada',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 30,
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Selecione um Produtor ou Código da Propriedade'),
                              ],
                            ),
                            FutureBuilder<List<Propriedade>>(
                              future: _carregaPropriedades(),
                              builder: (context, listPropriedade) {
                                if (listPropriedade.hasData) {
                                  if (listPropriedade.data!.isNotEmpty) {
                                    return Autocomplete<Propriedade>(
                                      displayStringForOption: (Propriedade propriedade) => propriedade.codigoNomeProdutor!,
                                      initialValue: TextEditingValue(
                                          text: (GlobalData.produtorSelecionado == null || GlobalData.produtorSelecionado.codigoNomeProdutor == null)
                                              ? ""
                                              : "${GlobalData.produtorSelecionado.codigoNomeProdutor} - ${GlobalData.produtorSelecionado.codProdutor}"),
                                      optionsBuilder: (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text == '') {
                                          return const Iterable<Propriedade>.empty();
                                        }
                                        return listPropriedade.data!.where(
                                            (Propriedade propriedade) => (propriedade.codigoNomeProdutor)!.toLowerCase().toString().contains(textEditingValue.text.toLowerCase()));
                                      },
                                      onSelected: (Propriedade propriedade) async {
                                        propriedade = (await _carregaFullPropriedade(propriedade))!;
                                        setState(() {
                                          GlobalData.produtorSelecionado = propriedade;
                                        });
                                      },
                                    );
                                  } else {
                                    return Text('-- Nenhum Produtor --');
                                  }
                                } else {
                                  return LoaderFeedbackCow(
                                    mensagem: "Carregando produtores",
                                    size: 60,
                                  );
                                }
                              },
                            ),
                          ])),
                      (GlobalData.produtorSelecionado.codigoNomeProdutor == null)
                          ? Text("Selecione um Produtor ou Código da Propriedade")
                          : Visibility(
                              visible: (GlobalData.produtorSelecionado.codigoNomeProdutor == null) ? false : true, // tratar condicional de visualização
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                child: FutureBuilder<List<Map<Visita, Questionario>>>(
                                  future: _carregaQuestionarioPorVisitaProdutor(_auth.user!, GlobalData.produtorSelecionado, 0),
                                  builder: (context, listQuestionarios) {
                                    if (listQuestionarios.hasData) {
                                      if (listQuestionarios.data!.isNotEmpty) {
                                        return Column(children: <Widget>[
                                          Row(
                                            children: [
                                              Text('Selecione um Questionário'),
                                            ],
                                          ),
                                          ListView.builder(
                                            physics: const ScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: listQuestionarios.data?.length,
                                            itemBuilder: ((context, index) {
                                              final visita = (listQuestionarios.data?[index].keys.toList())?[0];
                                              final linha = (listQuestionarios.data?[index].values.toList())?[0];

                                              return _cardListQuestionario(
                                                  FormularioScreen(
                                                    visita: visita!,
                                                    questionario: linha!,
                                                    propriedade: GlobalData.produtorSelecionado,
                                                  ),
                                                  _auth);
                                            }),
                                          ),
                                        ]);
                                      } else {
                                        return Card(
                                            child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Text(
                                            'Não há visitas agendadas para este produtor.\nConsulte o Relatório de Visitas.',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ));
                                      }
                                    } else {
                                      return LoaderFeedbackCow(
                                        mensagem: "Carregando Questionários",
                                        size: 60,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                    ],
                  )),
            ),
            SingleChildScrollView(
              child: SafeArea(
                  bottom: true,
                  child: Column(
                    children: <Widget>[
                      Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: Column(children: <Widget>[
                            Column(
                              children: [
                                Text(
                                  'Nova Visita Imprevista',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 30,
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text('Selecione um Produtor ou Código da Propriedade'),
                              ],
                            ),
                            FutureBuilder<List<Propriedade>>(
                              future: _carregaPropriedades(),
                              builder: (context, listPropriedade) {
                                if (listPropriedade.hasData) {
                                  if (listPropriedade.data!.isNotEmpty) {
                                    return Autocomplete<Propriedade>(
                                      displayStringForOption: (Propriedade propriedade) => propriedade.codigoNomeProdutor!,
                                      initialValue:
                                          TextEditingValue(text: (GlobalData.produtorSelecionado.pessoa == null) ? "" : GlobalData.produtorSelecionado.codigoNomeProdutor!),
                                      optionsBuilder: (TextEditingValue textEditingValue) {
                                        if (textEditingValue.text == '') {
                                          return const Iterable<Propriedade>.empty();
                                        }
                                        return listPropriedade.data!.where(
                                            (Propriedade propriedade) => (propriedade.codigoNomeProdutor)!.toLowerCase().toString().contains(textEditingValue.text.toLowerCase()));
                                      },
                                      onSelected: (Propriedade propriedade) async {
                                        propriedade = (await _carregaFullPropriedade(propriedade))!;
                                        setState(() {
                                          GlobalData.produtorSelecionado = propriedade;
                                        });
                                      },
                                    );
                                  } else {
                                    return Text('-- Nenhum Produtor --');
                                  }
                                } else {
                                  return LoaderFeedbackCow(
                                    mensagem: "Carregando produtores",
                                    size: 60,
                                  );
                                }
                              },
                            ),
                          ])),
                      (GlobalData.produtorSelecionado == null)
                          ? Text("Selecione um Produtor ou Código da Propriedade")
                          : Visibility(
                              visible: (GlobalData.produtorSelecionado == null) ? false : true, // tratar condicional de visualização
                              child: Container(
                                color: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                child: FutureBuilder<List<Map<Visita, Questionario>>>(
                                  future: _carregaQuestionarioPorVisitaProdutor(_auth.user!, GlobalData.produtorSelecionado, 1),
                                  builder: (context, listQuestionarios) {
                                    if (listQuestionarios.hasData) {
                                      if (listQuestionarios.data!.isNotEmpty) {
                                        return Column(children: <Widget>[
                                          Row(
                                            children: [
                                              Text('Selecione um Questionário'),
                                            ],
                                          ),
                                          ListView.builder(
                                            physics: const ScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: listQuestionarios.data?.length,
                                            itemBuilder: ((context, index) {
                                              final linha = (listQuestionarios.data?[index].values.toList())?[0];

                                              return FutureBuilder<Estabelecimento?>(
                                                  future: _carregaEstabelecimento(),
                                                  builder: (context, estabelData) {
                                                    return _cardListQuestionario(
                                                        FormularioScreen(
                                                          visita: Visita(
                                                              idAppTecnico: HashGenerator().geradorSha1Random(linha!.id.toString()),
                                                              nrVisita: null,
                                                              dataInicio: DateTime.now(),
                                                              // estabelecimento: estabelData.data,
                                                              estabelecimento: GlobalData.estabelecimentoSelecionado ?? estabelData.data,
                                                              propriedade: GlobalData.produtorSelecionado,
                                                              questionario: linha,
                                                              observacoes: "",
                                                              recomendacoes: "",
                                                              statusVisita: "EM ABERTO",
                                                              dataCriacao: DateTime.now(),
                                                              existente: true,
                                                              novo: true,
                                                              agendado: false,
                                                              finalizado: false,
                                                              dataHoraIU: DateTime.now()),
                                                          questionario: linha,
                                                          propriedade: GlobalData.produtorSelecionado,
                                                        ),
                                                        _auth);
                                                  });
                                            }),
                                          )
                                        ]);
                                      } else {
                                        return Card(
                                            child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Text(
                                            'Não há visitas agendadas para este produtor.\nConsulte o Relatório de Visitas.',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ));
                                      }
                                    } else {
                                      return LoaderFeedbackCow(
                                        mensagem: "Carregando Questionários",
                                        size: 60,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                    ],
                  )),
            ),
          ]),
        ),
        bottomNavigationBar: FooterScreens(
          views: _propsView,
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
      ),
    );
  }

  Widget _cardListQuestionario(FormularioScreen formularioScreen, AuthModel auth) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: (formularioScreen.visita?.idAppTecnico == null)
                ? CircleAvatar(
                    child: Icon(Icons.new_label_sharp),
                  )
                : Column(
                    children: [
                      if (formularioScreen.visita?.nrVisita != null)
                        Column(
                          children: [
                            Text("Visita"),
                            CircleAvatar(
                              child: Text(
                                formularioScreen.visita!.nrVisita!.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
            title: Text(
              formularioScreen.questionario!.descricao.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              children: <Widget>[
                Row(children: <Widget>[
                  if (formularioScreen.visita?.idAppTecnico != null)
                    Row(
                      children: [
                        Text('Data Visita: '),
                        Text(
                          DateFormat('dd/MM/yyyy').format(formularioScreen.visita!.dataCriacao!),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                ]),
                Row(
                  children: <Widget>[
                    Text('Valid.: '),
                    Row(children: [
                      Text(
                        "${DateFormat('dd/MM/yy').format(DateTime.parse(formularioScreen.questionario!.dataInicio!))} até ${DateFormat('dd/MM/yy').format(DateTime.parse(formularioScreen.questionario!.dataFim!))}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ]),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text('Status: '),
                    Text(
                      formularioScreen.visita!.statusVisita!,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ],
            ),
            trailing: CircleAvatar(child: Icon(Icons.question_answer)),
            onTap: () async {
              if (formularioScreen.visita?.statusVisita == "FINALIZADO") {
                return dialog2Opt(context, "Cancelar", "Continuar", "Consulta Respostas", "Esta visita está finalizada e está disponível apenas para consulta. Deseja continuar??",
                    "", formularioScreen);
              } else {
                return dialog2Opt(
                    context,
                    "Cancelar",
                    "Iniciar",
                    "Iniciar preenchimento de Questionário",
                    "Deseja iniciar o questionário ${formularioScreen.questionario?.descricao} para o produtor(a) ${formularioScreen.propriedade?.codigoNomeProdutor}?",
                    "",
                    formularioScreen);
              }
            },
          ),
        ],
      ),
    );
  }
}
