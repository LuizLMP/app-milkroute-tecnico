import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/categoriapergunta_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/questionario_dao.dart';
import 'package:milkroute_tecnico/model/categoriapergunta.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class QuestionarioDAOImpl implements QuestionarioDAO {
  late Database _db;

  @override
  // ignore: missing_return
  Future<List<Questionario>> selectAll(Questionario questionario, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Questionario> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM questionario WHERE id = ?", [questionario.id]);
          break;
        case TipoConsultaDB.PorTecnico:
          resultado = await _db.rawQuery("SELECT * FROM questionario WHERE idTecnico = ?", [questionario.tecnico?.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('questionario');
          break;
        default:
          resultado = await _db.query('questionario');
          break;
      }

      for (var linha in resultado) {
        lista.add(Questionario(
          id: linha['id'],
          descricao: linha['descricao'],
          dataInicio: linha['dataInicio'],
          dataFim: linha['dataFim'],
          ultimaAlteracao: linha['ultimaAlteracao'],
          listCategorias: await CategoriaPerguntaDAOImpl().selectAll(CategoriaPergunta(questionario: Questionario(id: linha['id'])), TipoConsultaDB.PorQuestionario),
          tecnico: Tecnico(id: linha['idTecnico']),
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Questionario (SelectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  // ignore: missing_return
  Future<Questionario?> carregarQuestionario(int id) async {
    try {
      var array = await QuestionarioDAOImpl().selectAll(Questionario(id: id), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Questionario(
          id: array[0].id,
          descricao: array[0].descricao,
          dataInicio: array[0].dataInicio,
          dataFim: array[0].dataFim,
          ultimaAlteracao: array[0].ultimaAlteracao,
          listCategorias: array[0].listCategorias,
          tecnico: array[0].tecnico,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Questionario (loadQuestionario): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  // ignore: missing_return
  Future<Questionario?> carregarQuestionarioSimple(int id) async {
    try {
      var array = await QuestionarioDAOImpl().selectSimple(Questionario(id: id), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Questionario(
          id: array[0].id,
          descricao: array[0].descricao,
          dataInicio: array[0].dataInicio,
          dataFim: array[0].dataFim,
          ultimaAlteracao: array[0].ultimaAlteracao,
          listCategorias: array[0].listCategorias,
          tecnico: array[0].tecnico,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Questionario (loadQuestionario): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String id) async {
    try {
      await CategoriaPerguntaDAOImpl().remove(id);
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM questionario WHERE id = ?';
      await _db.rawDelete(sql, [id]);
    } catch (ex) {
      throw Exception("Erro Questionario (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Questionario questionario) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = '''
          REPLACE INTO questionario (id, descricao, dataInicio, dataFim, ultimaAlteracao, idTecnico) 
          VALUES (?, ?, ?, ?, ?, ?)
          ''';
      await _db.rawInsert(sql, [
        questionario.id,
        questionario.descricao,
        questionario.dataInicio,
        questionario.dataFim,
        questionario.ultimaAlteracao,
        (questionario.tecnico == null) ? null : questionario.tecnico?.id
      ]);

      for (var elem in questionario.listCategorias!) {
        if (elem.questionario == null) {
          elem.questionario = Questionario(id: questionario.id);
        } else {
          elem.questionario?.id = questionario.id;
        }

        await CategoriaPerguntaDAOImpl().insert(elem);
      }
    } catch (ex) {
      throw Exception("Erro Questionario (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Questionario questionario) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'UPDATE questionario SET descricao = ?, dataInicio = ?, dataFim = ?, ultimaAlteracao = ? WHERE id = ?';
      await _db.rawUpdate(sql, [questionario.descricao, questionario.dataInicio, questionario.dataFim, questionario.ultimaAlteracao, questionario.id]);

      for (var e in questionario.listCategorias!) {
        await CategoriaPerguntaDAOImpl().update(e);
      }
    } catch (ex) {
      throw Exception("Erro Questionario (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Questionario>> selectSimple(Questionario questionario, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Questionario> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM questionario WHERE id = ?", [questionario.id]);
          break;
        case TipoConsultaDB.PorTecnico:
          resultado = await _db.rawQuery("SELECT * FROM questionario WHERE idTecnico = ?", [questionario.tecnico?.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('questionario');
          break;
        default:
          resultado = await _db.query('questionario');
          break;
      }

      for (var linha in resultado) {
        lista.add(Questionario(
          id: linha['id'],
          descricao: linha['descricao'],
          dataInicio: linha['dataInicio'],
          dataFim: linha['dataFim'],
          ultimaAlteracao: linha['ultimaAlteracao'],
          listCategorias: <CategoriaPergunta>[],
          tecnico: Tecnico(id: linha['idTecnico']),
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Questionario (SelectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
