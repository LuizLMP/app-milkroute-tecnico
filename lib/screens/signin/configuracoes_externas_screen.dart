import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:provider/provider.dart';

class ConfiguracoesExternasScreen extends StatefulWidget {
  const ConfiguracoesExternasScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracoesExternasScreen> createState() => _ConfiguracoesExternasScreenState();
}

class _ConfiguracoesExternasScreenState extends State<ConfiguracoesExternasScreen> {
  @override
  Widget build(BuildContext context) {
    final _auth = context.read<AuthModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Configurações de Conexão",
          textScaleFactor: 1.0,
        ),
      ),
      body: SingleChildScrollView(
          child: SafeArea(
        child: ListBody(
          children: <Widget>[
            Container(
              height: 10.0,
            ),
            ListTile(
              leading: Icon(Icons.coffee),
              title: Text(
                'Habilitar Modo de Testes',
              ),
              trailing: Switch.adaptive(
                value: _auth.isTest,
                onChanged: (value) {
                  setState(() {
                    _auth.switchProductionTestes(value);
                  });
                },
              ),
            ),
            Divider(height: 20.0),
          ],
        ),
      )),
    );
  }
}
