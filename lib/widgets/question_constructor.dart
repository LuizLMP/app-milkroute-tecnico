import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/opcao_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/respostaitem_dao_impl.dart';
import 'package:milkroute_tecnico/utils.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/type/tipo_resposta.dart';
import 'package:milkroute_tecnico/screens/app/popUp.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

// ignore: must_be_immutable
class QuestionConstructor extends StatefulWidget {
  QuestionConstructor({
    super.key,
    required this.pergunta,
    required this.resposta,
    required this.blockPergunta,
  });

  final Pergunta pergunta;
  final Resposta resposta;
  final bool blockPergunta;

  @override
  State<QuestionConstructor> createState() => _QuestionConstructorState();
}

class _QuestionConstructorState extends State<QuestionConstructor> {
  RespostaItem _selectedResposta = RespostaItem(descricao: "");
  late List<RespostaItem> _listSelectedResposta;
  late DateTime _selectedDate;
  late TextEditingController _textField;
  bool inputSave = true;
  TextInputType _tipoInputTexto = TextInputType.text;

  Future<List<RespostaItem>> _carregaRespostaItem(
    Pergunta pergunta,
    Resposta resposta, [
    RespostaItem? respostaItem,
  ]) async {
    List<RespostaItem> listReturn = [];
    List<RespostaItem> listRespostaItem = await RespostaItemDAOImpl().selectAll(
      RespostaItem(pergunta: pergunta, resposta: resposta),
      TipoConsultaDB.PorPergunta,
    );

    if (respostaItem != null && respostaItem.opcao != null) {
      if (pergunta.tipoPergunta != TipoPergunta.MultiplaEscolha) {
        listReturn = listRespostaItem.where((respItem) => respItem.opcao?.id == respostaItem.opcao?.id).toList();
      }
    } else {
      listReturn = listRespostaItem;
    }

    return listReturn;
  }

  Future<List<RespostaItem>> _atualizaRespostaItem(
    Pergunta pergunta,
    Resposta resposta, [
    RespostaItem? respostaItem,
  ]) async {
    List<RespostaItem> listReturn;
    List<RespostaItem> listRespostaItem = await RespostaItemDAOImpl().selectAll(
      RespostaItem(pergunta: pergunta, resposta: resposta),
      TipoConsultaDB.PorPergunta,
    );

    if (respostaItem != null && respostaItem.opcao != null) {
      listReturn = listRespostaItem.where((respItem) => respItem.opcao?.id == respostaItem.opcao?.id).toList();
    } else {
      listReturn = listRespostaItem;
    }

    return listReturn;
  }

