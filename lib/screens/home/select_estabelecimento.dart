import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/estabelecimento_dao_impl.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/screens/home/pre_loader_screen.dart';
import 'package:milkroute_tecnico/widgets/dialogs.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectEstabelecimentoScreen extends StatefulWidget {
  const SelectEstabelecimentoScreen({super.key, this.model});

  final AuthModel? model;

  @override
  State<SelectEstabelecimentoScreen> createState() => SelectEstabelecimentoScreenState();
}

class SelectEstabelecimentoScreenState extends State<SelectEstabelecimentoScreen> {
  Estabelecimento? selectedEstabelecimento;

  Future<List<Estabelecimento>> carregarEstabelecimentos() async {
    List<Estabelecimento> listEstabel = [];

    listEstabel = await EstabelecimentoDAOImpl().selectAll(Estabelecimento(), TipoConsultaDB.Tudo);

    return listEstabel;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: null,
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Center(
                    child: Text(
                  'Selecione um Estabelecimento',
                  style: TextStyle(fontSize: 20),
                )),
                SizedBox(
                  height: 40,
                ),
                FutureBuilder(
                  future: carregarEstabelecimentos(),
                  builder: (context, listEstabel) {
                    if (listEstabel.hasData) {
                      if (listEstabel.data!.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: DropdownButtonFormField<Estabelecimento>(
                            decoration: InputDecoration(labelText: "Selecione um Estabelecimento"),
                            icon: Icon(Icons.arrow_downward),
                            value: (selectedEstabelecimento == null)
                                ? null
                                : (listEstabel.data?.where((element) => element.codEstabel == selectedEstabelecimento?.codEstabel))?.toList()[0],
                            items: listEstabel.data?.map<DropdownMenuItem<Estabelecimento>>((Estabelecimento estabelecimento) {
                              String? descricaoDropDown = (estabelecimento.pessoa?.cidade != null)
                                  ? "${estabelecimento.codEstabel} - ${estabelecimento.pessoa?.cidade?.nome} / ${estabelecimento.pessoa?.cidade?.estado?.sigla}"
                                  : estabelecimento.codigoNomeEstabel;

                              return DropdownMenuItem<Estabelecimento>(
                                value: estabelecimento,
                                child: Text(descricaoDropDown!),
                              );
                            }).toList(),
                            onChanged: (Estabelecimento? newValue) {
                              setState(() {
                                selectedEstabelecimento = newValue;
                              });
                            },
                          ),
                        );
                      } else {
                        return Text(
                          "Nenhum estabelecimento encontrado.\nContate sua Unidade para mais informações.",
                          textAlign: TextAlign.center,
                        );
                      }
                    } else {
                      return LoaderFeedbackCow(
                        mensagem: "Carregando estabelecimentos",
                        size: 60,
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  ),
                  onPressed: () async {
                    if (selectedEstabelecimento != null) {
                      GlobalData.estabelecimentoSelecionado = selectedEstabelecimento!;

                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setString("estabelecimento", selectedEstabelecimento!.codEstabel!);
                      });

                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PreLoaderScreen(
                          model: widget.model!,
                          estabelecimento: selectedEstabelecimento!,
                        ),
                      ));
                    } else {
                      dialog1Opt(
                        context,
                        "Voltar",
                        "Estabelecimento não informado",
                        "É necessário selecionar um estabelecimento",
                        null,
                      );
                    }
                  },
                  child: Text('Confirmar',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary,
                      )),
                ),
                TextButton(
                  onPressed: () async {
                    widget.model?.logout();
                    Navigator.of(context).pop();
                  },
                  child: Text('Voltar '),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
          ],
        )),
      ),
    );
  }
}
