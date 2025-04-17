import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/connectivityController.dart';
import 'package:milkroute_tecnico/screens/home/cadastro_produtor.dart';

import 'package:milkroute_tecnico/screens/home/select_estabelecimento.dart';
import 'package:milkroute_tecnico/screens/home/settings_screen.dart';
import 'package:milkroute_tecnico/screens/signin/login_screen.dart';
import 'package:milkroute_tecnico/services/dados_provider.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:milkroute_tecnico/screens/home/select_formulario_screen.dart';

void main() {
  // Configura as cores da barra de status e navegação
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: LightColors.kDarkBlue, // Cor da barra de navegação
    statusBarColor: Color(0xff033249), // Cor da barra de status
  ));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthModel _authModel = AuthModel();
  final ConnectivityProvider _connectivityProvider = ConnectivityProvider(Connectivity());

  @override
  void initState() {
    super.initState();
    _initializeModels();
  }

  void _initializeModels() {
    _loadModelSettings(_authModel.loadSettings, "Error Loading Settings");
    _loadModelSettings(_connectivityProvider.init, "Error Loading Connectivity");
  }

  void _loadModelSettings(Function loadFunction, String errorMessage) {
    try {
      loadFunction();
    } catch (ex) {
      print("$errorMessage: $ex");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthModel>.value(value: _authModel),
          ChangeNotifierProvider<ConnectivityProvider>.value(value: _connectivityProvider),
          ChangeNotifierProvider(
            create: (_) => FormDataProvider(),
            child: MyApp(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: [
            const Locale('pt'),
          ],
          theme: ThemeData(
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: LightColors.kDarkBlue,
            onPrimary: Colors.white, // Textos brancos no fundo azul escuro
            secondary: Color.fromARGB(127, 3, 50, 73),
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: LightColors.kDarkBlue, // Textos pretos no fundo branco
            tertiary: Colors.purple,
            onTertiary: Colors.white,
            error: Colors.redAccent,
            onError: Colors.white,
            background: Colors.white,
            onBackground: LightColors.kDarkBlue, // Textos pretos no fundo branco
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,

          home: Consumer<AuthModel>(builder: (context, authModel, child) {
            if (authModel.user != null && authModel.tecnico != null) {
              return SelectEstabelecimentoScreen(model: authModel);
            }
            return LoginScreen();
          }),
          routes: <String, WidgetBuilder>{
            '/login': (BuildContext context) => LoginScreen(),
            '/home': (BuildContext context) => CadastroPropriedadeScreen(),
            '/cadastro_produtor': (context) => CadastroPropriedadeScreen(),
            '/select_formulario': (BuildContext context) => SelectFormularioScreen(),
            '/settings': (BuildContext context) => SettingsScreen(),
          },
        ),
      ),
    );
  }
}
