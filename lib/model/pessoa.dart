import 'package:milkroute_tecnico/model/cidade.dart';

class Pessoa {
  int? codigoProdutor;
  String? numeroDocumento;
  String? nomeRazaoSocial;
  String? nomeFantasia;
  String? contato;
  String? endereco;
  String? numero;
  String? bairro;
  String? complemento;
  String? pontoReferencia;
  Cidade? cidade;
  String? cep;
  String? email;
  String? telefone;
  String? celular;
  String? telefoneComercial;
  String? inscricaoEstadual;
  String? inscricaoMunicipal;
  String? tipoDocumento;
  String? dataNascimentoFundacao;
  String? nomeMae;
  String? nomePai;

  Pessoa(
      {this.codigoProdutor,
      this.nomeRazaoSocial,
      this.nomeFantasia,
      this.contato,
      this.endereco,
      this.numero,
      this.bairro,
      this.complemento,
      this.pontoReferencia,
      this.cidade,
      this.cep,
      this.email,
      this.telefone,
      this.celular,
      this.telefoneComercial,
      this.inscricaoEstadual,
      this.inscricaoMunicipal,
      this.tipoDocumento,
      this.dataNascimentoFundacao,
      this.numeroDocumento,
      this.nomeMae,
      this.nomePai});

  Pessoa.fromJson(Map<String, dynamic> json) {
    nomeRazaoSocial = json['nomeRazaoSocial'].toString().replaceAll("/", "-");
    nomeFantasia = json['nomeFantasia'].toString().replaceAll("/", "-");
    contato = json['contato'];
    endereco = json['endereco'];
    numero = json['numero'];
    bairro = json['bairro'];
    complemento = json['complemento'];
    pontoReferencia = json['pontoReferencia'];
    cidade = json['cidade'] != null ? Cidade.fromJson(json['cidade']) : null;
    cep = json['cep'];
    email = json['email'];
    telefone = json['telefone'];
    celular = json['celular'];
    telefoneComercial = json['telefoneComercial'];
    inscricaoEstadual = json['inscricaoEstadual'];
    inscricaoMunicipal = json['inscricaoMunicipal'];
    tipoDocumento = json['tipoDocumento'];
    dataNascimentoFundacao = json['dataNascimentoFundacao'];
    numeroDocumento = json['numeroDocumento'];
    nomeMae = json['nomeMae'];
    nomePai = json['nomePai'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nomeRazaoSocial'] = nomeRazaoSocial;
    data['nomeFantasia'] = nomeFantasia;
    data['contato'] = contato;
    data['endereco'] = endereco;
    data['numero'] = numero;
    data['bairro'] = bairro;
    data['complemento'] = complemento;
    data['pontoReferencia'] = pontoReferencia;
    if (cidade != null) {
      data['cidade'] = cidade?.toJson();
    }
    data['cep'] = cep;
    data['email'] = email;
    data['telefone'] = telefone;
    data['celular'] = celular;
    data['telefoneComercial'] = telefoneComercial;
    data['inscricaoEstadual'] = inscricaoEstadual;
    data['inscricaoMunicipal'] = inscricaoMunicipal;
    data['tipoDocumento'] = tipoDocumento;
    data['dataNascimentoFundacao'] = dataNascimentoFundacao;
    data['numeroDocumento'] = numeroDocumento;
    data['nomeMae'] = nomeMae;
    data['nomePai'] = nomePai;
    return data;
  }
}
