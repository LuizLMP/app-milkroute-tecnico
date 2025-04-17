import 'dart:async';
import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/screens/app/popUp.dart';
import 'package:provider/provider.dart';

class CreateAccountScreen extends StatefulWidget {
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  String? _cpfCnpj, _empresa;

  final formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController? _controllerLogin, _controllerEmpresa;

  @override
  initState() {
    _controllerLogin = TextEditingController();
    _controllerEmpresa = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _auth = Provider.of<AuthModel>(context, listen: true);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          key: PageStorageKey("Divider 1"),
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "Bem vindo(a)!",
                    style: TextStyle(color: colorScheme.primary, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    color: Colors.transparent,
                    height: 20.0,
                  ),
                  Text("Crie uma conta e comece a visualizar suas informações.", style: TextStyle(color: colorScheme.secondaryContainer, fontSize: 15, fontWeight: FontWeight.bold))
                ])),
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                            title: TextFormField(
                          decoration: InputDecoration(labelText: 'CPF/CNPJ'),
                          validator: (val) => val!.isEmpty ? 'CPF/CNPJ é obrigatório' : null,
                          onSaved: (val) => _cpfCnpj = val,
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          controller: _controllerLogin,
                          autocorrect: false,
                        )),
                        ListTile(
                            title: TextFormField(
                          decoration: InputDecoration(labelText: 'Empresa'),
                          validator: (val) => val!.isEmpty ? 'Empresa é obrigatório' : null,
                          onSaved: (val) => _empresa = val,
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          controller: _controllerEmpresa,
                          autocorrect: false,
                        )),
                      ],
                    ),
                  ),
                  ListTile(
                    title: MaterialButton(
                      color: colorScheme.primary,
                      onPressed: () async {
                        final form = formKey.currentState;
                        if (form!.validate()) {
                          form.save();
                          final snackbar = SnackBar(
                            duration: Duration(seconds: 30),
                            content: Row(
                              children: <Widget>[CircularProgressIndicator(), Text("  Signing Up...")],
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);

                          _auth.newaccoutn(cpfCnpj: _cpfCnpj.toString().toLowerCase().trim(), empresa: _empresa!).then((result) async {
                            if (result) {
                              final snackbar = SnackBar(
                                duration: Duration(seconds: 3),
                                content: Row(
                                  children: <Widget>[CircularProgressIndicator(), Text("  Signing Up...")],
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackbar);

                              await Future.delayed(Duration(seconds: 3));
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              showAlertPopup(context, 'Info', _auth.errorMessage);
                            }
                          });
                        }
                      },
                      child: Text(
                        'Cadastrar',
                        textScaleFactor: 1.0,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ]))
          ],
        ),
      ),
    );
  }
}
