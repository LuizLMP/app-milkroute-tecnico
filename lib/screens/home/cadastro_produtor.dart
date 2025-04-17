import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/banco_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/cidade_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/estado_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/prepropriedade_dao_impl.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/banco.dart';
import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/model/estado.dart';
import 'package:milkroute_tecnico/model/prepropriedade.dart';
import 'package:milkroute_tecnico/domain/interfaces/prepropriedade_dao.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/services/prepropriedade_services.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';

class CadastroPropriedadeScreen extends StatefulWidget {
  final String? tenant;
  final User? user;
  final PrePropriedadeDAO? prePropriedadeDAO;

  const CadastroPropriedadeScreen({
    super.key,
    this.tenant,
    this.user,
    this.prePropriedadeDAO,
  });

  @override
  _CadastroPropriedadeScreenState createState() =>
      _CadastroPropriedadeScreenState();
}

class _CadastroPropriedadeScreenState extends State<CadastroPropriedadeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Estado> _estados = [];
  List<Cidade> _cidades = [];
  List<Banco> _bancos = [];
  Estado? _estadoSelecionado;
  Estado? _estadoAnterior;
  Cidade? _cidadeSelecionada;
  Banco? _bancoSelecionado;
  PrePropriedadeService? _apiPrePropriedade;
  Future<List<Cidade>>? _futureCidades;
  ScrollController? _scrollController;
  bool _isEstadoSelecionadoPelaPrimeiraVez = true;


  // Controladores de texto para os campos de cada aba
  final TextEditingController _agenciaController = TextEditingController();
  final TextEditingController _dvAgenciaController = TextEditingController();
  final TextEditingController _contaController = TextEditingController();
  final TextEditingController _dvContaController = TextEditingController();
  final TextEditingController _volumeInicialController =TextEditingController();
  final TextEditingController _capacidadeResfriadorController =TextEditingController();
  final TextEditingController _nrOrdenhasController = TextEditingController();
  final TextEditingController _diaPagamentoController = TextEditingController();
  final TextEditingController _nrRegProdutorController =TextEditingController();
  final TextEditingController _nirfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  late TextEditingController _cidadeController;
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _rgController = TextEditingController();
  final TextEditingController _inscricaoEstadualController =
      TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  bool _tanqueExpansao = false;
  bool _tanqueImersao = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 5, vsync: this);
     _cidadeController = TextEditingController();
  }

  Future<List<Estado>> carregarEstados() async {
    List<Estado> listEstados = [];

    listEstados =
        await EstadoDAOImpl().selectAll(Estado(), TipoConsultaDB.Tudo);
    listEstados.sort((a, b) {
      return a.sigla!.compareTo(b.sigla!);
    });

    return listEstados;
  }

  Future<List<Cidade>> carregarCidades(Estado _estado) async {
    List<Cidade> listCidades = [];
    await Future.delayed(Duration(seconds: 1));
    listCidades = await CidadeDAOImpl().selectByEstado(Cidade(), _estado);
    return listCidades;
  }

  Future<List<Banco>> carregarBancos() async {
    List<Banco> listBancos = [];

    listBancos = await BancoDAOImpl().selectAll(Banco(), TipoConsultaDB.Tudo);

    return listBancos;
  }

  Future<void> adicionarPrePropriedade(PrePropriedade prePropriedade) async {
    await PrePropriedadeDAOImpl().insert(prePropriedade);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _saveFormData() async {
    // Cria um objeto `PrePropriedade` com os dados preenchidos no formulário
    PrePropriedade prePropriedade = PrePropriedade(
      agencia: _agenciaController.text,
      dvAgencia: _dvAgenciaController.text,
      contaBancaria: _contaController.text,
      dvContaBancaria: _dvContaController.text,
      volumeInicial: double.tryParse(_volumeInicialController.text) ??
          0.0, // Permanece igual
      capacidadeResfriador:
          double.tryParse(_capacidadeResfriadorController.text) ?? 0.0,
      nrOrdenhas: int.tryParse(_nrOrdenhasController.text) ?? 0,
      tanqueExpansao: _tanqueExpansao,
      tanqueImersao: _tanqueImersao,
      diaPagamento: int.tryParse(_diaPagamentoController.text) ?? 0,
      nrRegProdutor: _nrRegProdutorController.text,
      nirf: _nirfController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      cep: _cepController.text,
      complemento: _complementoController.text,
      endereco: _enderecoController.text,
      numero: _numeroController.text,
      rg: _rgController.text,
      inscEstadual: _inscricaoEstadualController.text,
      observacoes: _observacoesController.text,
    );

    // Salva localmente no banco de dados SQLite
    if (widget.prePropriedadeDAO != null) {
      await adicionarPrePropriedade(prePropriedade);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados salvos localmente com sucesso!')),
      );
    }
  }

  void _sendDataToAPI() async {
    // Monta um mapa com os dados do objeto `PrePropriedade` para enviar à API
    Map<String, dynamic> produtorData = {
      'agencia': _agenciaController.text,
      'dvAgencia': _dvAgenciaController.text,
      'contaBancaria': _contaController.text,
      'dvContaBancaria': _dvContaController.text,
      'volumeInicial': double.tryParse(_volumeInicialController.text) ?? 0.0,
      'capacidadeResfriador': _capacidadeResfriadorController.text,
      'nrOrdenhas': int.tryParse(_nrOrdenhasController.text) ?? 0,
      'tanqueExpansao': _tanqueExpansao,
      'tanqueImersao': _tanqueImersao,
      'diaPagamento': int.tryParse(_diaPagamentoController.text) ?? 0,
      'nrRegProdutor': _nrRegProdutorController.text,
      'nirf': _nirfController.text,
      'email': _emailController.text,
      'telefone': _telefoneController.text,
      'cep': _cepController.text,
      'complemento': _complementoController.text,
      'endereco': _enderecoController.text,
      'numero': _numeroController.text,
      'rg': _rgController.text,
      'inscricaoEstadual': _inscricaoEstadualController.text,
      'observacoes': _observacoesController.text,
    };

    // Tenta enviar os dados para a API
    try {
      bool success = await _apiPrePropriedade!.cadastrarProdutor(
        produtorData,
        widget.tenant!,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados enviados para a API com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar dados: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: Text('Cadastro de Propriedade'),
        bottom: TabBar(
          indicatorColor: colorScheme.onPrimary,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.5),
          controller: _tabController,
          tabs: [
            Tab(text: 'Básico'),
            Tab(text: 'Produção'),
            Tab(text: 'Banco'),
            Tab(text: 'Outros'),
            Tab(text: 'Finalizar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDadosPessoaisTab(0), // Correct tabIndex
          _buildProducaoTab(1), // Correct tabIndex
          _buildDadosBancariosTab(2), // Correct tabIndex
          _buildOutrosDadosTab(3), // Correct tabIndex
          _buildFinalizarTab(4), // Correct tabIndex
        ],
      ),
    );
  }

  Widget _buildDadosPessoaisTab(int tabIndex) {
    return _buildTabContent(
      context,
      'Próximo',
      [
        FutureBuilder(
          future: carregarEstados(),
          builder: (context, listEstados) {
            if (listEstados.hasData) {
              if (listEstados.data!.isNotEmpty) {
                return DropdownButtonFormField<Estado>(
                  decoration: InputDecoration(labelText: "Selecione um Estado"),
                  icon: Icon(Icons.arrow_downward),
                  value: (_estadoSelecionado == null)
                      ? null
                      : (listEstados.data?.where((element) =>
                              element.sigla == _estadoSelecionado?.sigla))
                          ?.toList()[0],
                  items: listEstados.data
                      ?.map<DropdownMenuItem<Estado>>((Estado estado) {
                    String? descricaoDropDown = estado.sigla;

                    return DropdownMenuItem<Estado>(
                      value: estado,
                      child: Text(descricaoDropDown!),
                    );
                  }).toList(),
                  onChanged: (Estado? newValue) {
                    setState(() {
                      _estadoSelecionado = newValue;
                      _futureCidades = carregarCidades(_estadoSelecionado!);

                      _cidadeSelecionada = null;
                      _cidadeController.clear();
                      _cepController.clear();
                      _complementoController.clear();
                      _enderecoController.clear();
                      _numeroController.clear();

                      _estadoAnterior = newValue;
                      _isEstadoSelecionadoPelaPrimeiraVez = false;
                    });
                  },
                );
              } else {
                return Text(
                  "Nenhum estado encontrado.",
                  textAlign: TextAlign.center,
                );
              }
            } else {
              return LoaderFeedbackCow(
                mensagem: "Carregando Estados",
                size: 60,
              );
            }
          },
        ),
        FutureBuilder(
          future: _futureCidades,
          builder: (context, listCidades) {
            if (listCidades.hasData && listCidades.data!.isNotEmpty) {
              return Autocomplete<Cidade>(
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    _cidadeController = controller;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(labelText: "Selecione uma Cidade"),
                    );
                  },
                displayStringForOption: (Cidade cidade) => cidade.nome!,
                initialValue: TextEditingValue(
                  text: _cidadeSelecionada?.nome ??
                      "",
                ),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<Cidade>.empty();
                  }
                  return listCidades.data!.where((Cidade cidade) =>
                      (cidade.nome)!
                          .toLowerCase()
                          .toString()
                          .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (Cidade cidade) {
                  setState(() {
                    _cidadeSelecionada = cidade;
                    GlobalData.cidadeSelecionada = cidade;
                    _scrollToFocus();
                  });
                },
              );
            } else {
              return Text(
                "",
                textAlign: TextAlign.center,
              );
            }
          },
        ),
        _buildTextField(_cepController, 'CEP', TextInputType.number),
        _buildTextField(
            _complementoController, 'Complemento', TextInputType.text),
        _buildTextField(_enderecoController, 'Endereço', TextInputType.text),
        _buildTextField(_numeroController, 'Número', TextInputType.text),
      ],
      tabIndex,
    );
  }

  Widget _buildOutrosDadosTab(int tabIndex) {
    return _buildTabContent(
      context,
      'Próximo',
      [
        _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
        _buildTextField(_telefoneController, 'Telefone', TextInputType.phone),
        _buildTextField(
            _diaPagamentoController, 'Dia do Pagamento', TextInputType.number),
        _buildTextField(_nrRegProdutorController,
            'Número de Registro do Produtor', TextInputType.text),
        _buildTextField(_nirfController, 'NIRF', TextInputType.text),
        _buildTextField(_rgController, 'RG', TextInputType.text),
        _buildTextField(_inscricaoEstadualController, 'Inscrição Estadual',
            TextInputType.text),
        _buildTextField(
            _observacoesController, 'Observações', TextInputType.text),
      ],
      tabIndex,
    );
  }

  Widget _buildDadosBancariosTab(int tabIndex) {
    return _buildTabContent(
      context,
      'Próximo',
      [
        FutureBuilder(
          future: carregarBancos(),
          builder: (context, listBancos) {
            if (listBancos.hasData) {
              if (listBancos.data!.isNotEmpty) {
                return DropdownButtonFormField<Banco>(
                  decoration: InputDecoration(labelText: "Selecione um Banco"),
                  icon: Icon(Icons.arrow_downward),
                  value: (_bancoSelecionado == null)
                      ? null
                      : (listBancos.data?.where((element) =>
                          element.codFebraban ==
                          _bancoSelecionado?.codFebraban))?.toList()[0],
                  items: listBancos.data
                      ?.map<DropdownMenuItem<Banco>>((Banco banco) {
                    String? descricaoDropDown = banco.nomeBanco;
                    return DropdownMenuItem<Banco>(
                      value: banco,
                      child: Text(descricaoDropDown!),
                    );
                  }).toList(),
                  onChanged: (Banco? newValue) async {
                    setState(() {
                      _bancoSelecionado = newValue;
                    });
                  },
                );
              } else {
                return Text(
                  "Nenhum banco encontrado.\nContate sua Unidade para mais informações.",
                  textAlign: TextAlign.center,
                );
              }
            } else {
              return LoaderFeedbackCow(
                mensagem: "Carregando bancos",
                size: 60,
              );
            }
          },
        ),
        _buildTextField(_agenciaController, 'Agência', TextInputType.text),
        _buildTextField(_dvAgenciaController, 'DV Agência', TextInputType.text),
        _buildTextField(_contaController, 'Conta Corrente', TextInputType.text),
        _buildTextField(
            _dvContaController, 'DV Conta Corrente', TextInputType.text),
      ],
      tabIndex,
    );
  }

  Widget _buildProducaoTab(int tabIndex) {
    return _buildTabContent(
      context,
      'Próximo',
      [
        _buildTextField(_volumeInicialController,
            'Volume Inicial (Litros por dia)', TextInputType.number),
        _buildTextField(_capacidadeResfriadorController,
            'Capacidade do Resfriador', TextInputType.number),
        _buildTextField(
            _nrOrdenhasController, 'Número de Ordenhas', TextInputType.number),
        _buildCheckbox('Tanque de Expansão', _tanqueExpansao, (value) {
          setState(() {
            _tanqueExpansao = value ?? false;
          });
        }),
        _buildCheckbox('Tanque de Imersão', _tanqueImersao, (value) {
          setState(() {
            _tanqueImersao = value ?? false;
          });
        }),
      ],
      tabIndex,
    );
  }

  Widget _buildFinalizarTab(int tabIndex) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: () {
          _saveFormData();
          _sendDataToAPI();
        },
        child: Text('Finalizar Cadastro'),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, String buttonText,
      List<Widget> fields, int tabIndex) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: fields,
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              if (tabIndex < _tabController!.length - 1) {
                // Navigate to the next tab
                _tabController?.animateTo(tabIndex + 1);
              } else {
                // Finalize the form on the last tab
                _saveFormData();
                _sendDataToAPI();
              }
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _scrollToFocus() {
    _scrollController?.animateTo(135,
        duration: const Duration(seconds: 1), curve: Curves.linear);
  }

  Widget _buildTextField(
      TextEditingController controller, String label, TextInputType inputType) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: inputType);
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(label),
      ],
    );
  }
}
