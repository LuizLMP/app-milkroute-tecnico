import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/viewsController.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/resposta_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/visita_dao_impl.dart';
import 'package:milkroute_tecnico/screens/home/home_screen.dart';
import 'package:milkroute_tecnico/services/pdf_services.dart';
import 'package:milkroute_tecnico/utils.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:milkroute_tecnico/screens/app/app_drawer.dart';
import 'package:milkroute_tecnico/screens/home/conferir_respostas_screen.dart';
import 'package:milkroute_tecnico/widgets/dialogs.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:milkroute_tecnico/widgets/question_constructor.dart';

class FormularioScreen extends StatefulWidget {
  const FormularioScreen(
      {super.key, this.visita, this.questionario, this.propriedade});

  final Visita? visita;
  final Questionario? questionario;
  final Propriedade? propriedade;

  @override
  _FormularioScreenState createState() => _FormularioScreenState();
}

class _FormularioScreenState extends State<FormularioScreen>
    with TickerProviderStateMixin {
  String? valProdutoSelecionado;
  final ViewsController _propsView = ViewsController();
  // FormsController _formsController = FormsController();
  Resposta? resposta;
  TabController? _tabController;
  ScrollController? _scrollController;

  Future<Resposta> _carregaRespostaPorQuestionario(
      Visita visita, Questionario questionario) async {
    List<Resposta> resposta;

    Visita consultaVisitaDB =
        await VisitaDAOImpl().carregarVisita(visita.idAppTecnico!);

    if (visita.idAppTecnico == null || consultaVisitaDB.idAppTecnico == null) {
      visita = await VisitaDAOImpl().insert(visita);
    }

    resposta = await RespostaDAOImpl().selectAll(
        Resposta(visita: visita, questionario: questionario),
        TipoConsultaDB.PorVisita);

    if (resposta.isEmpty) {
      String hashResposta =
          HashGenerator().geradorSha1Random(questionario.id.toString());

      var idResposta = await RespostaDAOImpl().insert(Resposta(
          idAppTecnico: hashResposta,
          questionario: questionario,
          dataCriacao: DateTime.now(),
          dataHoraIU: DateTime.now(),
          visita: visita));

      resposta = await RespostaDAOImpl()
          .selectAll(Resposta(idAppTecnico: idResposta), TipoConsultaDB.PorPK);
    }

    return resposta[0];
  }

  @override
  void initState() {
    _scrollController = ScrollController();

    _tabController = TabController(
        length: (widget.questionario!.listCategorias!.length + 2), vsync: this);

    super.initState();
  }

  // void _scrollToTop() {
  //   _scrollController.animateTo(100, duration: const Duration(seconds: 1), curve: Curves.linear);
  // }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visitaWidget = (widget.visita == null) ? Visita() : widget.visita;
    final bool blockVisitaFinalizada =
        (visitaWidget?.statusVisita == "FINALIZADO") ? true : false;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: LightColors.kDarkBlue,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
          elevation: 0.0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 30.0),
            onPressed: () {
              dialog2Opt(
                context,
                "Voltar",
                "Sair do Formulário",
                "Deseja sair do formulário de visita?",
                "Seus dados estão salvos e voce pode continuar mais tarde!",
                "",
                HomeScreen(restorationId: '1'),
              );
            },
          ),
          actions: <Widget>[],
          title: Stack(
            children: [
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 0.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Visita()
                              .setColorVisita(widget.visita!.statusVisita!),
                          radius: 17.0,
                          child: Text(
                            widget.questionario!.id.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0.0),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.questionario!.descricao!,
                                style: TextStyle(fontSize: 18.0)),
                            Text(widget.propriedade!.codigoNomeProdutor!,
                                style: TextStyle(fontSize: 14.0)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Visibility(
                visible:
                    (visitaWidget?.statusVisita == "FINALIZADO") ? true : false,
                child: Positioned(
                  top: -7,
                  right: 0,
                  child: ElevatedButton(
                    onPressed: () async {
                      final String nomeArquivo =
                          "Relatório de Visita (${widget.propriedade?.codProdutor} - ${widget.propriedade!.pessoa!.nomeRazaoSocial} [${DateFormat("dd-MM-yyyy").format(widget.visita!.dataFinalizacao!)}]";

                      PDFScreen pdf = await PDFService()
                          .getRelatorioVisitaPDF(widget.visita!, nomeArquivo);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => pdf,
                          ));
                    },
                    child: CircleAvatar(
                        backgroundColor: colorScheme.primary,
                        radius: 20.0,
                        child: Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.white,
                        )),
                  ),
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.5),
            tabs: <Widget>[
              Tab(
                child: Center(
                    child: Text("Vamos começar?",
                        style: TextStyle(fontSize: 18.0))),
              ),
              for (final tab in widget.questionario!.listCategorias!)
                Tab(
                  child: Center(
                      child: Text(tab.descricao!,
                          style: TextStyle(fontSize: 18.0))),
                ),
              Tab(
                child: Center(
                    child: Text("Finalizar", style: TextStyle(fontSize: 18.0))),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: _scrollToTop,
        //   child: const Icon(Icons.keyboard_double_arrow_up_rounded),
        // ),
        drawer: AppDrawer(),
        body: FutureBuilder<Resposta>(
            future: _carregaRespostaPorQuestionario(
                visitaWidget!, widget.questionario!),
            builder: (context, resposta) {
              if (resposta.hasData) {
                if (resposta.data != null) {
                  return Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: TabBarView(controller: _tabController, children: [
                      SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(children: [
                          ListTile(
                            title: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Recomendações:",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (visitaWidget.recomendacoes != null)
                                    Text(visitaWidget.recomendacoes.toString())
                                  else
                                    Text("Sem recomendações"),
                                ]),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Observações:",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (visitaWidget.observacoes != null)
                                    Text(visitaWidget.observacoes.toString())
                                  else
                                    Text("Sem observações"),
                                ]),
                              ),
                            ),
                          ),
                          ListTile(
                            trailing: ElevatedButton(
                              child: Icon(Icons.arrow_forward_ios_rounded),
                              onPressed: () => _tabController
                                  ?.animateTo((_tabController!.index + 1)),
                            ),
                          ),
                        ]),
                      ),
                      for (final categoria
                          in widget.questionario!.listCategorias!)
                        SingleChildScrollView(
                          controller: _scrollController,
                          child: Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 10.0, left: 10.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "(*) Pergunta obrigatória",
                                      style: TextStyle(fontSize: 12.0,
                                          color: colorScheme.primary),
                                    ),
                                    Divider(
                                      color: colorScheme.primary,
                                    ),
                                    for (final pergunta
                                        in categoria.listPerguntas!)
                                      Visibility(
                                          visible: pergunta.ativa!,
                                          child: Container(
                                            child: QuestionConstructor(
                                              pergunta: pergunta,
                                              resposta: resposta.data!,
                                              blockPergunta:
                                                  blockVisitaFinalizada,
                                            ),
                                          )),
                                    ListTile(
                                      leading: ElevatedButton(
                                        child:
                                            Icon(Icons.arrow_back_ios_rounded),
                                        onPressed: () =>
                                            _tabController?.animateTo(
                                                (_tabController!.index - 1)),
                                      ),
                                      trailing: ElevatedButton(
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded),
                                        onPressed: () =>
                                            _tabController?.animateTo(
                                                (_tabController!.index + 1)),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                      SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: _carregaRespostaPorQuestionario(
                                  visitaWidget, widget.questionario!),
                              builder: ((context, resposta) {
                                if (resposta.hasData) {
                                  if (resposta != null) {
                                    return ConferirRespostas(
                                        questionario: widget.questionario,
                                        resposta: resposta.data,
                                        blockRespostas: blockVisitaFinalizada);
                                  } else {
                                    return Card(
                                        child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text(
                                        'Não há respostas a serem exibidas.',
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
                              }),
                            ),
                            ListTile(
                              leading: ElevatedButton(
                                child: Icon(Icons.arrow_back_ios_rounded),
                                onPressed: () => _tabController
                                    ?.animateTo((_tabController!.index - 1)),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
                  );
                } else {
                  return Card(
                      child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Não há perguntas a seres respondidas.\nConsulte seu estabelecimento para regularização.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ));
                }
              } else {
                return Scaffold(
                  backgroundColor: LightColors.kLightBlue,
                  body: LoaderFeedbackCow(
                    mensagem: "Carregando Questionários",
                    size: 60,
                  ),
                );
              }
            }),
        //
      ),
    );
  }
}
