import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/anexos_visita_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/banco_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/cidade_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/propriedade_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/questionario_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/sync_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/visita_dao_impl.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/anexos_visita.dart';
import 'package:milkroute_tecnico/model/banco.dart';
import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/sync.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:milkroute_tecnico/services/banco_service.dart';
import 'package:milkroute_tecnico/services/cidade_services.dart';
import 'package:milkroute_tecnico/services/propriedade_service.dart';
import 'package:milkroute_tecnico/services/sync_service.dart';
import 'package:milkroute_tecnico/services/tecnico_service.dart';
import 'package:milkroute_tecnico/services/visita_service.dart';
import "package:collection/collection.dart";
import 'package:milkroute_tecnico/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncController extends ChangeNotifier {
  static SyncController instance = SyncController();
  PropriedadeService apiPropriedade = PropriedadeService();
  TecnicoService apiTecnico = TecnicoService();
  VisitaService apiVisita = VisitaService();
  SyncService apiSync = SyncService();
  CidadeService apiCidade = CidadeService();
  BancoService apiBanco = BancoService();
  double loaderProgressBar = 1;
  String msgCarregamento = "--";
  late Sync sync;

  static final dataInicio_params = DateTime.now().subtract(Duration(days: 90));
  static final dataFim_params = DateTime.now();

  Future syncDados(User user, Estabelecimento estabelecimento) async {
    List<Sync> listSyncConcluidas = [];
    bool flagSync;
    SyncController.instance.loaderProgressBar = 0;
    List<Propriedade> _listPropriedadesAPI = [];
    List<Propriedade> _listPropriedadeSQLite = [];
    List<Visita> _listVisitasAPI = [];
    List<Visita> _listVisitasSQLite = [];

    await atualizaLoaderBar("Enviando dados de Visitas", 1);
    await enviarVisita(user);
    await enviarAnexosVisita(user);
    await carregarBancos(user);

    Map<dynamic, List<Sync>> pendencias = groupBy((await verificaSyncPendente(user)).toList(), (elem) => elem.nomeTabela);

    List<Sync> listPendencias = pendencias.entries.map((entry) => entry.value.first).toList();

    if (listPendencias.isNotEmpty) {
      int qtdeIteracoes = listPendencias.length;
      var paramsLoad = 80 / qtdeIteracoes;

      for (Sync ocorrenciaSync in listPendencias) {
        qtdeIteracoes -= 1;

        await atualizaLoaderBar("Sincronizando ${ocorrenciaSync.nomeTabela}", (paramsLoad * (listPendencias.length - qtdeIteracoes)).toInt());

        if (await verificaNecessidadeSync(ocorrenciaSync)) {
          if (ocorrenciaSync.nomeTabela == "Cidade") {
            await carregarCidades(user);
            // Sinaliza a tabela Sync que a sincronização da tabela Cidade foi concluída.
            await SyncDAOImpl()
                .replace(listPendencias.firstWhere((element) => element.nomeTabela == "Cidade", orElse: () => Sync(nomeTabela: "Cidade", dataHora: DateTime.now(), id: 0)));
          }

          if (ocorrenciaSync.nomeTabela == "Propriedade" || ocorrenciaSync.nomeTabela == "Pessoa" || ocorrenciaSync.nomeTabela == "Tecnico") {
            try {
              //_listPropriedadesAPI = await apiPropriedade.getListPropriedade(user.login, user.token, user.empresa);
              _listPropriedadesAPI =
                  (await apiPropriedade.getListPropriedadeByEstabelecimento(user.login!, user.token!, user.empresa!, estabelecimento.codEstabel!)).cast<Propriedade>();
              _listPropriedadeSQLite = await PropriedadeDAOImpl().selectSimple(Propriedade(), TipoConsultaDB.Tudo);

              await carregarPropriedades(listPendencias, _listPropriedadesAPI, _listPropriedadeSQLite).then((value) {
                if (value == true) {
                  // SINALIZA QUE FOI CONCLUIDO COM SUCESSO "Propriedade, Pessoa e Cidade"
                  listSyncConcluidas.add(ocorrenciaSync);
                  notifyListeners();
                } else {
                  flagSync = false;
                }
              });

              await SyncDAOImpl().replace(
                  listPendencias.firstWhere((element) => element.nomeTabela == "Propriedade", orElse: () => Sync(nomeTabela: "Propriedade", dataHora: DateTime.now(), id: 0)));
              await SyncDAOImpl()
                  .replace(listPendencias.firstWhere((element) => element.nomeTabela == "Pessoa", orElse: () => Sync(nomeTabela: "Pessoa", dataHora: DateTime.now(), id: 0)));

              GlobalData.listaGlobalAPIPropriedades = _listPropriedadesAPI;
            } catch (ex) {
              print("Erro ao Carregar Propriedades, Pessoas e Cidade: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
            }
          }

          // SINCRONIZAR VISITAS E QUESTIONÁRIOS
          if (ocorrenciaSync.nomeTabela == "Visita" || ocorrenciaSync.nomeTabela == "Questionario" || ocorrenciaSync.nomeTabela == "Tecnico") {
            try {
              // _listVisitasAPI = await apiVisita.carregarVisitasPorTecnico(user.login, user.token, user.empresa, dataInicio_params, dataFim_params, true, "AGENDADO");
              _listVisitasAPI = (await apiVisita.carregarVisitasPorTecnico(user.login!, user.token!, user.empresa!, dataInicio_params, dataFim_params, true))
                  .where((visita) => visita.estabelecimento?.codEstabel == estabelecimento.codEstabel)
                  .toList();

              _listVisitasSQLite = await VisitaDAOImpl().selectSimple(Visita(), TipoConsultaDB.Tudo);

              await carregarVisitas(user, _listVisitasAPI, _listVisitasSQLite).then((value) {
                if (value == true) {
                  // SINALIZA QUE FOI CONCLUIDO COM SUCESSO "Visita e Questionario"
                  listSyncConcluidas.add(ocorrenciaSync);
                  notifyListeners();
                } else {
                  flagSync = false;
                }
              });

              await SyncDAOImpl()
                  .replace(listPendencias.firstWhere((element) => element.nomeTabela == "Visita", orElse: () => Sync(nomeTabela: "Visita", dataHora: DateTime.now(), id: 0)));
              await SyncDAOImpl().replace(
                  listPendencias.firstWhere((element) => element.nomeTabela == "Questionario", orElse: () => Sync(nomeTabela: "Questionario", dataHora: DateTime.now(), id: 0)));

              GlobalData.listaGlobalAPIVisitas = _listVisitasAPI;
            } catch (ex) {
              print("Erro ao Carregar Visitas e Questionários: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
            }
          }

          await SyncDAOImpl()
              .replace(listPendencias.firstWhere((element) => element.nomeTabela == "Tecnico", orElse: () => Sync(nomeTabela: "Tecnico", dataHora: DateTime.now(), id: 0)));
        }

        if (listSyncConcluidas.isNotEmpty) {
          await _finalizaCarregamento();

          // AINDA NÃO POSSO ENVIAR UM POST SINALIZANDO A SINCRONIZAÇÃO PORQUE DEPENDE DE OUTROS DISPOSITIVOS
          // await postSyncRealizada(user, listSyncConcluidas).then((value) {
          //   if (value == true) {
          //     _finalizaCarregamento(pendencias.entries.last.value[0].dataHora);
          //   }
          // });
        }
      }
    } else {
      await _finalizaCarregamento();
    }
    // FORÇAR REDIRECIONAMENTO
    // SyncController.instance.loaderProgressBar = 2;
    await atualizaLoaderBar("Carregamento concluído", 100);

    setLastSyncDate(DateTime.now());
    notifyListeners();
  }

  Future<List<Sync>> verificaSyncPendente(User _user) async {
    List<Sync> listaPendenciasSync = [];
    listaPendenciasSync = await apiSync.getSync(_user.login!, _user.token!, _user.empresa!);

    return listaPendenciasSync;
  }

  Future<bool> enviarVisita(User _user) async {
    try {
      List<Visita> listaVisitasSync = [];

      await VisitaDAOImpl().selectSimple(Visita(), TipoConsultaDB.PorPendenciaSync).then((returnList) async {
        if (returnList.isNotEmpty) {
          List<Visita> listVisitasOnline = GlobalData.listaGlobalAPIVisitas;

          listaVisitasSync = returnList.where((visitaLocal) => !listVisitasOnline.any((visitasOnLine) => visitasOnLine.idAppTecnico == visitaLocal.idAppTecnico)).toList();
        }
      });

      if (listaVisitasSync.isNotEmpty) {
        for (Visita visita in listaVisitasSync) {
          List<Visita> listVisitaSync = [];
          listVisitaSync = await VisitaDAOImpl().selectAll(visita, TipoConsultaDB.PorPK);

          await apiSync.postVisita(_user.login!, _user.token!, _user.empresa!, jsonEncode(listVisitaSync[0]));
        }
        return true;
      } else {
        return true;
      }
    } catch (ex) {
      print("Erro Sync (enviarDados): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  Future<bool> enviarAnexosVisita(User _user) async {
    try {
      await AnexosVisitaDAOImpl().selectAll(AnexosVisita(), TipoConsultaDB.PorPendenciaSync).then((returnList) async {
        if (returnList.isNotEmpty) {
          for (AnexosVisita anexoVisita in returnList) {
            File file;
            List<File> files = [];
            Visita visita = await VisitaDAOImpl().selectSimple(Visita(idAppTecnico: anexoVisita.idAppTecnicoVisita), TipoConsultaDB.PorPK).then((value) => value[0]);

            if (anexoVisita.caminhoArquivo != null) {
              file = File(anexoVisita.caminhoArquivo!);
              files.add(file);
            }

            if (await apiSync.postAnexosVisita(_user.login!, _user.token!, _user.empresa!, visita, anexoVisita, files)) {
              anexoVisita.dataHoraIU = null;
              await AnexosVisitaDAOImpl().update(anexoVisita);
            }
          }
        }
      });

      return true;
    } catch (ex) {
      print("Erro Sync (enviarDados): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  Future<bool> enviarDados(User _user, Sync entidadeSync) async {
    try {
      String tipoEntidade = entidadeSync.tipoMethodSync.runtimeType.toString();

      // APENAS Visita, Resposta e RespostaItem PODEM ENVIAR DADOS PRA API
      if (tipoEntidade == "VisitaDAOImpl" || tipoEntidade == "RespostaDAOImpl" || tipoEntidade == "RespostaItemDAOImpl") {
        if (entidadeSync.dadosSync != null) {
          List listDadosAEnviar = entidadeSync.dadosSync;

          if (listDadosAEnviar.isNotEmpty) {
            for (var entidade in listDadosAEnviar) {
              if (tipoEntidade == "VisitaDAOImpl") {
                List<Visita> listVisitaSync = [];
                listVisitaSync = await VisitaDAOImpl().selectAll(entidade, TipoConsultaDB.PorPK);

                await apiSync.postVisita(_user.login!, _user.token!, _user.empresa!, jsonEncode(listVisitaSync[0]));
              }
            }
            return true;
          } else {
            return true;
          }
        } else {
          return true;
        }
      } else {
        return true;
      }
    } catch (ex) {
      print("Erro Sync (enviarDados): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  Future<bool> carregarPropriedades(List<Sync> listPendenciasSync, List<Propriedade> _listPropriedadesAPI, List<Propriedade> listPropriedadeSQLite) async {
    try {
      SyncController.instance.loaderProgressBar = 0;

      List<List<Propriedade>> bufferProcessamento = [];
      const int QTDETHREADS = 10;

      // ELIMITAR PROPRIEDADES JÁ EXISTENTES NO APP DA SINCRONIZAÇÃO PODE COMPROMETER A ATUALIZAÇÃO CADASTRAL DO PRODUTOR NO APP
      // _listPropriedadesAPI.removeWhere((Propriedade prop) {
      //   if (listPropriedadeSQLite.any((elem) => elem.codProdutor == prop.codProdutor)) {
      //     return true;
      //   } else {
      //     return false;
      //   }
      // });

      int pagSize = (_listPropriedadesAPI.length ~/ QTDETHREADS) + 1;
      int qtdePropriedades = _listPropriedadesAPI.length;
      int quantidadePag = qtdePropriedades ~/ pagSize + 1;
      int restoDiv = qtdePropriedades % pagSize;

      for (int i = 0; i < quantidadePag; i++) {
        int inicio = i * pagSize;
        int fim = (i == (quantidadePag - 1)) ? (inicio + restoDiv) : (inicio + pagSize);
        bufferProcessamento.add(_listPropriedadesAPI.sublist(inicio, fim));
      }

      if (_listPropriedadesAPI.length < 100) {
        await verificaInserePropriedade(_listPropriedadesAPI, 45, 35);
      } else {
        await Future.wait([
          if (bufferProcessamento[0].isNotEmpty) verificaInserePropriedade(bufferProcessamento[0], 45, 35),
          if (bufferProcessamento[1].isNotEmpty) verificaInserePropriedade(bufferProcessamento[1]),
          if (bufferProcessamento[2].isNotEmpty) verificaInserePropriedade(bufferProcessamento[2]),
          if (bufferProcessamento[3].isNotEmpty) verificaInserePropriedade(bufferProcessamento[3]),
          if (bufferProcessamento[4].isNotEmpty) verificaInserePropriedade(bufferProcessamento[4]),
          if (bufferProcessamento[5].isNotEmpty) verificaInserePropriedade(bufferProcessamento[5]),
          if (bufferProcessamento[6].isNotEmpty) verificaInserePropriedade(bufferProcessamento[6]),
          if (bufferProcessamento[7].isNotEmpty) verificaInserePropriedade(bufferProcessamento[7]),
          if (bufferProcessamento[8].isNotEmpty) verificaInserePropriedade(bufferProcessamento[8]),
          if (bufferProcessamento[9].isNotEmpty) verificaInserePropriedade(bufferProcessamento[9]),
        ]);
      }

      for (Propriedade propriedadeSQLite in listPropriedadeSQLite) {
        bool existeNaAPI = _listPropriedadesAPI.any((propriedadeAPI) => propriedadeAPI.codProdutor == propriedadeSQLite.codProdutor);

        if (!existeNaAPI) {
          PropriedadeDAOImpl().remove(propriedadeSQLite.codProdutor!);
        }
      }

      return true;
    } catch (ex) {
      print("Erro carregarProdutores: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  // NOVO CARREGAR CIDADES
  Future<void> carregarCidades(User user) async {
    try {
      // Chama o método getListCidadesAll passando o Bearer Token de autenticação e o tenant do usuário.
      List<Cidade> listCidadesAPI = (await apiCidade.getListCidadesAll(user.token!, user.empresa!)).cast<Cidade>();

      // Salva as cidades no SQLite (opcional).
      await CidadeDAOImpl().insertAll(listCidadesAPI);

      // Notifica os listeners sobre a atualização.
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar cidades: ${e.toString()}");
    }
  }

  Future<void> carregarBancos(User user) async {
    try {
      List<Banco> bancoAPIList = await apiBanco.obterBancos(user.token!, user.empresa!);

      // Salva as cidades no SQLite (opcional).

      await BancoDAOImpl().insertAll(bancoAPIList);

      // for (var banco in bancoAPI) {
      //   await BancoDAOImpl().replace(banco);
      // }

      // Notifica os listeners sobre a atualização.
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar bancos: ${e.toString()}");
    }
  }

  // ANTIGO CARREGAR CIDADES
  // Future<bool> carregarCidades(List<Propriedade> _listPropriedadesAPI) async {
  //   try {
  //     int percentSize = 0;
  //     int countArray = 0;

  //     // SEPARA CIDADES
  //     Map<dynamic, List<Propriedade>> mapListCidades = groupBy(_listPropriedadesAPI, (elem) {
  //       if (elem.pessoa.cidade != null) {
  //         return elem.pessoa.cidade.codigoMunIbge;
  //       }
  //     });

  //     percentSize = (mapListCidades.length ~/ 10);
  //     percentSize = (percentSize == 0) ? 1 : percentSize;
  //     countArray = 0;

  //     for (var element in mapListCidades.entries) {
  //       countArray++;

  //       if (countArray % percentSize == 0) {
  //         //await atualizaLoaderBar("Gravando cidades", (30 + (countArray ~/ percentSize)).toInt());
  //       }

  //       await CidadeDAOImpl().insert(element.value[0].pessoa.cidade);
  //     }

  //     return true;
  //   } catch (ex) {
  //     print("Erro carregarCidades: " + ex.toString().substring(ex.toString().indexOf(':') + 1));
  //     return false;
  //   }
  // }

  // Future<bool> carregarBancos(List<Propriedade> _listPropriedadesAPI) async {
  //   try {
  //     if (_listPropriedadesAPI == null || _listPropriedadesAPI.isEmpty) {
  //       print("Lista de propriedades está vazia.");
  //       return false;
  //     }

  //     int percentSize = 0;
  //     int countArray = 0;

  //     // SEPARA BANCOS POR CODFEBRABAN
  //     Map<dynamic, List<Propriedade>> mapListBancos = groupBy(_listPropriedadesAPI.where((elem) => elem.banco != null && elem.banco.codFebraban != null), (elem) {
  //       return elem.banco.codFebraban;
  //     });

  //     if (mapListBancos.isEmpty) {
  //       print("Nenhum banco encontrado para gravar.");
  //       return true; // Ou false, dependendo do que você quiser fazer nesse caso.
  //     }

  //     percentSize = (mapListBancos.length ~/ 10);
  //     percentSize = (percentSize == 0) ? 1 : percentSize;
  //     countArray = 0;

  //     for (var element in mapListBancos.entries) {
  //       countArray++;

  //       if (countArray % percentSize == 0) {
  //         // Atualiza a barra de progresso, se necessário
  //         // await atualizaLoaderBar("Gravando bancos", (30 + (countArray ~/ percentSize)).toInt());
  //       }

  //       Banco banco = element.value[0].banco as Banco;

  //       // Insere o banco na base de dados
  //       await BancoDAOImpl().insert(banco);
  //     }

  //     return true;
  //   } catch (ex) {
  //     print("Erro carregarBancos: " + ex.toString().substring(ex.toString().indexOf(':') + 1));
  //     return false;
  //   }
  // }

  Future<bool> carregarVisitas(User user, List<Visita> _listVisitasAPI, List<Visita> _listVisitasSQLite) async {
    try {
      List _listBatchQuestionarios = [];
      List<Visita> newVisitas = [];

      for (Visita visitaAPI in _listVisitasAPI) {
        bool existsInSQLite = _listVisitasSQLite.any((visitaSQLite) => visitaSQLite.idAppTecnico == visitaAPI.idAppTecnico);
        if (!existsInSQLite) {
          newVisitas.add(visitaAPI);
        }
      }

      if (newVisitas.isNotEmpty) {
        var mapListQuest = groupBy(_listVisitasAPI, (elem) {
          if (elem.questionario?.id != null) {
            return elem.questionario?.id;
          }
        });

        _listBatchQuestionarios = mapListQuest.values.toList();

        for (List<Visita> visitaQuest in _listBatchQuestionarios) {
          var listQuestionarios = await QuestionarioDAOImpl().selectAll(Questionario(), TipoConsultaDB.Tudo);

          if (listQuestionarios.any((elem) => elem.id == visitaQuest[0].questionario?.id) == false) {
            await apiVisita.carregarVisitasPorId(user.login!, user.token!, user.empresa!, visitaQuest[0].idWeb!).then((visita) async {
              if (visita != null) {
                visitaQuest[0].questionario = visita.questionario;
              }
            });

            await QuestionarioDAOImpl().insert(visitaQuest[0].questionario!);
          }
        }

        for (Visita idx in _listVisitasAPI) {
          Visita visitaExistente = Visita();

          if (_listVisitasSQLite.isNotEmpty) {
            visitaExistente = _listVisitasSQLite.firstWhere((visitaDisp) => visitaDisp.idWeb == idx.idWeb, orElse: () => Visita());

            if (visitaExistente == null) {
              idx.idAppTecnico ??= HashGenerator().geradorSha1Random((idx.idWeb.toString()));
            } else {
              idx.idAppTecnico = visitaExistente.idAppTecnico;
            }
          } else {
            idx.idAppTecnico ??= HashGenerator().geradorSha1Random((idx.idWeb.toString()));
          }

          await VisitaDAOImpl().batchInsert(idx);
        }
      }

      for (Visita visitaSQLite in _listVisitasSQLite) {
        bool existeNaAPI = _listVisitasAPI.any((visitaAPI) => visitaAPI.idAppTecnico == visitaSQLite.idAppTecnico);
        if (!existeNaAPI) {
          if (visitaSQLite.idAppTecnico != null) {
            await VisitaDAOImpl().remove(visitaSQLite.idAppTecnico!);
          }
        }
      }

      return true;
    } catch (ex) {
      print("Erro carregarVisitas: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  Future<void> atualizaLoaderBar(String msg, int valor) async {
    SyncController.instance.loaderProgressBar = valor / 100;
    SyncController.instance.msgCarregamento = msg;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<bool> postSyncRealizada(User _user, List<Sync> listSync) async {
    for (Sync elem in listSync) {
      dynamic listResult = jsonEncode(elem);

      if (!await apiSync.postSync(_user.login!, _user.token!, _user.empresa!, listResult)) {
        return false;
      }
    }

    return true;
  }

  Future<bool> verificaInserePropriedade(List<Propriedade> listBufferProp, [int? atualPercent, int? sizePercent]) async {
    try {
      if (sizePercent != null) {
        int percentSize = listBufferProp.length ~/ sizePercent;
        percentSize = (percentSize == 0) ? 1 : percentSize;
        int countArray = 0;

        for (Propriedade idx in listBufferProp) {
          countArray++;

          if (countArray % percentSize == 0) {
            //await atualizaLoaderBar("Gravando novas propriedades", (atualPercent + (countArray ~/ percentSize)));
          }
          await PropriedadeDAOImpl().insert(idx);
        }
        return true;
      } else {
        // VERIFICA SE JÁ EXISTE NO SQLITE

        for (Propriedade idx in listBufferProp) {
          await PropriedadeDAOImpl().insert(idx);
        }
        return true;
      }
    } catch (ex) {
      return false;
    }
  }

  Future<void> _finalizaCarregamento() async {
    double cronometer = 0;
    await Future.delayed(Duration(milliseconds: 500));

    while (cronometer <= 1.0) {
      await Future.delayed(Duration(milliseconds: 5));
      cronometer = cronometer + 0.01;

      SyncController.instance.loaderProgressBar = cronometer;
      notifyListeners();
    }

    SyncController.instance.loaderProgressBar = 1;
    notifyListeners();
  }

  Future<bool> verificaNecessidadeSync(Sync ocorrenciaSync) async {
    Sync? entidadeSyncLocal = await SyncDAOImpl().carregarSync(ocorrenciaSync.nomeTabela!);

    if (entidadeSyncLocal == null || entidadeSyncLocal.dataHora!.isBefore(ocorrenciaSync.dataHora!)) {
      return true;
    } else {
      return false;
    }
  }

  void setLastSyncDate(DateTime dateTime) {
    GlobalData.lastSyncDateTime = dateTime ?? DateTime.now();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("lastSync", dateTime.toString());
    });

    notifyListeners();
  }
}
