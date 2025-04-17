import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/analise_produtor_dao_impl.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/analise_leite.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/services/propriedade_service.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalisesProdutorScreen extends StatefulWidget {
  const AnalisesProdutorScreen({super.key, this.user, this.propriedade});

  final User? user;
  final Propriedade? propriedade;

  @override
  _AnalisesProdutorScreenState createState() => _AnalisesProdutorScreenState();
}

class _AnalisesProdutorScreenState extends State<AnalisesProdutorScreen>
    with SingleTickerProviderStateMixin, RestorationMixin {
  TabController? _tabController;
  PropriedadeService apiProp = PropriedadeService();
  final RestorableInt tabIndex = RestorableInt(0);

  @override
  String get restorationId => 'tab_scrollable';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(tabIndex, 'tab_index');
    _tabController?.index = tabIndex.value;
  }

  Future<bool> carregarAnalisesProdutores(
      User user, Propriedade propriedade) async {
    try {
      List<AnaliseLeiteProdutor> listAnalisesLeite =
          await apiProp.getAnaliseLeiteProdutor(
              propriedade.codProdutor.toString(), user.token!, user.empresa!);

      for (AnaliseLeiteProdutor analiseLeite in listAnalisesLeite) {
        await AnaliseLeiteProdutorDAOImpl().insert(analiseLeite);
      }

      return true;
    } catch (ex) {
      print(
          "Erro carregarAnalisesProdutores: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 9, vsync: this);
    _tabController?.addListener(() {
      setState(() {
        tabIndex.value = _tabController!.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Propriedade? propriedade = widget.propriedade;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tabs = [
      TabQualidade('Gordura', TipoAnalise.Gordura),
      TabQualidade('Proteína', TipoAnalise.Proteina),
      TabQualidade('Sólidos Totais', TipoAnalise.SolidosTotais),
      TabQualidade('ESD', TipoAnalise.ESD),
      TabQualidade('CPP UFC/ml', TipoAnalise.CPP),
      TabQualidade('CCS/ml', TipoAnalise.CCS),
      TabQualidade('NU', TipoAnalise.NU),
      TabQualidade('Acidez', TipoAnalise.ACIDEZ),
      TabQualidade(
        'Crioscopia',
        TipoAnalise.CRI,
      ),
    ];

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            toolbarHeight: 90,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(propriedade!.pessoa!.nomeRazaoSocial!,
                    style: TextStyle(fontSize: 25.0)),
                // if (propriedade.nomePropriedade != null)
                Text(
                  "${propriedade.codProdutor} - ${(propriedade.nomePropriedade == null) ? 'Propriedade sem nome' : propriedade.nomePropriedade.toString()}",
                  style: TextStyle(fontSize: 12.0),
                ),
                Text(
                  'Período: ${DateFormat.yM('pt_BR').format(GlobalData.periodo)}',
                  style: TextStyle(fontSize: 12.0),
                ),
              ],
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.filter_list),
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
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.5),
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  for (final tab in tabs)
                    Tab(
                      child: Center(
                          child: Text(tab.analise,
                              style: TextStyle(fontSize: 18.0))),
                    )
                ])),
        body: FutureBuilder(
            future:
                carregarAnalisesProdutores(widget.user!, widget.propriedade!),
            builder: ((context, returnCarregarAnalisesProdutores) {
              if (returnCarregarAnalisesProdutores.hasData) {
                if (returnCarregarAnalisesProdutores.data!) {
                  return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: FutureBuilder<List<AnaliseLeiteProdutor>>(
                          future: getAnaliseLeiteProdutor(propriedade),
                          builder: (context, analisesList) {
                            if (!analisesList.hasData) {
                              return Center(child: CircularProgressIndicator());
                            } else {
                              return TabBarView(
                                  controller: _tabController,
                                  children: [
                                    for (final tab in tabs)
                                      _buildTab(tab, analisesList.data!)
                                  ]);
                            }
                          }));
                } else {
                  return Card(
                      child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      'Não há dados de análises a serem exibidos para este produtor.',
                      style: TextStyle(fontSize: 20),
                    ),
                  ));
                }
              } else {
                return LoaderFeedbackCow(
                  mensagem: "Carregando Análises",
                  size: 60,
                );
              }
            })),
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

  Widget _buildTab(TabQualidade tab, List<AnaliseLeiteProdutor> movtos) {
    final barGroups = _createBarGroups(movtos, tab.tipoAnalise);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 350.0,
          height: 300.0,
          child: BarChart(
            BarChartData(
              maxY: _calculateMaxY(movtos, tab.tipoAnalise),
              minY: _calculateMinY(movtos, tab.tipoAnalise),
              barGroups: barGroups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(fontSize: 12, color: colorScheme.primary),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < movtos.length) {
                        final data = movtos[value.toInt()].data;
                        if (data != null) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${DateFormat('MMM/yy', 'pt_BR').format(data)}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black87),
                            ),
                          );
                        }
                      }
                      return Text(
                          ''); // Retorna um texto vazio se não houver data
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey[300]!,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: removeBg,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 0,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toStringAsFixed(3),
                      TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(
      List<AnaliseLeiteProdutor> movtos, TipoAnalise tpAnalise) {
    if (movtos.isEmpty) return [];

    // Filtra apenas os últimos 4 itens
    final recentMovtos =
        movtos.length > 4 ? movtos.sublist(movtos.length - 4) : movtos;

    final data = recentMovtos.map((movto) {
      double value;
      switch (tpAnalise) {
        case TipoAnalise.Proteina:
          value = movto.proteina ?? 0.0;
          break;
        case TipoAnalise.Gordura:
          value = movto.gordura ?? 0.0;
          break;
        case TipoAnalise.SolidosTotais:
          value = movto.solidosTotais ?? 0.0;
          break;
        case TipoAnalise.ESD:
          value = movto.esd ?? 0.0;
          break;
        case TipoAnalise.CCS:
          value = movto.ccs ?? 0.0;
          break;
        case TipoAnalise.CPP:
          value = movto.cbt ?? 0.0;
          break;
        case TipoAnalise.NU:
          value = movto.nu ?? 0.0;
          break;
        case TipoAnalise.ACIDEZ:
          value = movto.acidez ?? 0.0;
          break;
        case TipoAnalise.CRI:
          value = movto.cri ?? 0.0;
          break;
      }
      return BarChartGroupData(
        x: recentMovtos.indexOf(movto),
        barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.blue,
            width: 40,
            borderRadius: BorderRadius.circular(4),
            // backDrawRodData: BackgroundBarChartRodData(
            //   show: true,
            //   toY: _calculateMaxY(movtos, tpAnalise),
            //   color: Colors.grey[300],
            // ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();

    return data;
  }

  Future<List<AnaliseLeiteProdutor>> getAnaliseLeiteProdutor(
      Propriedade propriedade) async {
    List<AnaliseLeiteProdutor> movtos = await AnaliseLeiteProdutorDAOImpl()
        .selectAll(AnaliseLeiteProdutor(codProdutor: propriedade.codProdutor),
            TipoConsultaDB.PorPropriedade);

    movtos = movtos
        .where(
            (element) => element.data!.isBefore(GlobalData.lastDayCurrentMonth))
        .toList();

    return movtos;
  }

  Color removeBg(BarChartGroupData group) {
    return Colors.transparent;
  }
}

double _calculateMaxY(
    List<AnaliseLeiteProdutor> movtos, TipoAnalise tpAnalise) {
  if (movtos.isEmpty) return 0.0;

  // Calcula os valores com base no tipo de análise
  final valores = movtos.map((movto) {
    switch (tpAnalise) {
      case TipoAnalise.Proteina:
        return movto.proteina ?? 0.0;
      case TipoAnalise.Gordura:
        return movto.gordura ?? 0.0;
      case TipoAnalise.SolidosTotais:
        return movto.solidosTotais ?? 0.0;
      case TipoAnalise.ESD:
        return movto.esd ?? 0.0;
      case TipoAnalise.CCS:
        return movto.ccs ?? 0.0;
      case TipoAnalise.CPP:
        return movto.cbt ?? 0.0;
      case TipoAnalise.NU:
        return movto.nu ?? 0.0;
      case TipoAnalise.ACIDEZ:
        return movto.acidez ?? 0.0;
      case TipoAnalise.CRI:
        return movto.cri ?? 0.0;
    }
  }).toList();

  // Encontra o maior valor
  final maxValue = valores.reduce((a, b) => a > b ? a : b);

  // Define uma margem dinâmica com uma margem mínima fixa
  double margin;
  if (maxValue <= 1.0) {
    margin = 0.2; // Margem fixa para valores pequenos
  } else if (maxValue <= 10.0) {
    margin = maxValue * 0.1; // 10% de margem para valores médios
  } else {
    margin = maxValue * 0.07; // 5% de margem para valores grandes
  }

  // Adiciona uma margem mínima fixa para evitar proximidade visual
  const double minMargin = 0.7; // Margem mínima fixa
  margin = margin < minMargin ? minMargin : margin;

  return maxValue + margin;
}

double _calculateMinY(
    List<AnaliseLeiteProdutor> movtos, TipoAnalise tpAnalise) {
  if (movtos.isEmpty) return 0.0;

  final valores = movtos.map((movto) {
    switch (tpAnalise) {
      case TipoAnalise.Proteina:
        return movto.proteina ?? 0.0;
      case TipoAnalise.Gordura:
        return movto.gordura ?? 0.0;
      case TipoAnalise.SolidosTotais:
        return movto.solidosTotais ?? 0.0;
      case TipoAnalise.ESD:
        return movto.esd ?? 0.0;
      case TipoAnalise.CCS:
        return movto.ccs ?? 0.0;
      case TipoAnalise.CPP:
        return movto.cbt ?? 0.0;
      case TipoAnalise.NU:
        return movto.nu ?? 0.0;
      case TipoAnalise.ACIDEZ:
        return movto.acidez ?? 0.0;
      case TipoAnalise.CRI:
        return movto.cri ?? 0.0;
    }
  }).toList();

  final minValue = valores.reduce((a, b) => a < b ? a : b);

  // If the minimum value is non-negative, start the Y-axis at 0.0
  if (minValue >= 0.0) {
    return 0.0;
  }


  // Define a margin for negative values
  double lowerMargin;
  if (minValue >= -1.0) {
    lowerMargin = -0.05;
  } else if (minValue >= -10.0) {
    lowerMargin = minValue.abs() * -0.08;
  } else {
    lowerMargin = minValue.abs() * -0.1;
  }

  const double minMargin = 0.7;
  lowerMargin = lowerMargin < minMargin ? minMargin : lowerMargin;

  return minValue - lowerMargin;
}

class TabQualidade {
  String analise;
  TipoAnalise tipoAnalise;

  TabQualidade(this.analise, this.tipoAnalise);
}

class OrdinalQualidade {
  final String periodo;
  final double valor;

  OrdinalQualidade(this.periodo, this.valor);
}

enum TipoAnalise {
  Gordura,
  Proteina,
  SolidosTotais,
  ESD,
  CPP,
  CCS,
  NU,
  ACIDEZ,
  CRI
}
