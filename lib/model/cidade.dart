import 'package:milkroute_tecnico/model/estado.dart';

class Cidade {
  String? nome;
  int? codigoMunIbge;
  Estado? estado;

  Cidade({this.nome, this.codigoMunIbge, this.estado});

  Map<String, dynamic> toMap() {
    return {
      'codigoMunIbge': codigoMunIbge,
      'nome': nome,
      'estado': estado?.sigla,
    };
  }

  Cidade.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
    codigoMunIbge = json['codigoMunIbge'];
    estado = json['estado'] != null ? Estado.fromJson(json['estado']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['codigoMunIbge'] = codigoMunIbge;
    if (estado != null) {
      data['estado'] = estado?.toJson();
    }
    return data;
  }
}
