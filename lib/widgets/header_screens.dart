import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/syncController.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// ignore: must_be_immutable
class HeaderScreens extends StatefulWidget {
  AuthModel? auth;
  double? height;
  double? width;
  EdgeInsets? padding;
  int? ordemView = 0;
  HeaderScreens({super.key, this.auth, this.height, this.width, this.padding, this.ordemView});

  @override
  State<HeaderScreens> createState() => _HeaderScreensState();
}

class _HeaderScreensState extends State<HeaderScreens> {
  int qtdeViews = telas.isNotEmpty ? telas.length : 0;

  @override
  void initState() {
    super.initState();
    SyncController.instance.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSync = (SyncController.instance.loaderProgressBar < 0.99) ? true : false;
    Color loaderBarColor = (isSync) ? Colors.deepOrange : Colors.greenAccent;
    String? estabelecimentoDescr = (GlobalData.estabelecimentoSelecionado.pessoa!.cidade != null)
        ? "${GlobalData.estabelecimentoSelecionado.codEstabel!} - ${GlobalData.estabelecimentoSelecionado.pessoa!.cidade!.nome!} / ${GlobalData.estabelecimentoSelecionado.pessoa!.cidade!.estado!.sigla!}"
        : GlobalData.estabelecimentoSelecionado.codigoNomeEstabel;

    return Container(
      padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 0, vertical: 7),
      decoration: BoxDecoration(
        color: LightColors.kDarkBlue,
      ),
      height: widget.height,
      width: widget.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      TweenAnimationBuilder(
                        tween: Tween(begin: 0.0, end: SyncController.instance.loaderProgressBar),
                        duration: Duration(milliseconds: 500),
                        builder: ((context, value, _) {
                          if (value > 1) {
                            value = 1.0;
                          }

                          return CircularPercentIndicator(
                            radius: 21.0,
                            lineWidth: 4.0,
                            animation: false,
                            percent: value,
                            circularStrokeCap: CircularStrokeCap.round,
                            progressColor: loaderBarColor,
                            backgroundColor: LightColors.kDarkYellow,
                            center: (isSync)
                                ? LoaderFeedbackCow(
                                    mensagem: "",
                                    size: 23,
                                  )
                                : CircleAvatar(
                                    backgroundColor: LightColors.kBlue,
                                    radius: 15.0,
                                    backgroundImage: AssetImage(
                                      'assets/images/avatar_milkroute_tecnico.png',
                                    ),
                                  ),
                          );
                        }),
                      ),
                      // ElevatedButton(
                      //     onPressed: (() => SyncController.instance.syncDados(widget.auth.user)), child: Text('teste')),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            widget.auth!.tecnico!.nomeTecnico!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (widget.auth!.tecnico!.nomeTecnico!.length > 21) ? 18.0 : 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            estabelecimentoDescr!,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
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
    );
  }
}
