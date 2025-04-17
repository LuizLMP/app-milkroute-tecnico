import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/viewsController.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/questionario_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/visita_dao_impl.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:milkroute_tecnico/screens/app/app_drawer.dart';
import 'package:milkroute_tecnico/screens/home/formulario_screen.dart';
import 'package:milkroute_tecnico/utils.dart';
import 'package:milkroute_tecnico/widgets/dialogs.dart';
import 'package:milkroute_tecnico/widgets/footer_screen.dart';
import 'package:milkroute_tecnico/widgets/header_screens.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import "package:collection/collection.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.restorationId});

  final String restorationId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RestorationMixin {
  final RestorableInt _currentIndex = RestorableInt(0);
  final ViewsController _propsView = ViewsController();
  List<Visita> _structVisita = [];
  late ValueNotifier<List<Visita>> _selectedVisitas;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  PageController? _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  DateTime _visitaFirstDay = DateTime.now();
  DateTime _visitaLastDay = DateTime.now();

  @override
  String get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_currentIndex, 'bottom_navigation_tab_index');
  }

  Future<List<Visita>> _carregarVisitas() async {
    var listVisitas = await VisitaDAOImpl().selectSimple(Visita(), TipoConsultaDB.Tudo);

    listVisitas.sort(
      (a, b) {
        return a.dataInicio!.compareTo(b.dataInicio!);
      },
    );

    return listVisitas.toList();
  }

  @override
  void initState() {
    super.initState();

    _selectedDays.add(_focusedDay.value);
    _selectedVisitas = ValueNotifier(_getEventsForDay(_structVisita, _focusedDay.value));
  }

  @override
  void dispose() {
    _currentIndex.dispose();
    _focusedDay.dispose();
    _selectedVisitas.dispose();
    super.dispose();
  }

  bool get canClearSelection => _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  List<Visita> _getEventsForDay(List<Visita> structVisita, DateTime day) {
    if (structVisita.isNotEmpty) {
      var kVisitaSource = {
        for (var item in List.generate(structVisita.length, (index) => index))
          DateTime.parse(DateFormat("yyyy-MM-dd").format(structVisita[item].dataInicio!)):
              structVisita.where((Visita visita) => DateFormat("yyyy-MM-dd").format(visita.dataInicio!) == DateFormat("yyyy-MM-dd").format(structVisita[item].dataInicio!)).toList()
      };

      /// Example events.
      /// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
      var kVisita = LinkedHashMap<DateTime, List<Visita>>(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll(kVisitaSource);

      return kVisita[day] ?? [];
    } else {
      return [];
    }
  }

  List<Visita> _getEventsForDays(List<Visita> structVisita, Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(structVisita, d),
    ];
  }

  List<Visita> _getEventsForRange(List<Visita> structVisita, DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(structVisita, days);
  }

  /// Returns a list of [DateTime] objects from [first] to [last], inclusive.
  List<DateTime> daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }

  void _onDaySelected(List<Visita> structVisita, DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }

      _focusedDay.value = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    _selectedVisitas.value = _getEventsForDays(structVisita, _selectedDays);
  }

  void _onRangeSelected(List<Visita> structVisita, DateTime start, DateTime end, DateTime focusedDay) {
    setState(() {
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _selectedDays.clear();
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedVisitas.value = _getEventsForRange(structVisita, start, end);
    } else if (start != null) {
      _selectedVisitas.value = _getEventsForDay(structVisita, start);
    } else if (end != null) {
      _selectedVisitas.value = _getEventsForDay(structVisita, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final _auth = context.read<AuthModel>();
    final double heightSizeToolbar = 70;
    // final nomeTecnico = _auth.tecnico.nomeTecnico;

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
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings,
              color: colorScheme.onPrimary,),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            )
          ],
        ),
        drawer: AppDrawer(),
        body: SafeArea(
          bottom: true,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: FutureBuilder(
              future: _carregarVisitas(),
              builder: (context, listVisita) {
                if (listVisita.hasData) {
                  if (listVisita.data!.isNotEmpty) {
                    _visitaFirstDay = ((listVisita.data!.first.dataInicio!.isAfter(DateTime.now())) ? DateTime.now() : listVisita.data?.first.dataInicio)!;
                    _visitaLastDay = ((listVisita.data!.last.dataInicio!.isBefore(DateTime.now())) ? DateTime.now() : listVisita.data?.last.dataInicio)!;
                  } else {
                    _visitaFirstDay = DateTime.now();
                    _visitaLastDay = DateTime.now().add(Duration(days: 60));
                  }

                  return Column(
                    children: <Widget>[
                      Column(
                        children: [
                          Center(
                            child: Text(
                              'Agenda de Visitas',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      ValueListenableBuilder<DateTime>(
                        valueListenable: _focusedDay,
                        builder: (context, value, _) {
                          return _CalendarHeader(
                            focusedDay: value,
                            clearButtonVisible: canClearSelection,
                            onTodayButtonTap: () {
                              setState(() => _focusedDay.value = DateTime.now());
                            },
                            onClearButtonTap: () {
                              setState(() {
                                _rangeStart = null;
                                _rangeEnd = null;
                                _selectedDays.clear();
                                _selectedVisitas.value = [];
                              });
                            },
                            onLeftArrowTap: () {
                              _pageController?.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                            onRightArrowTap: () {
                              _pageController?.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            },
                          );
                        },
                      ),
                      TableCalendar<Visita>(
                        locale: 'pt_BR',
                        firstDay: _visitaFirstDay,
                        lastDay: _visitaLastDay,
                        focusedDay: _focusedDay.value,
                        headerVisible: false,
                        selectedDayPredicate: (day) => _selectedDays.contains(day),
                        rangeStartDay: _rangeStart,
                        rangeEndDay: _rangeEnd,
                        calendarFormat: _calendarFormat,
                        rangeSelectionMode: _rangeSelectionMode,
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) => Container(
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          outsideBuilder: (context, day, focusedDay) => Container(
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          todayBuilder: (context, day, focusedDay) => Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(),
                            ),
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          holidayBuilder: (context, day, focusedDay) => Container(
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                          selectedBuilder: (context, day, focusedDay) => Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.rectangle, color: colorScheme.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colorScheme.primary),
                            ),
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          rangeStartBuilder: (context, day, focusedDay) => Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.background),
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          rangeEndBuilder: (context, day, focusedDay) => Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.background),
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          ),
                          withinRangeBuilder: (context, day, isWithinRange) => Container(
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: colorScheme.background),
                            ),
                          ),
                          markerBuilder: (BuildContext context, date, events) {
                            if (events.length > 0) {
                              Map<String, List<Visita>> groupStatusVisitas = groupBy(events, (Visita elem) {
                                if (elem.listRespostas!.isNotEmpty && elem.statusVisita != "FINALIZADO") {
                                  return "EM ANDAMENTO";
                                } else {
                                  return elem.statusVisita!;
                                }
                              });

                              if (events.isEmpty) return SizedBox();
                              return Container(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: groupStatusVisitas.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        alignment: Alignment.bottomCenter,
                                        padding: const EdgeInsets.all(1),
                                        child: Container(
                                          decoration: BoxDecoration(color: Visita().setColorVisita(groupStatusVisitas.keys.toList()[index])),
                                          child: Text(
                                            groupStatusVisitas[groupStatusVisitas.keys.toList()[index]]!.length.toString(),
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    }),
                              );
                            } else {
                              return null;
                            }
                          },
                        ),
                        eventLoader: (day) {
                          return _getEventsForDay(listVisita.data!, day);
                        },
                        // Feriados - Exemplo: Todo dia 20 de cada mês
                        // holidayPredicate: (day) {
                        //   return day.day == 20;
                        // },
                        onDaySelected: (selectedDay, focusedDay) {
                          return _onDaySelected(listVisita.data!, selectedDay, focusedDay);
                        },
                        onRangeSelected: (start, end, focusedDay) {
                          return _onRangeSelected(listVisita.data!, start!, end!, focusedDay);
                        },
                        onCalendarCreated: (controller) => _pageController = controller,
                        onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() => _calendarFormat = format);
                          }
                        },
                      ),
                      const SizedBox(height: 5.0),
                      Expanded(
                        child: ValueListenableBuilder<List<Visita>>(
                          valueListenable: _selectedVisitas,
                          builder: (context, listVisita, _) {
                            return ListView.builder(
                              itemCount: listVisita.length,
                              itemBuilder: (context, index) {
                                final linha = listVisita[index];

                                if (linha.listRespostas!.isNotEmpty && linha.statusVisita != "FINALIZADO") {
                                  linha.statusVisita = "EM ANDAMENTO";
                                }

                                return Card(
                                  color: linha.setColorVisita(linha.statusVisita!),
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        onTap: () async {
                                          linha.questionario = await QuestionarioDAOImpl().carregarQuestionario(linha.questionario!.id!);

                                          if (linha.statusVisita == "FINALIZADO") {
                                            dialog2Opt(
                                              context,
                                              "Cancelar",
                                              "Iniciar",
                                              "Consulta Respostas",
                                              "Esta visita foi finalizada e está disponível apenas para consulta. Deseja continuar?",
                                              "",
                                              FormularioScreen(
                                                visita: linha,
                                                questionario: linha.questionario,
                                                propriedade: linha.propriedade,
                                              ),
                                              // pdf.data,
                                            );
                                          } else {
                                            dialog2Opt(
                                              context,
                                              "Cancelar",
                                              "Iniciar",
                                              "Iniciar preenchimento de Questionário",
                                              "Deseja iniciar o questionário ${linha.questionario?.descricao} para o produtor(a) ${linha.propriedade?.pessoa?.nomeRazaoSocial}?",
                                              "",
                                              FormularioScreen(
                                                visita: linha,
                                                questionario: linha.questionario,
                                                propriedade: linha.propriedade,
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
                                          ],
                                        ),
                                        trailing: Column(children: [
                                          CircleAvatar(backgroundColor: linha.setColorVisita(linha.statusVisita!), child: Icon(Icons.open_in_new)),
                                        ]),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return LoaderFeedbackCow(
                    mensagem: "Carregando Calendário de Visitas",
                    size: 60,
                  );
                }
              },
            ),
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
}

class _CalendarHeader extends StatelessWidget {
  final DateTime? focusedDay;
  final VoidCallback? onLeftArrowTap;
  final VoidCallback? onRightArrowTap;
  final VoidCallback? onTodayButtonTap;
  final VoidCallback? onClearButtonTap;
  final bool? clearButtonVisible;

  const _CalendarHeader({
    Key? key,
    this.focusedDay,
    this.onLeftArrowTap,
    this.onRightArrowTap,
    this.onTodayButtonTap,
    this.onClearButtonTap,
    this.clearButtonVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final headerText = DateFormat.yMMM().format(focusedDay);

    final headerText = DateFormat("MMM/yyyy", "pt_BR").format(focusedDay!);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: TextStyle(fontSize: 26.0),
            ),
          ),
          // IconButton(
          //   icon: Icon(Icons.calendar_today, size: 20.0),
          //   visualDensity: VisualDensity.compact,
          //   onPressed: onTodayButtonTap,
          // ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
          if (clearButtonVisible!)
            IconButton(
              icon: Icon(Icons.clear, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
        ],
      ),
    );
  }
}
