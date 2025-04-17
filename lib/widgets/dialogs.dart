import 'package:flutter/material.dart';

dialog2Opt(BuildContext context, String nomeBotaoCancelar, String nomeBotaoContinuar, String dialogTitle, String dialogMessage, var actionCancel, Widget widgetConfirm) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(nomeBotaoCancelar),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  if (widgetConfirm == null) {
    widgetConfirm = TextButton(
      child: Text(nomeBotaoContinuar),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget continueButton = TextButton(
    child: Text(nomeBotaoContinuar),
    onPressed: () async {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => widgetConfirm));
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(dialogTitle),
    content: Text(dialogMessage),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

dialog1Opt(BuildContext context, String nomeBotaoContinuar, String dialogTitle, String dialogMessage, [var actionButton]) {
  // set up the buttons

  Widget continueButton = TextButton(
    child: Text(nomeBotaoContinuar),
    onPressed: () async {
      if (actionButton != null) {
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => actionButton));
      }
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(dialogTitle),
    content: Text(dialogMessage),
    actions: [
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

dialogInputText(BuildContext context, String nomeBotaoCancelar, String nomeBotaoContinuar, String dialogTitle, String dialogMessage, var actionCancel, Widget widgetConfirm) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: Text(nomeBotaoCancelar),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: Text(nomeBotaoContinuar),
    onPressed: () async {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => widgetConfirm));
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(dialogTitle),
    content: Text(dialogMessage),
    actions: [
      cancelButton,
      continueButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void dialogInfo(BuildContext context, String nomeBotaoContinuar, Widget dialogTitle, Widget dialogMessage) {
  // set up the buttons
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: dialogTitle,
    content: dialogMessage,
    actions: [
      TextButton(
        child: Text(nomeBotaoContinuar),
        onPressed: () async {
          Navigator.of(context).pop();
        },
      )
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
