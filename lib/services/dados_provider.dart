import 'package:flutter/cupertino.dart';

class FormDataProvider with ChangeNotifier {
  // Dados para pagamento
  String bancoNumero = '';
  String agenciaNumero = '';
  String dvAgencia = '';
  String contaCorrente = '';
  String dvContaBancaria = '';
  String sigla = '';
  String diaPagamento = '';
  
  // Produção
  String volumeInicial = '';
  String capacidadeResfriador = '';
  bool tqExpansao = false;
  bool tqImersao = false;
  String numeroOrdenhas = '';

  // Informações de contato e localização
  String bairro = '';
  String celular = '';
  String cep = '';
  String complemento = '';
  String endereco = '';
  double latitude = 0.0;
  double longitude = 0.0;

  // Dados gerais da propriedade
  String nomePropriedade = '';
  String nomeRazaoSocial = '';
  String nrRegProdutor = '';
  String numero = '';
  String numeroDocumento = '';
  String inscEstadual = '';
  String rg = '';
  String email = '';
  String observacoes = '';

  // Informações da cidade
  String cidadeNome = '';
  int cidadeCodigoMunIbge = 0;
  String estadoNome = '';
  String paisNome = '';

  // Status da propriedade
  bool aprovado = false;
  bool existente = true;
  bool novo = false;
  bool pendente = false;
  bool reprovado = false;
  String situacao = '';
  String situacaoPropriedade = '';

  // Outros
  String nirf = '';
  String origem = '';
  String messageProcessamento = '';
  int id = 0;
  DateTime dataAtualizacao = DateTime.now();
  DateTime dataCadastro = DateTime.now();

  // Métodos de atualização para cada campo

  // Dados para pagamento
  void updateBancoNumero(String value) {
    bancoNumero = value;
    notifyListeners();
  }

  void updateAgenciaNumero(String value) {
    agenciaNumero = value;
    notifyListeners();
  }

  void updateDvAgencia(String value) {
    dvAgencia = value;
    notifyListeners();
  }

  void updateContaCorrente(String value) {
    contaCorrente = value;
    notifyListeners();
  }

  void updateDvContaBancaria(String value) {
    dvContaBancaria = value;
    notifyListeners();
  }

  void updateUf(String value) {
    sigla = value;
    notifyListeners();
  }

  void updateDiaPagamento(String value) {
    diaPagamento = value;
    notifyListeners();
  }

  // Produção
  void updateVolumeInicial(String value) {
    volumeInicial = value;
    notifyListeners();
  }

  void updateCapacidadeResfriador(String value) {
    capacidadeResfriador = value;
    notifyListeners();
  }

  void updateTqExpansao(bool value) {
    tqExpansao = value;
    notifyListeners();
  }

  void updateTqImersao(bool value) {
    tqImersao = value;
    notifyListeners();
  }

  void updateNumeroOrdenhas(String value) {
    numeroOrdenhas = value;
    notifyListeners();
  }

  // Informações de contato e localização
  void updateBairro(String value) {
    bairro = value;
    notifyListeners();
  }

  void updateCelular(String value) {
    celular = value;
    notifyListeners();
  }

  void updateCep(String value) {
    cep = value;
    notifyListeners();
  }

  void updateComplemento(String value) {
    complemento = value;
    notifyListeners();
  }

  void updateEndereco(String value) {
    endereco = value;
    notifyListeners();
  }

  void updateLatitude(double value) {
    latitude = value;
    notifyListeners();
  }

  void updateLongitude(double value) {
    longitude = value;
    notifyListeners();
  }

  // Dados gerais da propriedade
  void updateNomePropriedade(String value) {
    nomePropriedade = value;
    notifyListeners();
  }

  void updateNomeRazaoSocial(String value) {
    nomeRazaoSocial = value;
    notifyListeners();
  }

  void updateNrRegProdutor(String value) {
    nrRegProdutor = value;
    notifyListeners();
  }

  void updateNumero(String value) {
    numero = value;
    notifyListeners();
  }

  void updateNumeroDocumento(String value) {
    numeroDocumento = value;
    notifyListeners();
  }

  void updateInscEstadual(String value) {
    inscEstadual = value;
    notifyListeners();
  }

  void updateRg(String value) {
    rg = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updateObservacoes(String value) {
    observacoes = value;
    notifyListeners();
  }

  // Informações da cidade
  void updateCidadeNome(String value) {
    cidadeNome = value;
    notifyListeners();
  }

  void updateCidadeCodigoMunIbge(int value) {
    cidadeCodigoMunIbge = value;
    notifyListeners();
  }

  void updateEstadoNome(String value) {
    estadoNome = value;
    notifyListeners();
  }

  void updatePaisNome(String value) {
    paisNome = value;
    notifyListeners();
  }

  // Status da propriedade
  void updateAprovado(bool value) {
    aprovado = value;
    notifyListeners();
  }

  void updateExistente(bool value) {
    existente = value;
    notifyListeners();
  }

  void updateNovo(bool value) {
    novo = value;
    notifyListeners();
  }

  void updatePendente(bool value) {
    pendente = value;
    notifyListeners();
  }

  void updateReprovado(bool value) {
    reprovado = value;
    notifyListeners();
  }

  void updateSituacao(String value) {
    situacao = value;
    notifyListeners();
  }

  void updateSituacaoPropriedade(String value) {
    situacaoPropriedade = value;
    notifyListeners();
  }

  // Outros
  void updateNirf(String value) {
    nirf = value;
    notifyListeners();
  }

  void updateOrigem(String value) {
    origem = value;
    notifyListeners();
  }

  void updateMessageProcessamento(String value) {
    messageProcessamento = value;
    notifyListeners();
  }

  void updateId(int value) {
    id = value;
    notifyListeners();
  }

  void updateDataAtualizacao(DateTime value) {
    dataAtualizacao = value;
    notifyListeners();
  }

  void updateDataCadastro(DateTime value) {
    dataCadastro = value;
    notifyListeners();
  }
}
