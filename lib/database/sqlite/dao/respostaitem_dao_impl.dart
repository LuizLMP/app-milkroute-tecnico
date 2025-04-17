import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/opcao_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/pergunta_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/resposta_item_dao.dart';
import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class RespostaItemDAOImpl implements RespostaItemDAO {
  late Database _db;

  @override
  Future<List<RespostaItem>> selectAll(RespostaItem respostaItem, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<RespostaItem> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM resposta_item WHERE idAppTecnico = ?", [respostaItem.idAppTecnico]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('resposta_item');
          break;
        case TipoConsultaDB.PorPergunta:
          resultado = await _db.rawQuery("SELECT * FROM resposta_item WHERE idPergunta = ? AND idResposta = ?", [respostaItem.pergunta?.id, respostaItem.resposta?.idAppTecnico]);
          break;
        case TipoConsultaDB.PorResposta:
          resultado = await _db.rawQuery("SELECT * FROM resposta_item WHERE idResposta = ?", [respostaItem.resposta?.idAppTecnico]);
          break;
        case TipoConsultaDB.PorPendenciaSync:
          resultado = await _db.rawQuery("SELECT * FROM resposta_item WHERE dataHoraIU != '0001-01-01 00:00:00'");
          break;
        default:
          resultado = await _db.query('resposta_item');
          break;
      }

      for (var linha in resultado) {
        lista.add(RespostaItem(
          idAppTecnico: linha['idAppTecnico'],
          idWeb: linha['idWeb'],
          opcao: await OpcaoDAOImpl().carregarOpcao(linha['idOpcao']),
          descricao: linha['descricao'],
          pergunta: await PerguntaDAOImpl().carregarPergunta(linha['idPergunta']),
          resposta: Resposta(idAppTecnico: linha['idResposta']),
          dataHoraIU: linha['dataHoraIU'] != null ? DateTime.parse(linha['dataHoraIU']) : DateTime.parse('0001-01-01 00:00:00'),
          visualizaResposta: (linha['visualizaResposta'] == null)
              ? true
              : (linha['visualizaResposta'] == 1)
                  ? true
                  : false,
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro RespostaItem (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<RespostaItem?> carregarRespostaItem(String idAppTecnico) async {
    try {
      var array = await RespostaItemDAOImpl().selectAll(RespostaItem(idAppTecnico: idAppTecnico), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return RespostaItem(
            idAppTecnico: array[0].idAppTecnico,
            idWeb: array[0].idWeb,
            opcao: array[0].opcao,
            descricao: array[0].descricao,
            pergunta: array[0].pergunta,
            resposta: array[0].resposta,
            dataHoraIU: array[0].dataHoraIU,
            visualizaResposta: array[0].visualizaResposta);
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro RespostaItem (loadRespostaItem): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String id, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          await _db.rawDelete("DELETE FROM resposta_item WHERE idAppTecnico = ?", [id]);
          break;
        case TipoConsultaDB.PorPergunta:
          await _db.rawDelete("DELETE FROM resposta_item WHERE idPergunta = ?", [id]);
          break;
        case TipoConsultaDB.PorResposta:
          await _db.rawDelete("DELETE FROM resposta_item WHERE idResposta = ?", [id]);
          break;
        // case TipoConsultaDB.Tudo:
        //   await _db.rawDelete("TRUNCATE resposta_item");
        //   break;
        default:
          await _db.rawDelete("DELETE FROM resposta_item WHERE id = ?", [id]);
          break;
      }
    } catch (ex) {
      throw Exception("Erro RespostaItem (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(RespostaItem respostaItem) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = ''' REPLACE INTO resposta_item (idAppTecnico, idWeb, idOpcao, descricao, idPergunta, idResposta, visualizaResposta, dataHoraIU) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?)''';
      await _db.rawInsert(sql, [
        respostaItem.idAppTecnico,
        respostaItem.idWeb,
        respostaItem.opcao?.id,
        respostaItem.descricao,
        respostaItem.pergunta?.id,
        respostaItem.resposta?.idAppTecnico,
        respostaItem.visualizaResposta,
        DateFormat(dateFormatAPI).format(respostaItem.dataHoraIU!)
      ]);
    } catch (ex) {
      throw Exception("Erro RespostaItem (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(RespostaItem respostaItem) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = ''' UPDATE resposta_item 
                SET idWeb = ?, idOpcao = ?, descricao = ?, idPergunta = ?, idResposta = ?, visualizaResposta = ?, dataHoraIU = ? 
                WHERE idAppTecnico = ?''';
      await _db.rawUpdate(sql, [
        respostaItem.idWeb,
        respostaItem.opcao?.id,
        respostaItem.descricao,
        respostaItem.pergunta?.id,
        respostaItem.resposta?.idAppTecnico,
        (respostaItem.visualizaResposta == true) ? 1 : 0,
        DateFormat(dateFormatAPI).format(respostaItem.dataHoraIU!),
        respostaItem.idAppTecnico,
      ]);
    } catch (ex) {
      throw Exception("Erro RespostaItem (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<List<RespostaItem>> selectSimple(RespostaItem respostaItem, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<RespostaItem> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM resposta_item WHERE idAppTecnico = ?", [respostaItem.idAppTecnico]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('resposta_item');
          break;
        case TipoConsultaDB.PorPergunta:
          resultado = await _db.rawQuery("SELECT * FROM resposta_item WHERE idPergunta = ? AND idResposta = ?", [respostaItem.pergunta?.id, respostaItem.resposta?.idAppTecnico]);
          break;
        case TipoConsultaDB.PorResposta:
          resultado = await _db.rawQuery("SELECT * FROM resposta_item WHERE idResposta = ?", [respostaItem.resposta?.idAppTecnico]);
          break;
        case TipoConsultaDB.PorPendenciaSync:
          resultado = await _db.rawQuery("SELECT * FROM resposta_item WHERE dataHoraIU != '0001-01-01 00:00:00'");
          break;
        default:
          resultado = await _db.query('resposta_item');
          break;
      }

      for (var linha in resultado) {
        lista.add(RespostaItem(
          idAppTecnico: linha['idAppTecnico'],
          idWeb: linha['idWeb'],
          opcao: Opcao(id: linha['idOpcao']),
          descricao: linha['descricao'],
          pergunta: Pergunta(id: linha['idPergunta']),
          resposta: Resposta(idAppTecnico: linha['idResposta']),
          dataHoraIU: linha['dataHoraIU'] != null ? DateTime.parse(linha['dataHoraIU']) : DateTime.parse('0001-01-01 00:00:00'),
          visualizaResposta: (linha['visualizaResposta'] == 0) ? false : true,
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro RespostaItem (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
