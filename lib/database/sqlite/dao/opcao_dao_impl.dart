import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/domain/interfaces/opcao_dao.dart';
import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class OpcaoDAOImpl implements OpcaoDAO {
  late Database _db;

  @override
  Future<List<Opcao>> selectAll(Opcao opcao, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Opcao> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM opcao WHERE id = ?", [opcao.id]);
          break;
        case TipoConsultaDB.PorPergunta:
          resultado = await _db.rawQuery("SELECT * FROM opcao WHERE idPergunta = ?", [opcao.pergunta?.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('opcao');
          break;
        default:
          resultado = await _db.query('opcao');
          break;
      }

      for (var linha in resultado) {
        lista.add(Opcao(
            id: linha['id'],
            descricao: linha['descricao'],
            valorResposta: linha['valorResposta'],
            ativa: (linha['ativa'] == 0) ? false : true,
            color: linha['color'],
            pergunta: Pergunta(id: linha['idPergunta'])));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Opcao (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<Opcao?> carregarOpcao(int id) async {
    try {
      var array = await OpcaoDAOImpl().selectAll(Opcao(id: id), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Opcao(
          id: array[0].id,
          descricao: array[0].descricao,
          valorResposta: array[0].valorResposta,
          color: array[0].color,
          ativa: array[0].ativa,
          pergunta: array[0].pergunta,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Opcao (loadOpcao): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String id) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM opcao WHERE id = ?';
      await _db.rawDelete(sql, [id]);
    } catch (ex) {
      throw Exception("Erro Opcao (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Opcao opcao) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'REPLACE INTO opcao (id, descricao, valorResposta, ativa, color, idPergunta) VALUES (?, ?, ?, ?, ?, ?)';
      await _db.rawInsert(sql, [opcao.id, opcao.descricao, opcao.valorResposta, opcao.ativa, opcao.color, opcao.pergunta?.id]);
    } catch (ex) {
      throw Exception("Erro Opcao (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Opcao opcao) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'UPDATE opcao SET descricao = ?, valorResposta = ?, ativa = ?, color = ?, idPergunta = ? WHERE sigla = ?';
      await _db.rawUpdate(sql, [opcao.descricao, opcao.valorResposta, opcao.ativa, opcao.color, opcao.pergunta?.id, opcao.id]);
    } catch (ex) {
      throw Exception("Erro Opcao (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Opcao>> selectSimple(Opcao opcao, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Opcao> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM opcao WHERE id = ?", [opcao.id]);
          break;
        case TipoConsultaDB.PorPergunta:
          resultado = await _db.rawQuery("SELECT * FROM opcao WHERE idPergunta = ?", [opcao.pergunta?.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('opcao');
          break;
        default:
          resultado = await _db.query('opcao');
          break;
      }

      for (var linha in resultado) {
        lista.add(Opcao(
            id: linha['id'],
            descricao: linha['descricao'],
            valorResposta: linha['valorResposta'],
            ativa: (linha['ativa'] == 0) ? false : true,
            color: linha['color'],
            pergunta: Pergunta(id: linha['idPergunta'])));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Opcao (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
