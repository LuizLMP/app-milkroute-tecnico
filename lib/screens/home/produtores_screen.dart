import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/connectivityController.dart';
import 'package:milkroute_tecnico/controller/viewsController.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/propriedade_dao_impl.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/screens/app/app_drawer.dart';
import 'package:milkroute_tecnico/screens/home/analises_produtor_screen.dart';
import 'package:milkroute_tecnico/screens/home/movimentos_produtor_screen.dart';
import 'package:milkroute_tecnico/screens/home/notasfiscais_screen.dart';
import 'package:milkroute_tecnico/screens/home/select_formulario_screen.dart';
import 'package:milkroute_tecnico/widgets/dialogs.dart';
import 'package:milkroute_tecnico/widgets/footer_screen.dart';
import 'package:milkroute_tecnico/widgets/header_screens.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:provider/provider.dart';

class ProdutoresScreen extends StatefulWidget {
  const ProdutoresScreen({super.key});

  @override
  State<ProdutoresScreen> createState() => _ProdutoresScreenState();
}

class _ProdutoresScreenState extends State<ProdutoresScreen> {
  final ViewsController _propsView = ViewsController();
  Propriedade propriedadeSelecionada = Propriedade();
  ScrollController? _scrollController;

  Future<List<Propriedade>> _carregaListaPropriedade() async {
    var list = await PropriedadeDAOImpl()
        .selectSimple(Propriedade(), TipoConsultaDB.Tudo);

    return list.toList();
  }

  Future<Propriedade> _carregaDadosPropriedade(Propriedade propriedade) async {
    Propriedade propriedadeLoader;

    List<Propriedade> returnListPropriedade =
        await PropriedadeDAOImpl().selectAll(propriedade, TipoConsultaDB.PorPK);

    propriedadeLoader = returnListPropriedade[0];

    return propriedadeLoader;
  }

  @override
  void initState() {
    _scrollController = ScrollController();

    super.initState();
  }

