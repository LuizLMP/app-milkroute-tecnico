import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Views {
  Widget? viewScreen;
  String? label;
  int? ordem;
  Icon? icone;

  Views({this.viewScreen, this.label, this.ordem, this.icone});

  Views.fromJson(Map<String, dynamic> json) {
    viewScreen = json['viewScreen'];
    label = json['label'];
    ordem = json['Ordem'];
    icone = json['Icone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['viewScreen'] = viewScreen;
    data['label'] = label;
    data['Ordem'] = ordem;
    data['Icone'] = icone;
    return data;
  }
}
