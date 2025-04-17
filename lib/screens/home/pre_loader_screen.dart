import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/connectivityController.dart';
import 'package:milkroute_tecnico/controller/syncController.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/screens/home/home_screen.dart';
import 'package:milkroute_tecnico/screens/home/select_estabelecimento.dart';
import 'package:milkroute_tecnico/screens/signin/login_screen.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class PreLoaderScreen extends StatefulWidget {
  const PreLoaderScreen({Key? key, this.model, this.estabelecimento}) : super(key: key);

  final AuthModel? model;
  final Estabelecimento? estabelecimento;

  @override
  State<PreLoaderScreen> createState() => _PreLoaderScreenState();
}

class _PreLoaderScreenState extends State<PreLoaderScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.estabelecimento == null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SelectEstabelecimentoScreen()));
    }

    SyncController.instance.syncDados(widget.model!.user!, widget.estabelecimento!);

    SyncController.instance.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _conn = context.read<ConnectivityProvider>();

    if (_conn.state == ConnectivityResult.none) {
      return HomeScreen(
        restorationId: '1',
      );
    } else {
      if (SyncController.instance.loaderProgressBar > 0.99) {
        return HomeScreen(
          restorationId: '1',
        );
      } else if (SyncController.instance.loaderProgressBar > 1.99) {
        return LoginScreen();
      }
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: null,
        body: SafeArea(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: SyncController.instance.loaderProgressBar),
                    duration: Duration(milliseconds: 500),
                    builder: ((context, value, _) => CircularPercentIndicator(
                          radius: 140.0,
                          lineWidth: 25.0,
                          animation: false,
                          percent: value,
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: LightColors.kDarkBlue,
                          backgroundColor: LightColors.kDarkYellow,
                          center: Container(
                            width: 200,
                            child: Image.asset(
                              "assets/images/logo_milkroute_tecnico.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ))),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text("${(SyncController.instance.loaderProgressBar * 100).toInt()}%"),
            Text(SyncController.instance.msgCarregamento),
            SizedBox(
              height: 50,
            ),
            LoaderFeedbackCow(
              size: 80,
              mensagem: '',
            )
          ],
        )),
      ),
    );
  }
}