  void _scrollToFocus() {
    _scrollController?.animateTo(135,
        duration: const Duration(seconds: 1), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final _auth = context.read<AuthModel>();
    final _conn = context.watch<ConnectivityProvider>();

    final double heightSizeToolbar = 70;
    final double bordaDisplay =
        (MediaQuery.of(context).size.width < 450) ? 0.25 : 0.1;
    final double larguraDisplay = MediaQuery.of(context).size.width -
        (MediaQuery.of(context).size.width * bordaDisplay);

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
              icon: Icon(
                Icons.settings,
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
        ),
        drawer: AppDrawer(),
        body: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            controller: _scrollController,
            child: SafeArea(
                bottom: true,
                child: Column(
                  children: <Widget>[
                    Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: Column(children: <Widget>[
                          Column(
                            children: [
                              Text(
                                'Consulta de Produtores',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 30,
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                  'Selecione um Produtor ou Código Propriedade'),
                            ],
                          ),
                          FutureBuilder<List<Propriedade>>(
                            future: _carregaListaPropriedade(),
                            builder: (context, listPropriedades) {
                              if (listPropriedades.hasData) {
                                if (listPropriedades.data!.isNotEmpty) {
                                  return Autocomplete<Propriedade>(
                                    displayStringForOption:
                                        (Propriedade propriedade) =>
                                            propriedade.codigoNomeProdutor!,
                                    initialValue: TextEditingValue(
                                        text: (GlobalData.produtorSelecionado
                                                    .pessoa ==
                                                null)
                                            ? ""
                                            : GlobalData.produtorSelecionado
                                                .codigoNomeProdutor!),
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<
                                            Propriedade>.empty();
                                      }
                                      return listPropriedades.data!.where(
                                          (Propriedade propriedade) =>
                                              (propriedade.codigoNomeProdutor)!
                                                  .toLowerCase()
                                                  .toString()
                                                  .contains(textEditingValue
                                                      .text
                                                      .toLowerCase()));
                                    },
                                    onSelected: (Propriedade propriedade) {
                                      setState(() {
                                        propriedadeSelecionada = propriedade;
                                        GlobalData.produtorSelecionado =
                                            propriedade;
                                        _scrollToFocus();
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
                    (propriedadeSelecionada.codigoNomeProdutor == null)
                        ? Text("Selecione um produtor")
                        : Visibility(
                            visible: (propriedadeSelecionada
                                        .codigoNomeProdutor ==
                                    null)
                                ? false
                                : true, // tratar condicional de visualização
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                  color: LightColors.kDarkBlue,
                                ),
                                margin: const EdgeInsets.all(4),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                child: Column(
                                  children: [
                                    FutureBuilder<Propriedade>(
                                        future: _carregaDadosPropriedade(
                                            propriedadeSelecionada),
                                        builder: (context, propriedade) {
                                          if (propriedade.hasData &&
                                              propriedade.data != null) {
                                            Propriedade? propriedadeSelect =
                                                propriedade.data;

                                            return Container(
                                              child: Column(children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 4, 0, 4),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            propriedadeSelect!
                                                                .pessoa!
                                                                .nomeFantasia!,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 20.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Text(
                                                            "${propriedadeSelect.pessoa?.cidade?.nome}/${propriedadeSelect.pessoa?.cidade?.estado?.sigla}",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14.0,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    2, 4, 2, 4),
                                                            child: Column(
                                                                children: [
                                                                  Container(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              4,
                                                                          bottom:
                                                                              4),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          blockDadosFormProdutor(
                                                                              "Endereço",
                                                                              [
                                                                                {
                                                                                  "Logradouro: ": propriedadeSelect.pessoa?.endereco ?? ""
                                                                                },
                                                                                {
                                                                                  "Número:": propriedadeSelect.pessoa?.numero ?? ""
                                                                                },
                                                                                {
                                                                                  "Bairro: ": propriedadeSelect.pessoa?.bairro ?? ""
                                                                                },
                                                                                {
                                                                                  "Complemento: ": propriedadeSelect.pessoa?.complemento ?? ""
                                                                                },
                                                                                {
                                                                                  "Cidade / UF: ": propriedadeSelect.pessoa?.cidade != null ? "${propriedadeSelect.pessoa!.cidade!.nome} / ${propriedadeSelect.pessoa!.cidade!.estado?.sigla ?? ''}" : ""
                                                                                },
                                                                                {
                                                                                  "CEP: ": propriedadeSelect.pessoa?.cep ?? ""
                                                                                },
                                                                                {
                                                                                  "Referencia: ": propriedadeSelect.pessoa?.pontoReferencia ?? ""
                                                                                },
                                                                              ]),
                                                                          blockDadosFormProdutor(
                                                                              "Contato",
                                                                              [
                                                                                {
                                                                                  "E-mail: ": propriedadeSelect.pessoa?.email ?? ""
                                                                                },
                                                                                {
                                                                                  "Telefone:": propriedadeSelect.pessoa?.telefone ?? ""
                                                                                },
                                                                                {
                                                                                  "Celular: ": propriedadeSelect.pessoa?.celular ?? ""
                                                                                },
                                                                                {
                                                                                  "Telefone Com.: ": propriedadeSelect.pessoa?.telefoneComercial ?? ""
                                                                                },
                                                                              ]
                                                                            ),
                                                                          blockDadosFormProdutor(
                                                                              "Propriedade",
                                                                              [
                                                                                {
                                                                                  "Matrícula: ": propriedadeSelect.codProdutor.toString()
                                                                                },
                                                                                {
                                                                                  "Nome Prop.: ": propriedadeSelect.nomePropriedade!
                                                                                },
                                                                                {
                                                                                  "Data Cadastro: ": GlobalData().convertDateToCast(IdiomaData.EnUS, DateFormat("yyyy-MM-dd").format(DateTime.parse(propriedadeSelect.dataCadastro!)).toString())
                                                                                },
                                                                              ]),
                                                                        ],
                                                                      )),
                                                                ]),
                                                          ),
                                                          Container(
                                                            child: Column(
                                                              children: <Widget>[
                                                                ButtonBar(
                                                                  alignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    (propriedadeSelect.latitude !=
                                                                                null &&
                                                                            propriedadeSelect.longitude !=
                                                                                null)
                                                                        ? SizedBox(
                                                                            width:
                                                                                larguraDisplay,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: colorScheme.secondary,
                                                                                shadowColor: Colors.white38,
                                                                              ),
                                                                              onPressed: () => MapsLauncher.launchCoordinates(propriedadeSelect.latitude!, propriedadeSelect.longitude!, 'Google Headquarters are here'),
                                                                              child: buttonOpcaoLayout(Icon(Icons.pin_drop, color: colorScheme.onPrimary,), "Propriedade"),
                                                                            ),
                                                                          )
                                                                        : SizedBox(
                                                                            width:
                                                                                larguraDisplay / 3,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: colorScheme.secondary,
                                                                                shadowColor: Colors.red,
                                                                              ),
                                                                              onPressed: () => {
                                                                                dialogInfo(context, "Continuar", Text("Localidade indisponível"), Text("As coordenadas da propriedade não estão disponíveis para visualização no Maps"))
                                                                              },
                                                                              child: buttonOpcaoLayout(Icon(Icons.block), "Propriedade"),
                                                                            ),
                                                                          ),
                                                                  ],
                                                                ),
                                                                (_conn.state ==
                                                                        ConnectivityResult
                                                                            .none)
                                                                    ? ButtonBar(
                                                                        alignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                larguraDisplay,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: colorScheme.secondary.withOpacity(0.8),
                                                                                shadowColor: Colors.white38,
                                                                              ),
                                                                              onPressed: () async => null,
                                                                              child: buttonOpcaoLayout(
                                                                                Icon(Icons.wifi_off),
                                                                                "Movimentos",
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : ButtonBar(
                                                                        alignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                larguraDisplay,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: colorScheme.secondary,
                                                                                shadowColor: Colors.white38,
                                                                              ),
                                                                              onPressed: () async => await Navigator.of(context).push(MaterialPageRoute(
                                                                                  builder: (context) => MovimentosProdutorScreen(
                                                                                        user: _auth.user!,
                                                                                        propriedade: propriedadeSelect,
                                                                                      ))),
                                                                              child: buttonOpcaoLayout(
                                                                                Icon(Icons.clean_hands_rounded, color: colorScheme.onPrimary,),
                                                                                "Movimentos",
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                (_conn.state ==
                                                                        ConnectivityResult
                                                                            .none)
                                                                    ? ButtonBar(
                                                                        alignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                larguraDisplay,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: colorScheme.secondary.withOpacity(0.8),
                                                                                shadowColor: Colors.white38,
                                                                              ),
                                                                              onPressed: () async => null,
                                                                              child: buttonOpcaoLayout(
                                                                                Icon(Icons.wifi_off),
                                                                                "Análises",
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : ButtonBar(
                                                                        alignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                larguraDisplay,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: colorScheme.secondary,
                                                                                shadowColor: Colors.white38,
                                                                              ),
                                                                              onPressed: () async => await Navigator.of(context).push(MaterialPageRoute(
                                                                                  builder: (context) => AnalisesProdutorScreen(
                                                                                        user: _auth.user!,
                                                                                        propriedade: propriedadeSelect,
                                                                                      ))),
                                                                              child: buttonOpcaoLayout(
                                                                                Icon(Icons.clean_hands_rounded, color: colorScheme.onPrimary,),
                                                                                "Análises",
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                (_conn.state ==
                                                                        ConnectivityResult
                                                                            .none)
                                                                    ? ButtonBar(
                                                                        alignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                larguraDisplay,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: colorScheme.secondary.withOpacity(0.8),
                                                                                shadowColor: Colors.white38,
                                                                              ),
                                                                              onPressed: () async => null,
                                                                              child: buttonOpcaoLayout(
                                                                                Icon(Icons.wifi_off),
                                                                                "Notas Fiscais",
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    : ButtonBar(
                                                                        alignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          SizedBox(
                                                                            width:
                                                                                larguraDisplay,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                backgroundColor: colorScheme.secondary,
                                                                                shadowColor: Colors.white38,
                                                                              ),
                                                                              onPressed: () async => await Navigator.of(context).push(MaterialPageRoute(
                                                                                  builder: (context) => NotasFiscaisScreen(
                                                                                        user: _auth.user!,
                                                                                        propriedade: propriedadeSelect,
                                                                                      ))),
                                                                              child: buttonOpcaoLayout(
                                                                                Icon(Icons.sell, color: colorScheme.onPrimary,),
                                                                                "Notas Fiscais",
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                ButtonBar(
                                                                  alignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    SizedBox(
                                                                      width:
                                                                          larguraDisplay,
                                                                      child:
                                                                          ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              colorScheme.secondary,
                                                                          shadowColor:
                                                                              Colors.white38,
                                                                        ),
                                                                        onPressed: () async => await Navigator.of(context).push(MaterialPageRoute(
                                                                            builder: (context) => SelectFormularioScreen(
                                                                                  propriedade: propriedadeSelect,
                                                                                ))),
                                                                        child:
                                                                            buttonOpcaoLayout(
                                                                          Icon(Icons
                                                                              .calendar_today, color: colorScheme.onPrimary,),
                                                                          "Nova Visita",
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                            );
                                          } else {
                                            return Text(
                                                "Dados do produtor não disponíveis");
                                          }
                                        }),
                                  ],
                                )),
                          ),
                  ],
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

  Widget blockWidgetProdutor(
      String titulo, List<Map<String, Widget>> widgetGraficos) {
    final widthBlock = (MediaQuery.of(context).size.width -
        (MediaQuery.of(context).size.width * 0.135));

    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      width: widthBlock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (titulo != null && titulo != "")
            Text(
              titulo,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          Row(
            children: <Widget>[
              for (final linha in widgetGraficos)
                if (linha.values.first != null)
                  Row(children: [
                    linha.values.first,
                  ]),
            ],
          )
        ],
      ),
    );
  }

  Widget blockDadosFormProdutor(
      String titulo, List<Map<String, String>> campos) {
    return Container(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          for (final linha in campos)
            if (linha.values.first != null)
              linhaDadosFormProdutor(
                  linha.keys.first.toString(), linha.values.first.toString())
        ],
      ),
    );
  }

  Widget linhaDadosFormProdutor(String rotulo, String valorRotulo) {
    final TextStyle _textStyleLabel = TextStyle(color: Colors.white);
    final TextStyle _textStyleAnswer =
        TextStyle(color: Colors.white, fontWeight: FontWeight.bold);

    return Row(children: [
      Text(
        rotulo,
        style: _textStyleLabel,
      ),
      Text(
        valorRotulo,
        style: _textStyleAnswer,
      )
    ]);
  }

  Widget buttonOpcaoLayout(Icon icone, String descricao) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          icone,
          Text(
            descricao,
            style: TextStyle(color: Colors.white, fontSize: 12),
          )
        ],
      ),
    ));
  }
}
