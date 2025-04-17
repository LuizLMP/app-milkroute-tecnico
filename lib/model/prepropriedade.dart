import 'package:milkroute_tecnico/model/cidade.dart';

class PrePropriedade {
  int? id;
  String? numeroDocumento;
  String? inscEstadual;
  String? rg;
  String? nirf;
  String? nrRegProdutor;
  String? nomeRazaoSocial;
  String? nomePropriedade;
  String? endereco;
  String? numero;
  String? bairro;
  String? complemento;
  Cidade? cidade;
  String? cep;
  String? telefone;
  String? celular;
  String? email;
  String? banco;
  String? agencia;
  String? dvAgencia;
  String? contaBancaria;
  String? dvContaBancaria;
  String? observacoes;
  bool? aprovado;
  bool? reprovado;
  String? dataCadastro;
  String? dataAtualizacao;
  String? messageProcessamento;
  String? situacao;
  String? situacaoPropriedade;
  String? origem;
  int? diaPagamento;
  double? volumeInicial;
  double? capacidadeResfriador;
  int? nrOrdenhas;
  bool? tanqueExpansao;
  bool? tanqueImersao;
  double? latitude;
  double? longitude;
  bool? novo;
  bool? existente;
  bool? pendente;

  PrePropriedade(
      {this.id,
      this.numeroDocumento,
      this.inscEstadual,
      this.rg,
      this.nirf,
      this.nrRegProdutor,
      this.nomeRazaoSocial,
      this.nomePropriedade,
      this.endereco,
      this.numero,
      this.bairro,
      this.complemento,
      this.cidade,
      this.cep,
      this.telefone,
      this.celular,
      this.email,
      this.banco,
      this.agencia,
      this.dvAgencia,
      this.contaBancaria,
      this.dvContaBancaria,
      this.observacoes,
      this.aprovado,
      this.reprovado,
      this.dataCadastro,
      this.dataAtualizacao,
      this.messageProcessamento,
      this.situacao,
      this.situacaoPropriedade,
      this.origem,
      this.diaPagamento,
      this.volumeInicial,
      this.capacidadeResfriador,
      this.nrOrdenhas,
      this.tanqueExpansao,
      this.tanqueImersao,
      this.latitude,
      this.longitude,
      this.novo,
      this.existente,
      this.pendente});

  PrePropriedade.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numeroDocumento = json['numeroDocumento'];
    inscEstadual = json['inscEstadual'];
    rg = json['rg'];
    nirf = json['nirf'];
    nrRegProdutor = json['nrRegProdutor'];
    nomeRazaoSocial = json['nomeRazaoSocial'];
    nomePropriedade = json['nomePropriedade'];
    endereco = json['endereco'];
    numero = json['numero'];
    bairro = json['bairro'];
    complemento = json['complemento'];
    cidade = json['cidade'] != null ? Cidade.fromJson(json['cidade']) : null;
    cep = json['cep'];
    telefone = json['telefone'];
    celular = json['celular'];
    email = json['email'];
    banco = json['banco'];
    agencia = json['agencia'];
    dvAgencia = json['dvAgencia'];
    contaBancaria = json['contaBancaria'];
    dvContaBancaria = json['dvContaBancaria'];
    observacoes = json['observacoes'];
    aprovado = json['aprovado'];
    reprovado = json['reprovado'];
    dataCadastro = json['dataCadastro'];
    dataAtualizacao = json['dataAtualizacao'];
    messageProcessamento = json['messageProcessamento'];
    situacao = json['situacao'];
    situacaoPropriedade = json['situacaoPropriedade'];
    origem = json['origem'];
    diaPagamento = json['diaPagamento'];
    volumeInicial = json['volumeInicial'];
    capacidadeResfriador = json['capacidadeResfriador'];
    nrOrdenhas = json['nrOrdenhas'];
    tanqueExpansao = json['tanqueExpansao'];
    tanqueImersao = json['tanqueImersao'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    novo = json['novo'];
    existente = json['existente'];
    pendente = json['pendente'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['numeroDocumento'] = numeroDocumento;
    data['inscEstadual'] = inscEstadual;
    data['rg'] = rg;
    data['nirf'] = nirf;
    data['nrRegProdutor'] = nrRegProdutor;
    data['nomeRazaoSocial'] = nomeRazaoSocial;
    data['nomePropriedade'] = nomePropriedade;
    data['endereco'] = endereco;
    data['numero'] = numero;
    data['bairro'] = bairro;
    data['complemento'] = complemento;
    if (cidade != null) {
      data['cidade'] = cidade?.toJson();
    }
    data['cep'] = cep;
    data['telefone'] = telefone;
    data['celular'] = celular;
    data['email'] = email;
    data['banco'] = banco;
    data['agencia'] = agencia;
    data['dvAgencia'] = dvAgencia;
    data['contaBancaria'] = contaBancaria;
    data['dvContaBancaria'] = dvContaBancaria;
    data['observacoes'] = observacoes;
    data['aprovado'] = aprovado;
    data['reprovado'] = reprovado;
    data['dataCadastro'] = dataCadastro;
    data['dataAtualizacao'] = dataAtualizacao;
    data['messageProcessamento'] = messageProcessamento;
    data['situacao'] = situacao;
    data['situacaoPropriedade'] = situacaoPropriedade;
    data['origem'] = origem;
    data['diaPagamento'] = diaPagamento;
    data['volumeInicial'] = volumeInicial;
    data['capacidadeResfriador'] = capacidadeResfriador;
    data['nrOrdenhas'] = nrOrdenhas;
    data['tanqueExpansao'] = tanqueExpansao;
    data['tanqueImersao'] = tanqueImersao;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['novo'] = novo;
    data['existente'] = existente;
    data['pendente'] = pendente;
    return data;
  }
}
