import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/estabelecimento_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/questionario_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/tecnico_dao.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class TecnicoDAOImpl implements TecnicoDAO {
  late Database _db;
  @override
  // ignore: missing_return
  Future<List<Tecnico>> selectAll(Tecnico tecnico, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Tecnico> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM tecnico WHERE id = ?", [tecnico.id]);
          break;
        case TipoConsultaDB.PorTecnico:
          resultado = await _db.rawQuery("SELECT * FROM tecnico WHERE id = ?", [tecnico.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('tecnico');
          break;
        default:
          resultado = await _db.query('tecnico');
          break;
      }

      for (var linha in resultado) {
        lista.add(Tecnico(
            id: linha['id'],
            nomeTecnico: linha['nomeTecnico'],
            listQuestionarios: await QuestionarioDAOImpl().selectAll(Questionario(tecnico: Tecnico(id: linha['id'])), TipoConsultaDB.PorTecnico)));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Questionario (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<Tecnico?> carregarTecnico(int id) async {
    try {
      var array = await TecnicoDAOImpl().selectAll(Tecnico(id: id), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Tecnico(
          id: array[0].id,
          nomeTecnico: array[0].nomeTecnico,
          listQuestionarios: array[0].listQuestionarios,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Questionario (loadTecnico): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String id) async {
    try {
      await QuestionarioDAOImpl().remove(id);

      _db = (await Connection.get())!;
      var sql = 'DELETE FROM tecnico WHERE id = ?';
      await _db.rawDelete(sql, [id]);
    } catch (ex) {
      throw Exception("Erro Questionario (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Tecnico tecnico) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'REPLACE INTO tecnico (id, nomeTecnico, sequenciaNrVisita) VALUES (?,?,?)';
      await _db.rawInsert(sql, [tecnico.id, tecnico.nomeTecnico, tecnico.sequenciaNrVisita]);

      for (Questionario elem in tecnico.listQuestionarios!) {
        if (elem.tecnico == null) {
          elem.tecnico = Tecnico(id: tecnico.id);
        } else {
          elem.tecnico?.id = tecnico.id;
        }

        await QuestionarioDAOImpl().insert(elem);
      }

      for (Estabelecimento elem in tecnico.listEstabelecimentos!) {
        if (elem.tecnico == null) {
          elem.tecnico = Tecnico(id: tecnico.id);
        } else {
          elem.tecnico?.id = tecnico.id;
        }

        await EstabelecimentoDAOImpl().insert(elem);
      }
    } catch (ex) {
      throw Exception("Erro Questionario (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Tecnico tecnico) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'UPDATE tecnico SET nomeTecnico = ? WHERE id = ?';

      await _db.rawUpdate(sql, [
        tecnico.nomeTecnico,
        tecnico.id,
      ]);

      for (var e in tecnico.listQuestionarios!) {
        await QuestionarioDAOImpl().update(e);
      }
    } catch (ex) {
      throw Exception("Erro Questionario (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Tecnico>> selectSimple(Tecnico tecnico, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Tecnico> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM tecnico WHERE id = ?", [tecnico.id]);
          break;
        case TipoConsultaDB.PorTecnico:
          resultado = await _db.rawQuery("SELECT * FROM tecnico WHERE id = ?", [tecnico.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('tecnico');
          break;
        default:
          resultado = await _db.query('tecnico');
          break;
      }

      for (var linha in resultado) {
        lista.add(Tecnico(
            id: linha['id'],
            nomeTecnico: linha['nomeTecnico'],
            // ignore: deprecated_member_use
            listQuestionarios: []));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Questionario (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