  Future<Opcao?> _salvaResposta(
    RespostaItem respostaItemNova,
    RespostaItem? respostaItemAntiga,
  ) async {
    try {
      RespostaItem? _respostaItemValidada;

      if (respostaItemAntiga != null && respostaItemAntiga.idAppTecnico != null) {
        respostaItemNova.idAppTecnico = respostaItemAntiga.idAppTecnico;
        respostaItemNova.idWeb = respostaItemAntiga.idWeb;
      } else {
        respostaItemNova.idAppTecnico = HashGenerator().geradorSha1Random(respostaItemNova.pergunta!.id.toString());
      }
      respostaItemNova.dataHoraIU = DateTime.now();

      respostaItemNova.descricao ??= respostaItemNova.opcao?.descricao ?? "";

      switch (respostaItemNova.pergunta?.tipoPergunta) {
        case TipoPergunta.MultiplaEscolha:
          List<Opcao> listOpcoes = await OpcaoDAOImpl().selectAll(
            respostaItemNova.opcao!,
            TipoConsultaDB.PorPergunta,
          );
          List<RespostaItem> listRespostaItemDB = await RespostaItemDAOImpl().selectAll(respostaItemNova, TipoConsultaDB.PorPergunta);

          if (listRespostaItemDB.length < listOpcoes.length) {
            for (Opcao elemOpt in listOpcoes) {
              if (!listRespostaItemDB.any((elemResp) => elemResp.opcao?.id == elemOpt.id)) {
                await RespostaItemDAOImpl().insert(
                  RespostaItem(
                    idAppTecnico: HashGenerator().geradorSha1Random(elemOpt.id.toString()),
                    opcao: elemOpt,
                    descricao: elemOpt.descricao,
                    pergunta: elemOpt.pergunta,
                    resposta: respostaItemNova.resposta,
                    visualizaResposta: false,
                    dataHoraIU: DateTime.now(),
                  ),
                );
              }
            }
          }

          await _atualizaRespostaItem(
            respostaItemNova.pergunta!,
            respostaItemNova.resposta!,
            respostaItemNova,
          ).then((result) async {
            if (result.isNotEmpty) {
              respostaItemNova.idAppTecnico = result[0].idAppTecnico;
              await RespostaItemDAOImpl().update(respostaItemNova);
            }
          });

          break;

        case TipoPergunta.Combo:
          if (respostaItemNova.opcao?.valorResposta == "Sem valor") {
            await RespostaItemDAOImpl().remove(
              respostaItemNova.pergunta!.id.toString(),
              TipoConsultaDB.PorPergunta,
            );
          } else {
            await _atualizaRespostaItem(
              respostaItemNova.pergunta!,
              respostaItemNova.resposta!,
            ).then((result) async {
              if (result.isNotEmpty) {
                _respostaItemValidada = result[0];
                await RespostaItemDAOImpl().insert(respostaItemNova);
              }
            });

            if (_respostaItemValidada != null) {
              respostaItemNova.idAppTecnico = _respostaItemValidada!.idAppTecnico;
            } else {
              await RespostaItemDAOImpl().insert(respostaItemNova);
            }
          }

          break;

        case TipoPergunta.Texto:
          if (respostaItemNova.descricao == null || respostaItemNova.descricao!.isEmpty) {
            await RespostaItemDAOImpl().remove(
              respostaItemNova.pergunta!.id.toString(),
              TipoConsultaDB.PorPergunta,
            );
          } else {
            await _atualizaRespostaItem(
              respostaItemNova.pergunta!,
              respostaItemNova.resposta!,
            ).then((result) async {
              if (result.isNotEmpty) {
                _respostaItemValidada = result[0];
                await RespostaItemDAOImpl().insert(respostaItemNova);
              }
            });

            if (_respostaItemValidada != null) {
              respostaItemNova.idAppTecnico = _respostaItemValidada?.idAppTecnico;
            } else {
              await RespostaItemDAOImpl().insert(respostaItemNova);
            }
          }
          break;

        default:
          await _atualizaRespostaItem(
            respostaItemNova.pergunta!,
            respostaItemNova.resposta!,
          ).then((result) async {
            if (result.isNotEmpty) {
              _respostaItemValidada = result[0];
              await RespostaItemDAOImpl().insert(respostaItemNova);
            }
          });

          if (_respostaItemValidada != null) {
            respostaItemNova.idAppTecnico = _respostaItemValidada?.idAppTecnico;
          } else {
            await RespostaItemDAOImpl().insert(respostaItemNova);
          }

          break;
      }

      return respostaItemNova.opcao;
    } catch (ex) {
      throw Exception(
        "Erro ao salvar resposta. Motivo: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _textField = TextEditingController();
  }

  @override
  void dispose() {
    _textField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String flagPerguntaObrig = (widget.pergunta.obrigatorio!) ? " *" : "";

    if (widget.pergunta.listOpcoes!.isNotEmpty) {
      _tipoInputTexto = (widget.pergunta.listOpcoes?[0].valorResposta == "number") ? TextInputType.number : TextInputType.text;
    }

    return FutureBuilder(
        future: _carregaRespostaItem(widget.pergunta, widget.resposta, _selectedResposta),
        builder: ((context, respostaItem) {
          // --- Correção para evitar salvamento replicado de respostas

          if (respostaItem.hasData && respostaItem.data!.isNotEmpty) {
            _selectedResposta = respostaItem.data![0];

            if (widget.pergunta.tipoPergunta == TipoPergunta.MultiplaEscolha) {
              _listSelectedResposta = respostaItem.data!;
            }
          }
          // ----

          if (_selectedResposta == null || _selectedResposta.opcao == null) {
            if (respostaItem.hasData && respostaItem.data!.isNotEmpty) {
              var opcaoSelecionada = respostaItem.data;
              _selectedResposta = opcaoSelecionada![0];

              if (widget.pergunta.tipoPergunta == TipoPergunta.MultiplaEscolha) {
                _listSelectedResposta = opcaoSelecionada!;
              }
            } else {
              _selectedResposta = RespostaItem();
              _listSelectedResposta = [];
            }
          }

          if (widget.pergunta != null || widget.resposta != null) {
            switch (widget.pergunta.tipoPergunta) {
              case TipoPergunta.Combo:
                return Builder(builder: (context) {
                  List<Opcao> listOpcoesSelect = [];

                  listOpcoesSelect.add(Opcao(descricao: " -- Selecione uma opção -- ", valorResposta: "Sem valor", pergunta: widget.pergunta, ativa: true, id: null));
                  listOpcoesSelect.addAll(widget.pergunta.listOpcoes!);

                  if (widget.blockPergunta) {
                    return ListTile(
                      title: DropdownButtonFormField<Opcao>(
                          decoration: InputDecoration(labelText: widget.pergunta.descricao! + flagPerguntaObrig),
                          value: (_selectedResposta == null || _selectedResposta.opcao == null)
                              ? listOpcoesSelect[0]
                              : (listOpcoesSelect.where((elem) => elem.id == _selectedResposta.opcao?.id)).toList()[0],
                          items: listOpcoesSelect.map<DropdownMenuItem<Opcao>>((Opcao opcao) {
                            return DropdownMenuItem<Opcao>(
                              value: opcao,
                              child: Text(opcao.descricao!),
                            );
                          }).toList(),
                          onChanged: null),
                    );
                  } else {
                    return ListTile(
                      title: DropdownButtonFormField<Opcao>(
                        decoration: InputDecoration(labelText: widget.pergunta.descricao! + flagPerguntaObrig),
                        value: (_selectedResposta == null || _selectedResposta.opcao == null)
                            ? listOpcoesSelect[0]
                            : (listOpcoesSelect.where((elem) => elem.id == _selectedResposta.opcao?.id)).toList()[0],
                        icon: Icon(Icons.arrow_downward),
                        items: listOpcoesSelect.map<DropdownMenuItem<Opcao>>((Opcao opcao) {
                          return DropdownMenuItem<Opcao>(
                            value: opcao,
                            child: Text(opcao.descricao!),
                          );
                        }).toList(),
                        onChanged: (Opcao? newValue) {
                          if (newValue != null) {
                            _salvaResposta(
                              RespostaItem(opcao: newValue, pergunta: widget.pergunta, resposta: widget.resposta),
                              _selectedResposta,
                            ).then((returnSalvar) {
                              setState(() {
                                _selectedResposta.opcao = returnSalvar ?? newValue;
                              });
                            });
                          }
                        },
                      ),
                    );
                  }
                });
                break;

              case TipoPergunta.Data:
                if (widget.blockPergunta) {
                  return ListTile(
                      title: TextField(
                    controller: TextEditingController(
                        text: (_textField.text == "")
                            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(
                                (_selectedResposta.descricao ?? "0001-01-01").isEmpty ? "0001-01-01" : GlobalData().convertDateToCast(IdiomaData.PtBR, _selectedResposta.descricao!)
                                //_selectedResposta.descricao
                                ))
                            : _textField.text),
                    readOnly: true,
                    style: TextStyle(color: Colors.black45),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.date_range),
                      labelText: widget.pergunta.descricao! + flagPerguntaObrig,
                    ),
                    onChanged: null,
                  ));
                } else {
                  return ListTile(
                      title: TextField(
                    controller: TextEditingController(
                        text: (_textField.text == "")
                            ? DateFormat('dd/MM/yyyy').format(
                                DateTime.parse((_selectedResposta.descricao == null) ? "0001-01-01" : GlobalData().convertDateToCast(IdiomaData.PtBR, _selectedResposta.descricao!)
                                    //_selectedResposta.descricao
                                    ))
                            : _textField.text),
                    readOnly: (widget.blockPergunta) ? true : false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.date_range),
                      suffix: (!widget.blockPergunta)
                          ? GestureDetector(
                              child: Icon(Icons.close),
                              onTap: (() async {
                                String dataClear = "00/00/0000";
                                await _salvaResposta(
                                    RespostaItem(opcao: widget.pergunta.listOpcoes?[0], pergunta: widget.pergunta, resposta: widget.resposta, descricao: dataClear),
                                    _selectedResposta);
                                setState(() {
                                  _textField.clear();
                                  _selectedResposta.descricao = "";
                                });
                              }),
                            )
                          : Icon(Icons.block),
                      labelText: widget.pergunta.descricao! + flagPerguntaObrig,
                    ),
                    onChanged: null,
                    onTap: (() {
                      if (widget.blockPergunta) {
                        return null;
                      } else {
                        showDatePicker(
                                context: context,
                                initialDate: (_selectedDate == null) ? DateTime.now() : _selectedDate,
                                firstDate: DateTime(DateTime.now().year - 1),
                                lastDate: DateTime(DateTime.now().year + 1))
                            .then((pickedDate) {
                          setState(() {
                            _selectedDate = pickedDate!;
                            _textField.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                          });
                        });
                      }
                    }),
                    onSubmitted: (String value) async {
                      Opcao? returnSalvar = await _salvaResposta(
                          RespostaItem(opcao: widget.pergunta.listOpcoes?[0], pergunta: widget.pergunta, resposta: widget.resposta, descricao: value), _selectedResposta);

                      setState(() {
                        _textField.text = value;
                        (returnSalvar != null)
                            ? _selectedResposta.opcao = returnSalvar
                            : showAlertPopup(context, "Info", "A resposta do campo ${widget.pergunta.descricao} não pode ser salva. Tente novamente");
                      });
                    },
                  ));
                }

                break;

              case TipoPergunta.EscolhaUma:
                return ListTile(
                  title: Row(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(widget.pergunta.descricao! + flagPerguntaObrig),
                          Row(
                            children: [
                              for (final opcao in widget.pergunta.listOpcoes!)
                                Column(
                                  children: <Widget>[
                                    Builder(
                                      builder: ((BuildContext context) {
                                        if ((respostaItem.hasData && respostaItem.data!.isNotEmpty) && (_selectedResposta.opcao?.id == opcao.id)) {
                                          _selectedResposta.opcao = opcao;
                                        }

                                        if (widget.blockPergunta == true) {
                                          return Transform.scale(
                                            scale: 1.6,
                                            child: Radio(
                                              activeColor: opcao.cor,
                                              value: opcao,
                                              groupValue: _selectedResposta.opcao,
                                              onChanged: null,
                                            ),
                                          );
                                        } else {
                                          return Transform.scale(
                                            scale: 1.6,
                                            child: Radio(
                                              activeColor: opcao.cor,
                                              value: opcao,
                                              groupValue: _selectedResposta.opcao,
                                              onChanged: (Opcao? valor) async {
                                                Opcao? returnSalvar =
                                                    await _salvaResposta(RespostaItem(opcao: opcao, pergunta: widget.pergunta, resposta: widget.resposta), _selectedResposta);

                                                setState(() {
                                                  (returnSalvar != null) ? _selectedResposta.opcao = returnSalvar : _selectedResposta.opcao = valor;
                                                });
                                              },
                                            ),
                                          );
                                        }
                                      }),
                                    ),
                                    Text(
                                      opcao.descricao!,
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                    Divider(
                                      height: 20.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                );
                break;

              case TipoPergunta.MultiplaEscolha:
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(widget.pergunta.descricao! + flagPerguntaObrig),
                      Stack(
                        children: [
                          GridView.count(
                            crossAxisCount: 4,
                            childAspectRatio: 1,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children: List.generate(widget.pergunta.listOpcoes!.length, (index) {
                              Opcao opcao = widget.pergunta.listOpcoes![index];

                              RespostaItem? respostaCheck;

                              if (_listSelectedResposta.isNotEmpty) {
                                var returnList = _listSelectedResposta.where((elem) => (elem.opcao?.id == opcao.id)).toList();
                                if (returnList.isNotEmpty) {
                                  respostaCheck = returnList[0];
                                }
                              }

                              if (widget.blockPergunta) {
                                return Column(
                                  children: <Widget>[
                                    Transform.scale(
                                      scale: 1.6,
                                      child: Checkbox(
                                        visualDensity: VisualDensity.comfortable,
                                        value: respostaCheck?.visualizaResposta ?? false,
                                        activeColor: opcao.cor,
                                        onChanged: null,
                                      ),
                                    ),
                                    Text(
                                      opcao.descricao!,
                                      style: TextStyle(fontSize: 12.0),
                                      textAlign: TextAlign.center,
                                    ),
                                    Divider(
                                      height: 20.0,
                                      color: Colors.black,
                                    ),
                                  ],
                                );
                              } else {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: Column(
                                    children: <Widget>[
                                      Transform.scale(
                                        scale: 1.6,
                                        child: Checkbox(
                                          value: (respostaCheck != null) ? respostaCheck.visualizaResposta : false,
                                          activeColor: opcao.cor,
                                          visualDensity: VisualDensity.comfortable,
                                          onChanged: (bool? value) {
                                            if (value != null) {
                                              _salvaResposta(
                                                RespostaItem(opcao: opcao, pergunta: widget.pergunta, resposta: widget.resposta, visualizaResposta: value),
                                                _selectedResposta,
                                              ).then((returnSalvar) {
                                                _listSelectedResposta.asMap().entries.forEach((e) {
                                                  if (e.value.opcao?.id == opcao.id) {
                                                    _listSelectedResposta[e.key].visualizaResposta = value;
                                                  }
                                                });

                                                setState(() {
                                                  if (returnSalvar != null) {
                                                    _listSelectedResposta;
                                                  }
                                                });
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      Text(
                                        opcao.descricao!,
                                        style: TextStyle(fontSize: 12.0),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                break;

              case TipoPergunta.Texto:
                if (widget.blockPergunta) {
                  return ListTile(
                      title: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.edit_off_sharp),
                      labelText: widget.pergunta.descricao! + flagPerguntaObrig,
                    ), // onSaved: (val) => _tenant = val,

                    style: TextStyle(
                      color: Colors.black45,
                    ),
                    controller: TextEditingController(text: (_textField.text == "") ? _selectedResposta.descricao : _textField.text),
                    readOnly: true,
                    onChanged: null,
                  ));
                } else {
                  return Builder(
                    builder: (context) {
                      return ListTile(
                        title: TextField(
                          decoration: InputDecoration(
                            labelText: widget.pergunta.descricao! + flagPerguntaObrig,
                            prefixIcon: Icon(Icons.edit),
                            suffix: (!widget.blockPergunta)
                                ? GestureDetector(
                                    child: Icon(Icons.close),
                                    onLongPress: () async {
                                      await _salvaResposta(RespostaItem(opcao: widget.pergunta.listOpcoes?[0], pergunta: widget.pergunta, resposta: widget.resposta, descricao: ""),
                                          _selectedResposta);

                                      setState(() {
                                        _textField.clear();
                                        _selectedResposta.descricao = "";
                                      });
                                    },
                                  )
                                : Icon(Icons.block),
                          ),
                          controller: TextEditingController(
                            text: (_textField.text == "") ? _selectedResposta.descricao : _textField.text,
                          )..selection = TextSelection.fromPosition(TextPosition(offset: _textField.text.length)),
                          readOnly: (widget.blockPergunta) ? true : false,
                          style: TextStyle(
                            color: (widget.pergunta.listOpcoes!.isEmpty) ? colorScheme.primary : widget.pergunta.listOpcoes?[0].cor,
                          ),
                          keyboardType: _tipoInputTexto,
                          onChanged: (value) {
                            setState(() {
                              _textField.text = value;
                              inputSave = false;
                            });
                          },
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            Opcao? returnSalvar = await _salvaResposta(
                                RespostaItem(opcao: widget.pergunta.listOpcoes?[0], pergunta: widget.pergunta, resposta: widget.resposta, descricao: _textField.text),
                                _selectedResposta);

                            if (returnSalvar != null) {
                              _selectedResposta.opcao = returnSalvar;

                              setState(() {
                                inputSave = true;
                              });
                            } else {
                              showAlertPopup(context, 'Info', "A resposta do campo ${widget.pergunta.descricao} não pode ser salva. Tente novamente!");
                            }
                          },
                          icon: AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: (inputSave)
                                  ? Icon(
                                      Icons.check_circle,
                                      size: 35,
                                      color: Colors.green.shade600,
                                      key: ValueKey(Icons.check_circle),
                                    )
                                  : Icon(
                                      Icons.save,
                                      size: 35,
                                      color: Colors.red.shade600,
                                      key: ValueKey(Icons.save),
                                    )),
                        ),
                      );
                    },
                  );
                }

                break;

              case TipoPergunta.Imagem:
                if (widget.blockPergunta) {
                  return ListTile(
                    title: Row(children: []),
                  );
                } else {
                  return ListTile(
                    title: Text('Imagens'),
                  );
                }
                break;

              default:
                return ListTile(title: Text("Problemas com o carregamento da pergunta. Procure o estabelecimento responsável para solução do problema!"));
                break;
            }
          } else {
            return ListTile(title: Text("Carregando Questionário de Visita. AGUARDE...!"));
          }
        }));
  }

  // ignore: unused_element, missing_return
  Future<DateTime> _showDatePickerCustom(BuildContext context) async {
    final picked = await showMonthPicker(context: context, initialDate: GlobalData.periodo, firstDate: DateTime(2010, 1), lastDate: DateTime.now());
    if (picked != null && picked != GlobalData.periodo) {
      setState(() {
        GlobalData.periodo = picked;
        GlobalData.firstDayCurrentMonth = DateTime(GlobalData.periodo.year, GlobalData.periodo.month, 1, 0, 0, 0);
        GlobalData.lastDayCurrentMonth = DateTime(GlobalData.periodo.year, GlobalData.periodo.month + 1, 1, 23, 59, 59).subtract(Duration(days: 1));
      });
      return picked;
    }
    return GlobalData.periodo;
  }
}
