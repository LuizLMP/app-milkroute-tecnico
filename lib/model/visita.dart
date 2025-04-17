import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/type/status_visita.dart';

class Visita {
  String? idAppTecnico;
  int? idWeb;
  int? nrVisita;
  DateTime? dataInicio = DateTime.parse('0001-01-01 00:00:00');
  Estabelecimento? estabelecimento;
  Propriedade? propriedade;
  Questionario? questionario;
  String? observacoes;
  String? recomendacoes;
  double? latitude;
  double? longitude;
  DateTime? dataFinalizacao = DateTime.parse('0001-01-01 00:00:00');
  List<Resposta>? listRespostas;
  String? statusVisita;
  DateTime? dataCriacao = DateTime.parse('0001-01-01 00:00:00');
  bool? existente;
  bool? novo;
  bool? solicitado;
  bool? agendado;
  bool? finalizado;
  DateTime? dataHoraIU = DateTime.parse('0001-01-01 00:00:00');
  Color? get corStatus => setColorVisita(statusVisita!);

  Visita({
    this.idAppTecnico,
    this.idWeb,
    this.nrVisita,
    this.dataInicio,
    this.estabelecimento,
    this.propriedade,
    this.questionario,
    this.observacoes,
    this.recomendacoes,
    this.latitude,
    this.longitude,
    this.dataFinalizacao,
    this.listRespostas,
    this.statusVisita,
    this.dataCriacao,
    this.existente,
    this.novo,
    this.solicitado,
    this.agendado,
    this.finalizado,
    this.dataHoraIU,
  });

  Visita.fromJson(Map<String, dynamic> json) {
    idWeb = json['id'];
    idAppTecnico = json['idAppTecnico'];
    nrVisita = json['nrVisita'];
    dataInicio = json['dataInicio'] != null ? DateTime.parse(json['dataInicio']) : DateTime.parse('0001-01-01 00:00:00');
    estabelecimento = json['estabelecimento'] != null ? Estabelecimento.fromJson(json['estabelecimento']) : null;
    propriedade = json['propriedade'] != null ? Propriedade.fromJson(json['propriedade']) : null;
    questionario = json['questionario'] != null ? Questionario.fromJson(json['questionario']) : null;

    if (json['questionario_fk'] != null) {
      questionario = json['questionario_fk'] != null ? Questionario(id: json['questionario_fk']) : null;
    }

    observacoes = json['observacoes'];
    recomendacoes = json['recomendacoes'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    dataFinalizacao = json['dataFinalizacao'] != null ? DateTime.parse(json['dataFinalizacao']) : DateTime.parse('0001-01-01 00:00:00');
    if (json['respostas'] != null) {
      listRespostas = <Resposta>[];
      json['respostas'].forEach((v) {
        listRespostas?.add(Resposta.fromJson(v));
      });
    }
    statusVisita = json['statusVisita'];
    dataCriacao = json['dataCriacao'] != null ? DateTime.parse(json['dataCriacao']) : DateTime.parse('0001-01-01 00:00:00');
    existente = json['existente'];
    novo = json['novo'];
    solicitado = json['solicitado'];
    agendado = json['agendado'];
    finalizado = json['finalizado'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = idWeb;
    data['idAppTecnico'] = idAppTecnico;
    data['nrVisita'] = nrVisita;
    data['dataInicio'] = dataInicio.toString();
    if (estabelecimento != null) {
      data['estabelecimento'] = estabelecimento?.toJson();
    }
    if (propriedade != null) {
      data['propriedade'] = propriedade?.toJson();
    }
    if (questionario != null) {
      data['questionario'] = questionario?.toJson();
    }
    data['observacoes'] = observacoes;
    data['recomendacoes'] = recomendacoes;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['dataFinalizacao'] = dataFinalizacao.toString();
    if (listRespostas != null) {
      data['respostas'] = listRespostas?.map((v) => v.toJson()).toList();
    }
    data['statusVisita'] = statusVisita;
    data['dataCriacao'] = dataCriacao.toString();
    data['existente'] = existente;
    data['novo'] = novo;
    data['solicitado'] = solicitado;
    data['agendado'] = agendado;
    data['finalizado'] = finalizado;
    return data;
  }

  Color setColorVisita(String statusVisita) {
    switch (statusVisita) {
      case "AGENDADO":
        return Color.fromARGB(255, 230, 239, 255);

      case "SOLICITADO":
        return Color.fromARGB(255, 255, 233, 144);

      case "FINALIZADO":
        return Colors.lightGreen.shade400;

      case "CONFIRMADO":
        return Color.fromARGB(255, 158, 188, 240);

      default:
        return Colors.white;
    }
  }

  StatusVisita setStatusVisita(String statusVisita) {
    switch (statusVisita) {
      case "AGENDADO":
        return StatusVisita.Agendada;
      case "SOLICITADO":
        return StatusVisita.Solicitada;
      case "FINALIZADO":
        return StatusVisita.Concluida;
      case "CONFIRMADO":
        return StatusVisita.Agendada;
      case "TRANSMITIDA":
        return StatusVisita.Transmitida;
      default:
        return StatusVisita.Iniciada;
    }
  }
}
