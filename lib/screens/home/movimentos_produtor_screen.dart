import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/movimento_produtor_dao_impl.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/movimento_leite.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/services/propriedade_service.dart';
import 'package:milkroute_tecnico/widgets/dialogs.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import "package:collection/collection.dart";
import 'package:fl_chart/fl_chart.dart';

class MovimentosProdutorScreen extends StatefulWidget {
  const MovimentosProdutorScreen({super.key, this.user, this.propriedade});

  final User? user;
  final Propriedade? propriedade;

  @override
  _MovimentosProdutorScreenState createState() =>
      _MovimentosProdutorScreenState();
}

class _MovimentosProdutorScreenState extends State<MovimentosProdutorScreen>
    with TickerProviderStateMixin {
  PropriedadeService apiProp = PropriedadeService();
  final totalPeriodo = ValueNotifier<String>("0L");
  final mediaMes = ValueNotifier<String>("0L");
  final totalPeriodoBenef = ValueNotifier<String>("0L");
  final mediaMesBenef = ValueNotifier<String>("0L");
  TabController? _tabController;

  final RestorableInt tabIndex = RestorableInt(0);

  Future<bool> carregarMovimentosProdutores(
      User user, Propriedade propriedade) async {
    try {
      List<MovimentoLeiteProdutor> listMovimentosLeite =
          await apiProp.getMovimentoLeiteProdutor(
              propriedade.codProdutor.toString(), user.token!, user.empresa!);

      for (var movimentoLeite in listMovimentosLeite) {
        await MovimentoLeiteProdutorDAOImpl().insert(movimentoLeite);
      }

      return true;
    } catch (ex) {
      print(
          "Erro carregarMovimentosProdutores: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Propriedade? propriedade = widget.propriedade;

    // Se "verGraficos" for TRUE, mostra os gráficos abaixo dos cards de quantidades diárias
    bool verGraficos = false;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: Colors.white),
          toolbarHeight: 70,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(propriedade!.pessoa!.nomeRazaoSocial!,
                    style: TextStyle(fontSize: 25.0, color: Colors.white)),
                if (propriedade.nomePropriedade != null)
                  Text(
                    "${propriedade.codProdutor} - ${propriedade.nomePropriedade}",
                    style: TextStyle(fontSize: 12.0, color: Colors.white),
                  ),
                Text(
                  'Período: ${DateFormat.yM('pt_BR').format(GlobalData.periodo)}',
                  style: TextStyle(fontSize: 12.0, color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.filter_list,  color: Colors.white),
                onPressed: () {
                  _showDatePicker(context);
                }),
            // IconButton(
            //   icon: Icon(Icons.close),
            //   onPressed: () async {
            //     await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProdutoresScreen()));
            //   },
            // )
          ],
          bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: true,
              tabs: <Widget>[
                Tab(
                  child: Center(
                      child: Text('Coletas detalhadas',
                          style: TextStyle(fontSize: 18.0))),
                ),
                Tab(
                  child: Center(
                      child: Text('Resumo por produtor',
                          style: TextStyle(fontSize: 18.0))),
                ),
              ]),
        ),
        body: FutureBuilder(
          future:
              carregarMovimentosProdutores(widget.user!, widget.propriedade!),
          builder: (context, returnCarregarMovimentosProdutores) {
            if (returnCarregarMovimentosProdutores.hasData) {
              if (returnCarregarMovimentosProdutores.data!) {
                return TabBarView(controller: _tabController, children: [
                  ListView(children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Container(
                            child: Column(
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Card(
                                shadowColor: Colors.blue,
                                child: Stack(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Total período"),
                                            ValueListenableBuilder(
                                                valueListenable: totalPeriodo,
                                                builder:
                                                    (context, value, widget) {
                                                  return Text(
                                                      totalPeriodo.value,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 22.0));
                                                })
                                          ],
                                        ))
                                  ],
                                ),
                              )),
                              Expanded(
                                  child: Card(
                                shadowColor: Colors.blue,
                                child: Stack(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Média diária"),
                                            ValueListenableBuilder(
                                                valueListenable: mediaMes,
                                                builder:
                                                    (context, value, widget) {
                                                  return Text(mediaMes.value,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 22.0));
                                                })
                                          ],
                                        ))
                                  ],
                                ),
                              )),
                            ]),
                            Visibility(
                              visible: widget.propriedade!.possuiBeneficiario!,
                              child: Row(children: [
                                Expanded(
                                    child: Card(
                                  shadowColor: Colors.blue,
                                  child: Stack(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Total beneficiários",
                                                style:
                                                    TextStyle(fontSize: 11.0),
                                              ),
                                              ValueListenableBuilder(
                                                  valueListenable:
                                                      totalPeriodoBenef,
                                                  builder:
                                                      (context, value, widget) {
                                                    return Text(
                                                        totalPeriodoBenef.value,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 18.0));
                                                  })
                                            ],
                                          ))
                                    ],
                                  ),
                                )),
                                Expanded(
                                    child: Card(
                                  shadowColor: Colors.blue,
                                  child: Stack(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Média diária beneficiários",
                                                style:
                                                    TextStyle(fontSize: 11.0),
                                              ),
                                              ValueListenableBuilder(
                                                  valueListenable:
                                                      mediaMesBenef,
                                                  builder:
                                                      (context, value, widget) {
                                                    return Text(
                                                        mediaMesBenef.value,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 18.0));
                                                  })
                                            ],
                                          ))
                                    ],
                                  ),
                                )),
                              ]),
                            )
                          ],
                        ))),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: FutureBuilder<List<MovimentoLeiteProdutor>>(
                          future: _gridLitrosDia(propriedade),
                          builder: (context, diasColeta) {
                            if (diasColeta.hasData) {
                              if (diasColeta.data!.isNotEmpty) {
                                return GridView.count(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.7,
                                    //childAspectRatio: 1.0,
                                    physics: const ScrollPhysics(),
                                    padding: const EdgeInsets.all(10.0),
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    children: List.generate(
                                        diasColeta.data!.length, (index) {
                                      final infoColeta =
                                          diasColeta.data![index];

                                      if (infoColeta.numeroDocumento ==
                                              propriedade
                                                  .pessoa?.numeroDocumento ||
                                          infoColeta.codProdutor ==
                                              propriedade.codProdutor) {
                                        return Container(
                                          child: Card(
                                            color: Colors.blue.shade50,
                                            margin: EdgeInsets.fromLTRB(
                                                5.0, 5.0, 5.0, 5.0),
                                            elevation: 2.0,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text('Dia '),
                                                      Text(
                                                        DateFormat('dd')
                                                            .format(infoColeta
                                                                .dataColeta!)
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text('Vol.: '),
                                                      Text(
                                                          NumberFormat.currency(
                                                                  decimalDigits:
                                                                      0,
                                                                  symbol: '',
                                                                  locale:
                                                                      'pt_BR')
                                                              .format(infoColeta
                                                                  .quantidade)
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          child: GestureDetector(
                                            onTap: (() {
                                              dialogInfo(
                                                context,
                                                "",
                                                Text(
                                                    "Dia ${DateFormat('dd/MM/yyyy').format(infoColeta.dataColeta!)}"),
                                                Text(
                                                    "Beneficiário ${infoColeta.nomePropriedade}"),
                                              );
                                            }),
                                            child: Card(
                                              color: Colors.green.shade100,
                                              margin: EdgeInsets.fromLTRB(
                                                  5.0, 5.0, 5.0, 5.0),
                                              elevation: 2.0,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text('Dia '),
                                                        Text(
                                                          DateFormat('dd')
                                                              .format(infoColeta
                                                                  .dataColeta!)
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  8, 0, 0, 0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .info_outline,
                                                                size: 12,
                                                                color:
                                                                    colorScheme
                                                                        .primary,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text('Vol.: '),
                                                        Text(
                                                            NumberFormat.currency(
                                                                    decimalDigits:
                                                                        0,
                                                                    symbol: '',
                                                                    locale:
                                                                        'pt_BR')
                                                                .format(infoColeta
                                                                    .quantidade)
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }));
                              } else {
                                return Card(
                                    child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Text(
                                    'Não há nenhuma coleta de leite no mês de ${DateFormat.y('pt_BR').format(GlobalData.periodo)}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ));
                              }
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Text('Carregando movimentos...'),
                                      SizedBox(height: 10),
                                      CircularProgressIndicator(
                                        color: colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          }),
                    ),
                    Visibility(
                      visible: true, // Adjust visibility as needed
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<List<MovimentoLeiteProdutor>>(
                          future: _gridLitrosDia(propriedade),
                          builder: (context, movtos) {
                            if (movtos.hasData && movtos.data!.isNotEmpty) {
                              return _buildBarChart(movtos.data!);
                            } else if (!movtos.hasData) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              return Text('No data available');
                            }
                          },
                        ),
                      ),
                    )
                  ]),
                  SingleChildScrollView(
                    child: SafeArea(
                      child: Column(children: [
                        Stack(
                          children: [
                            Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    // Padding(
                                    //   padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                                    //   child: Text(
                                    //     'Resumo por produtor',
                                    //     style: TextStyle(
                                    //         fontSize: 20.0,
                                    //         fontWeight: FontWeight.bold),
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(children: [
                                        FutureBuilder<
                                            List<MovimentoLeiteProdutor>>(
                                          future:
                                              _resumoPorProdutor(propriedade),
                                          builder: (context, listProdutores) {
                                            if (listProdutores.hasData) {
                                              if (listProdutores
                                                  .data!.isNotEmpty) {
                                                return Scrollbar(
                                                  child: ListView.builder(
                                                    physics:
                                                        const ScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    shrinkWrap: true,
                                                    itemCount: listProdutores
                                                        .data?.length,
                                                    itemBuilder:
                                                        ((context, index) {
                                                      final linha =
                                                          listProdutores
                                                              .data?[index];

                                                      return Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: <Widget>[
                                                          ListTile(
                                                            title: Text(
                                                              linha!
                                                                  .nomePropriedade!,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            subtitle: Column(
                                                              children: <Widget>[
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                        "Doct.: ${linha.numeroDocumento}")
                                                                  ],
                                                                ),
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          "${linha.quantidade}L",
                                                                          style: TextStyle(
                                                                              fontSize: 18.0,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black),
                                                                        )
                                                                      ],
                                                                    ))
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }),
                                                  ),
                                                );
                                              } else {
                                                return Card(
                                                    child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      18.0),
                                                  child: Text(
                                                    "Não há nenhum produtor a ser listado",
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                ));
                                              }
                                            } else {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(18.0),
                                                child: Center(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          'Carregando produtores'),
                                                      SizedBox(height: 10),
                                                      CircularProgressIndicator(
                                                        color:
                                                            colorScheme.primary,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ]),
                                    ),
                                    // print("TOTAL: " + totalPorProdutor.toString());
                                    // print("MEDIA: " + mediaPorProdutor.toString());
                                    // return Text('x');
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ]),
                    ),
                  ),
                ]);
              } else {
                return Card(
                    child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    'Não há dados de movimentos a serem exibidos para este produtor.',
                    style: TextStyle(fontSize: 20),
                  ),
                ));
              }
            } else {
              return LoaderFeedbackCow(
                mensagem: "Carregando Movimentos",
                size: 60,
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showMonthPicker(
        context: context,
        initialDate: GlobalData.periodo,
        firstDate: DateTime(2010, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != GlobalData.periodo) {
      setState(() {
        GlobalData.periodo = picked;
        GlobalData.firstDayCurrentMonth = DateTime(
            GlobalData.periodo.year, GlobalData.periodo.month, 1, 0, 0, 0);
        GlobalData.lastDayCurrentMonth = DateTime(GlobalData.periodo.year,
                GlobalData.periodo.month + 1, 1, 23, 59, 59)
            .subtract(Duration(days: 1));
      });
    }
  }

  Future<List<MovimentoLeiteProdutor>> _gridLitrosDia(
      Propriedade propriedade) async {
    List<MovimentoLeiteProdutor> movtos = await MovimentoLeiteProdutorDAOImpl()
        .selectAll(MovimentoLeiteProdutor(codProdutor: propriedade.codProdutor),
            TipoConsultaDB.PorPropriedade);

    movtos = movtos
        .where((element) =>
            element.dataColeta!.isAfter(GlobalData.firstDayCurrentMonth) &&
            element.dataColeta!.isBefore(GlobalData.lastDayCurrentMonth))
        .toList();

    movtos.sort((a, b) {
      return a.dataColeta!.compareTo(b.dataColeta!);
    });

    final total = movtos.fold<int>(0,
        (previousValue, element) => previousValue + (element.quantidade ?? 0));

    totalPeriodo.value = "${total}L";

    final diasNoPeriodo = GlobalData.lastDayCurrentMonth
        .difference(GlobalData.firstDayCurrentMonth)
        .inDays;
    final media = diasNoPeriodo > 0 ? (total / diasNoPeriodo).floor() : 0;

    mediaMes.value = "${media}L";

    return movtos.toList();
  }

  Widget _buildBarChart(List<MovimentoLeiteProdutor> movtos) {
    final barGroups = _createBarGroups(movtos);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < barGroups.length) {
                    return Text(
                      barGroups[value.toInt()].x.toString(),
                      style: TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(
      List<MovimentoLeiteProdutor> movtos) {
    var posIni = 0;
    if (movtos.isEmpty) return [];
    if (movtos.length > 4) posIni = movtos.length - 4;

    final data = movtos.getRange(posIni, movtos.length).map((movto) {
      return BarChartGroupData(
        x: movtos.indexOf(movto),
        barRods: [
          BarChartRodData(
            toY: movto.quantidade!.toDouble(),
            color: Colors.blue,
            width: 16,
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return data;
  }

  Future<List<MovimentoLeiteProdutor>> _resumoPorProdutor(
      Propriedade propriedade) async {
    List<MovimentoLeiteProdutor> listProdutorMovimentos = [];

    List<MovimentoLeiteProdutor> movtos = await MovimentoLeiteProdutorDAOImpl()
        .selectAll(MovimentoLeiteProdutor(codProdutor: propriedade.codProdutor),
            TipoConsultaDB.PorPropriedade);

    movtos = movtos
        .where((element) =>
            element.dataColeta!.isAfter(GlobalData.firstDayCurrentMonth) &&
            element.dataColeta!.isBefore(GlobalData.lastDayCurrentMonth))
        .toList();

    var totalPorProdutor =
        movtos.groupFoldBy((movto) => movto.numeroDocumento, (prev, elem) {
      var obj = {};

      if (prev == null) {
        obj.addAll({
          'numeroDocumento': elem.numeroDocumento,
          'nomePropriedade': elem.nomePropriedade,
          'totalMovimentos': elem.quantidade
        });
      } else {
        obj.addAll({
          'numeroDocumento': elem.numeroDocumento,
          'nomePropriedade': elem.nomePropriedade,
          'totalMovimentos': (elem.quantidade! +
              ((prev as Map<String, dynamic>)['totalMovimentos'] as int))
        });
      }
      prev = obj;

      return prev;
    });

    if (totalPorProdutor.isNotEmpty && totalPorProdutor.isNotEmpty) {
      for (var produtor in totalPorProdutor.values) {
        listProdutorMovimentos.add(MovimentoLeiteProdutor(
            nomePropriedade: (produtor
                as Map<dynamic, dynamic>)['nomePropriedade'] as String,
            numeroDocumento: produtor['numeroDocumento'] as String,
            quantidade: produtor['totalMovimentos'] as int));
      }
    }

    return listProdutorMovimentos;
  }
}

class OrdinalVolumes {
  final String periodo;
  final int quantidade;
  final double media;

  OrdinalVolumes(this.periodo, this.quantidade, this.media);
}
