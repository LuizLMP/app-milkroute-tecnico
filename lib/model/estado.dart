import 'package:milkroute_tecnico/model/pais.dart';

class Estado {
  String? sigla;
  String? nome;
  Pais? pais;

  Estado({this.nome, this.sigla, this.pais});

  Estado.fromJson(Map<String, dynamic> json) {
    sigla = json['sigla'];
    nome = json['nome'];
    pais = json['pais'] != null ? Pais.fromJson(json['pais']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sigla'] = sigla;
    data['nome'] = nome;
    if (pais != null) {
      data['pais'] = pais?.toJson();
    }
    return data;
  }
}
