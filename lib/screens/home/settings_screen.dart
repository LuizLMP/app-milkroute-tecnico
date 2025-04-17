import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:provider/provider.dart';

// Stateful widget for managing name data
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key, this.restorationId}) : super(key: key);
  final String? restorationId;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final _auth = context.read<AuthModel>();

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Configurações",
            textScaleFactor: 1.0,
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ),
        body: SingleChildScrollView(
            child: SafeArea(
          child: ListBody(
            children: <Widget>[
              Container(
                height: 10.0,
              ),
              if (!kIsWeb)
                ListTile(
                  leading: Icon(Icons.fingerprint),
                  title: Text(
                    'Habilitar Biometria',
                    textScaleFactor: 1.0,
                  ),
                  subtitle: Platform.isIOS
                      ? Text(
                          'TouchID or FaceID',
                          textScaleFactor: 1.0,
                        )
                      : Text(
                          'Impressao Digital',
                          textScaleFactor: 1.0,
                        ),
                  trailing: Switch.adaptive(
                    value: _auth.isBioSetup,
                    onChanged: (value) {
                      setState(() {
                        _auth.handleIsBioSetup(value);
                      });
                    },
                  ),
                ),
              Divider(
                height: 20.0,
              )
            ],
          ),
        )),
      ),
    );
  }
}
