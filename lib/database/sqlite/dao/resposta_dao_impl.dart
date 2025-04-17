import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/respostaitem_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/resposta_dao.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:sqflite/sqflite.dart';

class RespostaDAOImpl implements RespostaDAO {
  late Database _db;

  @override
  Future<List<Resposta>> selectAll(Resposta resposta, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Resposta> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM resposta WHERE idAppTecnico = ?", [resposta.idAppTecnico]);
          break;
        case TipoConsultaDB.PorVisita:
          resultado = await _db.rawQuery("SELECT * FROM resposta WHERE idVisita = ? AND idQuestionario = ?", [resposta.visita?.idAppTecnico, resposta.questionario?.id]);
          break;
        case TipoConsultaDB.PorQuestionario:
          resultado = await _db.rawQuery("SELECT * FROM resposta WHERE idQuestionario = ?", [resposta.questionario?.id]);
          break;
        case TipoConsultaDB.PorPendenciaSync:
          resultado = await _db.rawQuery("SELECT * FROM resposta WHERE dataHoraIU != '0001-01-01 00:00:00'");
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('resposta');
          break;
        default:
          resultado = await _db.query('resposta');
          break;
      }

      for (var linha in resultado) {
        lista.add(Resposta(
          idAppTecnico: linha['idAppTecnico'],
          idWeb: linha['idWeb'],
          dataCriacao: linha['dataCriacao'] != null ? DateTime.parse(linha['dataCriacao']) : DateTime.parse('0001-01-01 00:00:00'),
          questionario: Questionario(id: linha['idQuestionario']),
          visita: Visita(idAppTecnico: linha['idVisita']),
          dataHoraIU: linha['dataHoraIU'] != null ? DateTime.parse(linha['dataHoraIU']) : DateTime.parse('0001-01-01 00:00:00'),
          listRespostaItem: await RespostaItemDAOImpl().selectAll(RespostaItem(resposta: Resposta(idAppTecnico: linha['idAppTecnico'])), TipoConsultaDB.PorResposta),
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Resposta (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<Resposta?> carregarResposta(String idAppTecnico) async {
    try {
      var array = await RespostaDAOImpl().selectAll(Resposta(idAppTecnico: idAppTecnico), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Resposta(
            idAppTecnico: array[0].idAppTecnico,
            idWeb: array[0].idWeb,
            dataCriacao: array[0].dataCriacao,
            questionario: array[0].questionario,
            listRespostaItem: array[0].listRespostaItem,
            visita: array[0].visita,
            dataHoraIU: array[0].dataHoraIU);
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Resposta (loadResposta): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String idAppTecnico, TipoConsultaDB tipoConsultaDB) async {
    try {
      await RespostaItemDAOImpl().remove(idAppTecnico, TipoConsultaDB.PorResposta);

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          await _db.rawDelete("DELETE FROM resposta WHERE idAppTecnico = ?", [idAppTecnico]);
          break;
        case TipoConsultaDB.PorVisita:
          await _db.rawDelete("DELETE FROM resposta WHERE idVisita = ?", [idAppTecnico]);
          break;
        default:
          await _db.rawDelete("DELETE FROM resposta WHERE idAppTecnico = ?", [idAppTecnico]);
          break;
      }
    } catch (ex) {
      throw Exception("Erro Resposta (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Resposta resposta) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'REPLACE INTO resposta (idAppTecnico, idWeb, dataCriacao, idQuestionario, idVisita, dataHoraIU) VALUES (?, ?, ?, ?, ?, ?)';
      await _db.rawInsert(sql, [
        resposta.idAppTecnico,
        resposta.idWeb,
        DateFormat(dateFormatAPI).format(resposta.dataCriacao!),
        resposta.questionario?.id,
        resposta.visita?.idAppTecnico,
        DateFormat(dateFormatAPI).format(resposta.dataHoraIU!)
      ]);

      if (resposta.listRespostaItem != null) {
        for (var elem in resposta.listRespostaItem!) {
          if (elem.resposta == null) {
            elem.resposta = Resposta(idAppTecnico: resposta.idAppTecnico);
          } else {
            elem.resposta?.idAppTecnico = resposta.idAppTecnico;
          }

          await RespostaItemDAOImpl().insert(elem);
        }
      }

      return resposta.idAppTecnico;
    } catch (ex) {
      throw Exception("Erro Resposta (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Resposta resposta) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = ''' UPDATE resposta 
              SET idWeb = ?, dataCriacao = ?, idQuestionario = ?, idVisita = ?, dataHoraIU = ? 
              WHERE idAppTecnico = ? ''';
      await _db.rawUpdate(sql, [
        resposta.idWeb,
        DateFormat(dateFormatAPI).format(resposta.dataCriacao!),
        resposta.questionario?.id,
        resposta.visita?.idAppTecnico,
        DateFormat(dateFormatAPI).format(resposta.dataHoraIU!),
        resposta.idAppTecnico
      ]);

      for (var elem in resposta.listRespostaItem!) {
        elem.resposta?.idAppTecnico = resposta.idAppTecnico;
        await RespostaItemDAOImpl().update(elem);
      }
    } catch (ex) {
      throw Exception("Erro Resposta (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<List<Resposta>> selectSimple(Resposta resposta, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Resposta> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM resposta WHERE idAppTecnico = ?", [resposta.idAppTecnico]);
          break;
        case TipoConsultaDB.PorVisita:
          resultado = await _db.rawQuery("SELECT * FROM resposta WHERE idVisita = ?", [resposta.visita?.idAppTecnico]);
          break;
        case TipoConsultaDB.PorQuestionario:
          resultado = await _db.rawQuery("SELECT * FROM resposta WHERE idQuestionario = ?", [resposta.questionario?.id]);
          break;
        case TipoConsultaDB.PorPendenciaSync:
          resultado = await _db.rawQuery("SELECT * FROM resposta WHERE dataHoraIU != '0001-01-01 00:00:00'");
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('resposta');
          break;
        default:
          resultado = await _db.query('resposta');
          break;
      }

      for (var linha in resultado) {
        lista.add(Resposta(
          idAppTecnico: linha['idAppTecnico'],
          idWeb: linha['idWeb'],
          dataCriacao: linha['dataCriacao'] != null ? DateTime.parse(linha['dataCriacao']) : DateTime.parse('0001-01-01 00:00:00'),
          questionario: Questionario(id: linha['idQuestionario']),
          visita: Visita(idAppTecnico: linha['idVisita']),
          dataHoraIU: linha['dataHoraIU'] != null ? DateTime.parse(linha['dataHoraIU']) : DateTime.parse('0001-01-01 00:00:00'),
          // ignore: deprecated_member_use
          listRespostaItem: [],
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Resposta (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
