import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/pergunta_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/categoriapergunta_dao.dart';
import 'package:milkroute_tecnico/model/categoriapergunta.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class CategoriaPerguntaDAOImpl implements CategoriaPerguntaDAO {
  late Database _db;

  @override
  // ignore: missing_return
  Future<List<CategoriaPergunta>> selectAll(CategoriaPergunta categoriaPergunta, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<CategoriaPergunta> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM categoria_pergunta WHERE id = ?", [categoriaPergunta.id]);
          break;
        case TipoConsultaDB.PorQuestionario:
          resultado = await _db.rawQuery("SELECT * FROM categoria_pergunta WHERE idQuestionario = ?", [categoriaPergunta.questionario?.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('categoria_pergunta');
          break;
        default:
          resultado = await _db.query('categoria_pergunta');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          CategoriaPergunta(
            id: linha['id'],
            descricao: linha['descricao'],
            ordem: linha['ordem'],
            questionario: Questionario(id: linha['idQuestionario']),
            listPerguntas: await PerguntaDAOImpl().selectAll(
                Pergunta(
                  categorias: CategoriaPergunta(id: linha['id']),
                ),
                TipoConsultaDB.PorCategoria),
          ),
        );
      }

      lista.sort(
        (a, b) {
          return a.ordem!.compareTo(b.ordem!);
        },
      );

      return lista;
    } catch (ex) {
      print("Erro CategoriaPergunta (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return [];
    }
  }

  @override
  // ignore: missing_return
  Future<CategoriaPergunta?> carregarCategoriaPergunta(int id) async {
    try {
      var array = await CategoriaPerguntaDAOImpl().selectAll(CategoriaPergunta(id: id), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return CategoriaPergunta(
          id: array[0].id,
          descricao: array[0].descricao,
          ordem: array[0].ordem,
          questionario: array[0].questionario,
          listPerguntas: array[0].listPerguntas,
        );
      } else {
        return null;
      }
    } catch (ex) {
      print("Erro CategoriaPergunta (loadCategoriaPergunta): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return null;
    }
  }

  @override
  Future remove(String id) async {
    try {
      await PerguntaDAOImpl().remove(id);

      _db = (await Connection.get())!;
      var sql = 'DELETE FROM categoria_pergunta WHERE id = ?';
      await _db.rawDelete(sql, [id]);
    } catch (ex) {
      print("Erro CategoriaPergunta (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(CategoriaPergunta categoriaPergunta) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'REPLACE INTO categoria_pergunta (id, descricao, ordem, idQuestionario) VALUES (?,?,?,?)';
      await _db.rawInsert(sql, [categoriaPergunta.id, categoriaPergunta.descricao, categoriaPergunta.ordem, categoriaPergunta.questionario?.id]);

      for (var elem in categoriaPergunta.listPerguntas!) {
        if (elem.categorias == null) {
          elem.categorias = CategoriaPergunta(id: categoriaPergunta.id);
        } else {
          elem.categorias?.id = categoriaPergunta.id;
        }
        await PerguntaDAOImpl().insert(elem);
      }
    } catch (ex) {
      print("Erro CategoriaPergunta (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(CategoriaPergunta categoriaPergunta) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'UPDATE categoria_pergunta SET descricao = ?, ordem = ?, idQuestionario = ? WHERE id = ?';
      await _db.rawUpdate(sql, [categoriaPergunta.descricao, categoriaPergunta.ordem, categoriaPergunta.questionario!.id, categoriaPergunta.id]);

      for (var e in categoriaPergunta.listPerguntas!) {
        await PerguntaDAOImpl().update(e);
      }
    } catch (ex) {
      print("Erro CategoriaPergunta (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<CategoriaPergunta>> selectSimple(CategoriaPergunta categoriaPergunta, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<CategoriaPergunta> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM categoria_pergunta WHERE id = ?", [categoriaPergunta.id]);
          break;
        case TipoConsultaDB.PorQuestionario:
          resultado = await _db.rawQuery("SELECT * FROM categoria_pergunta WHERE idQuestionario = ?", [categoriaPergunta.questionario?.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('categoria_pergunta');
          break;
        default:
          resultado = await _db.query('categoria_pergunta');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          CategoriaPergunta(
            id: linha['id'],
            descricao: linha['descricao'],
            ordem: linha['ordem'],
            questionario: Questionario(id: linha['idQuestionario']),
            // ignore: deprecated_member_use
            listPerguntas: [],
          ),
        );
      }

      return lista;
    } catch (ex) {
      print("Erro CategoriaPergunta (selectSimple): " + ex.toString().substring(ex.toString().indexOf(':') + 1));
      return [];
    }
  }
}
