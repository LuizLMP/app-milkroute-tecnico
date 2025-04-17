import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/controller/viewsController.dart';

class OpcoesButton extends StatelessWidget {
  final Color? cardColor;
  final String? title;
  final IconData? icon;
  final Widget? telas;
  final int? viewIdCard;

  OpcoesButton({this.cardColor, this.title, this.icon, this.telas, this.viewIdCard});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () async {
          ViewsController.instance.viewId = viewIdCard!;
          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => telas!));
        },
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
          padding: EdgeInsets.all(15.0),
          //height: 96,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[CircleAvatar(radius: 25.0, backgroundColor: Colors.white, child: Icon(icon, size: 30.0, color: Colors.deepOrange))]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: LightColors.kDarkBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
