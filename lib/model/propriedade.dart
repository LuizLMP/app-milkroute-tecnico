import 'package:milkroute_tecnico/model/Banco.dart';
import 'package:milkroute_tecnico/model/pessoa.dart';

class Propriedade {
  int? id;
  String? tenant;
  Pessoa? pessoa;
  Banco? banco;
  int? codProdutor;
  String? nomePropriedade;
  bool? ativa;
  double? latitude;
  double? longitude;
  Propriedade? propriedadeBeneficiaria;
  String? dataCadastro;
  double? volumeMedio;
  String? nomeAbreviado;
  String? situacao;
  String? codigoNomeProdutor;
  String? firstName;
  String? lastName;
  bool? possuiBeneficiario;

  Propriedade(
      {this.id,
      this.pessoa,
      this.codProdutor,
      this.nomePropriedade,
      this.ativa,
      this.latitude,
      this.longitude,
      this.propriedadeBeneficiaria,
      this.dataCadastro,
      this.volumeMedio,
      this.nomeAbreviado,
      this.situacao,
      this.codigoNomeProdutor,
      this.firstName,
      this.lastName,
      this.possuiBeneficiario});

  Propriedade.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pessoa = json['pessoa'] != null ? Pessoa.fromJson(json['pessoa']) : null;
    codProdutor = json['codProdutor'];
    nomePropriedade = json['nomePropriedade'];
    ativa = json['ativa'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    propriedadeBeneficiaria = json['propriedadeBeneficiaria'] != null ? Propriedade.fromJson(json['propriedadeBeneficiaria']) : null;
    dataCadastro = json['dataCadastro'];
    volumeMedio = double.tryParse(json['volumeMedio'].toString());
    nomeAbreviado = json['nomeAbreviado'];
    situacao = json['situacao'];
    codigoNomeProdutor = json['codigoNomeProdutor'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    possuiBeneficiario = json['possuiBeneficiario'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (pessoa != null) {
      data['pessoa'] = pessoa?.toJson();
    }
    data['codProdutor'] = codProdutor;
    data['nomePropriedade'] = nomePropriedade;
    data['ativa'] = ativa;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    if (propriedadeBeneficiaria != null) {
      data['propriedadeBeneficiaria'] = propriedadeBeneficiaria?.toJson();
    }
    data['dataCadastro'] = dataCadastro;
    data['volumeMedio'] = volumeMedio;
    data['nomeAbreviado'] = nomeAbreviado;
    data['situacao'] = situacao;
    data['codigoNomeProdutor'] = codigoNomeProdutor;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['possuiBeneficiario'] = possuiBeneficiario;

    return data;
  }
}
