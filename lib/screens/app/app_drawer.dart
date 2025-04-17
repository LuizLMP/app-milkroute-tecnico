import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/controller/syncController.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/screens/home/cadastro_produtor.dart';
import 'package:milkroute_tecnico/screens/home/select_estabelecimento.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  void initState() {
    super.initState();
    SyncController.instance.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final _auth = context.read<AuthModel>();

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text(
                _auth.tecnico?.nomeTecnico ?? "",
                textScaleFactor: 1.0,
                maxLines: 1,
              ),
              // onTap: () {
              //   Navigator.of(context).popAndPushNamed("/myaccount");
              // },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.change_circle),
              title: Text(
                'Trocar Estabelecimento',
                textScaleFactor: 1.0,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SelectEstabelecimentoScreen(
                          model: _auth,
                        )));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Cadastro de Produtor'),
              onTap: () {
                Navigator.of(context).popAndPushNamed("/cadastro_produtor");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                'Configurações',
                textScaleFactor: 1.0,
              ),
              onTap: () {
                Navigator.of(context).popAndPushNamed("/settings");
              },
            ),
            Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: (SyncController.instance.loaderProgressBar < 0.99)
                  ? Row(children: <Widget>[
                      Text(
                        "Sincronizando Milkroute (${(SyncController.instance.loaderProgressBar * 100).toInt()}%)  ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                          child: Image.asset(
                            "assets/gifs/cowMove.gif",
                            fit: BoxFit.contain,
                            height: 40.0,
                            alignment: Alignment.center,
                          ),
                          onTap: (() async {
                            await SyncController.instance.syncDados(_auth.user!, GlobalData.estabelecimentoSelecionado);
                          })),
                    ])
                  : GestureDetector(
                      child: Row(children: <Widget>[
                        Icon(Icons.sync_sharp),
                        Text(
                          "  Sincronização Manual  ",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Image.asset(
                          "assets/gifs/cowStatic.png",
                          fit: BoxFit.contain,
                          height: 40.0,
                          alignment: Alignment.center,
                        ),
                      ]),
                      onTap: (() async {
                        await SyncController.instance.syncDados(_auth.user!, GlobalData.estabelecimentoSelecionado);
                      })),
            ),
            TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: SyncController.instance.loaderProgressBar),
                duration: Duration(milliseconds: 500),
                builder: ((context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 16.0,
                    ))),
            Divider(),
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text(
                'Logout',
                textScaleFactor: 1.0,
              ),
              onTap: () {
                _auth.logout();
                Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
