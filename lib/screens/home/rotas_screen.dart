import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/viewsController.dart';
import 'package:milkroute_tecnico/screens/app/app_drawer.dart';
import 'package:milkroute_tecnico/widgets/footer_screen.dart';
import 'package:milkroute_tecnico/widgets/header_screens.dart';
// ignore: implementation_imports
import 'package:provider/src/provider.dart';

class RotasScreen extends StatefulWidget {
  const RotasScreen({super.key});

  @override
  State<RotasScreen> createState() => _RotasScreenState();
}

class _RotasScreenState extends State<RotasScreen> {
  final ViewsController _propsView = ViewsController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final double heightSizeToolbar = 70;
    final _auth = context.read<AuthModel>();

    return Scaffold(
      backgroundColor: LightColors.kLightBlue,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        toolbarHeight: heightSizeToolbar,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          )
        ],
        title: SafeArea(
          bottom: true,
          child: Column(
            children: <Widget>[
              HeaderScreens(
                auth: _auth,
                height: heightSizeToolbar,
                width: width,
                ordemView: ViewsController.instance.viewId,
              ),
            ],
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: <Widget>[
            Text('Rotas View'),
          ],
        ),
      ),
      bottomNavigationBar: FooterScreens(
        views: _propsView,
        textTheme: textTheme,
        colorScheme: colorScheme,
      ),
    );
  }
}
