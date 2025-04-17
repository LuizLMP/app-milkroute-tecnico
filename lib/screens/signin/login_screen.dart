import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/screens/app/popUp.dart';
import 'package:milkroute_tecnico/screens/home/select_estabelecimento.dart';
import 'package:milkroute_tecnico/screens/signin/configuracoes_externas_screen.dart';
import 'package:milkroute_tecnico/screens/signin/recuperarsenha_screen.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.login, this.empresa});

  final String? login, empresa;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _auth;

  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _password, _login, _tenant;

  TextEditingController? _controllerLogin, _controllerEmpresa, _controllerPassword;

  @override
  void initState() {
    _controllerLogin = TextEditingController(text: widget?.login ?? "");
    _controllerEmpresa = TextEditingController(text: widget?.empresa ?? "");
    _controllerPassword = TextEditingController();
    autoLogIn();
    super.initState();
  }

  void autoLogIn() async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _login = _prefs.getString("saved_login") ?? "";
      var _empresa = _prefs.getString("saved_empresa") ?? "";
      var _rememberMe = _prefs.getBool("remember_me") ?? false;

      if (_rememberMe) {
        _controllerLogin?.text = _login ?? "";
        _controllerEmpresa?.text = _empresa ?? "";
      }
    } catch (ex) {
      print(ex);
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    _auth = Provider.of<AuthModel>(context, listen: true);
    final colorScheme = Theme.of(context).colorScheme;

    final loginButon = MaterialButton(
      color: colorScheme.primary,
      onPressed: () async {
        final form = formKey.currentState;

        setState(() {
          _isLoading = true;
        });

        if (form!.validate()) {
          form.save();
          await _auth.login(login: _login, password: _password, tenant: _tenant).then((result) async {
            if (result) {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SelectEstabelecimentoScreen(
                  model: _auth,
                ),
                // PreLoaderScreen(
                //   model: _auth,
                // ),
              ));
            } else {
              setState(() => _isLoading = false);
              _showSnackBar(_auth.errorMessage);
            }
          });
        }
      },
      child: Text("Entrar", style: TextStyle(color: Colors.white), textAlign: TextAlign.center, textScaleFactor: 1.0),
    );

    var loginForm = Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: TextFormField(
                        onSaved: (val) => _login = val?.trim(),
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          return val!.length < 3 ? "Usuário é obrigatório" : null;
                        },
                        controller: _controllerLogin,
                        decoration: InputDecoration(labelText: "Usuário")),
                  ),
                  ListTile(
                    title: TextFormField(
                        onSaved: (val) => _tenant = val,
                        keyboardType: TextInputType.text,
                        validator: (val) {
                          return val!.length < 2 ? "Empresa é obrigatório" : null;
                        },
                        controller: _controllerEmpresa,
                        decoration: InputDecoration(labelText: "Empresa")),
                  ),
                  ListTile(
                    title: TextFormField(
                      obscureText: true,
                      onSaved: (val) => _password = val,
                      validator: (val) {
                        return val!.isEmpty ? "Por favor informe uma senha" : null;
                      },
                      controller: _controllerPassword,
                      decoration: InputDecoration(labelText: "Password"),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Lembrar',
                      textScaleFactor: 1.0,
                    ),
                    trailing: Switch.adaptive(
                      onChanged: _auth.handleRememberMe,
                      value: _auth.rememberMe,
                    ),
                  ),
                ],
              ),
            ),
            _isLoading
                ? LoaderFeedbackCow(
                    mensagem: "Verificando credenciais de acesso...",
                    size: 50,
                  )
                : ListTile(title: loginButon),
            MaterialButton(
                child: Text(
                  'Esqueceu sua senha?',
                  textScaleFactor: 1.0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecuperaSenhaScreen(), fullscreenDialog: true),
                  ).then((success) => success
                      ? showAlertPopup(context, 'Info', "Nova senha realizada com sucesso! Vocé receberá as novas credenciais de acesso no seu e-mail.")
                      : showAlertPopup(context, 'Info', "Não foi possível realizar a recuperação de senha. Procure a empresa responsável!"));
                }),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Milkroute Técnico | Desenvolvido por RF Solution IT', style: TextStyle(fontSize: 11.0)),
                TextButton(
                    onPressed: () => launchUrl(Uri.parse("https://...")),
                    child: Text('Política de Privacidade', style: TextStyle(fontSize: 11.0))),
                TextButton(
                    onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ConfiguracoesExternasScreen(), fullscreenDialog: true),
                        ),
                    child: Text('+ Configurações', style: TextStyle(fontSize: 11.0))),
              ],
            )
          ],
        ));

    return Scaffold(
        appBar: null,
        key: scaffoldKey,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: <Widget>[
              SizedBox(
                height: 40.0,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_auth.isTest)
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/images/logo_milkroute_tecnico_test.png",
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    SizedBox(
                      height: 155.0,
                      child: Image.asset(
                        "assets/images/logo_milkroute_tecnico.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (_auth.isTest)
                    Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text(
                        'Modo de testes ativado',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  loginForm,
                ],
              ),
            ],
          ),
        ));
  }

  Future<bool?> getLoginState() async {
    SharedPreferences pf = await SharedPreferences.getInstance();
    bool? loginState = pf.getBool('loginState');
    return loginState;
  }
}
