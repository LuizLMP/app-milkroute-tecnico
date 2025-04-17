import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/opcao_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/pergunta_dao.dart';
import 'package:milkroute_tecnico/model/categoriapergunta.dart';
import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class PerguntaDAOImpl implements PerguntaDAO {
  late Database _db;

  @override
  // ignore: missing_return
  Future<List<Pergunta>> selectAll(Pergunta pergunta, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Pergunta> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM pergunta WHERE id = ?", [pergunta.id]);
          break;
        case TipoConsultaDB.PorCategoria:
          resultado = await _db.rawQuery("SELECT * FROM pergunta WHERE idCategoria = ?", [pergunta.categorias?.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('pergunta');
          break;
        default:
          resultado = await _db.query('pergunta');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Pergunta(
              id: linha['id'],
              descricao: linha['descricao'],
              tipoResposta: linha['tipoResposta'],
              obrigatorio: (linha['obrigatorio'] == 0) ? false : true,
              ativa: (linha['ativa'] == 0) ? false : true,
              ordem: linha['ordem'],
              tamanhoMaximo: linha['tamanhoMaximo'],
              listOpcoes: await OpcaoDAOImpl().selectAll(
                  Opcao(
                    pergunta: Pergunta(id: linha['id']),
                  ),
                  TipoConsultaDB.PorPergunta),
              categorias: CategoriaPergunta(id: linha['idCategoria'])),
        );
      }

      lista.sort(
        (a, b) {
          return a.ordem!.compareTo(b.ordem!);
        },
      );

      return lista;
    } catch (ex) {
      throw Exception("Erro Pergunta (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<Pergunta?> carregarPergunta(int id) async {
    try {
      var array = await PerguntaDAOImpl().selectAll(
        Pergunta(id: id),
        TipoConsultaDB.PorPK,
      );

      if (array.isNotEmpty) {
        return Pergunta(
          id: array[0].id,
          descricao: array[0].descricao,
          tipoResposta: array[0].tipoResposta,
          obrigatorio: array[0].obrigatorio,
          ativa: array[0].ativa,
          ordem: array[0].ordem,
          tamanhoMaximo: array[0].tamanhoMaximo,
          listOpcoes: array[0].listOpcoes,
          categorias: array[0].categorias,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Pergunta (loadPergunta): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String id) async {
    try {
      await OpcaoDAOImpl().remove(id);

      _db = (await Connection.get())!;
      var sql = 'DELETE FROM pergunta WHERE id = ?';
      await _db.rawDelete(sql, [id]);
    } catch (ex) {
      throw Exception("Erro Pergunta (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Pergunta pergunta) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = '''
            REPLACE INTO pergunta (id, descricao, tipoResposta, obrigatorio, ativa, ordem, tamanhoMaximo, idCategoria) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
          ''';
      await _db.rawInsert(
          sql, [pergunta.id, pergunta.descricao, pergunta.tipoResposta, pergunta.obrigatorio, pergunta.ativa, pergunta.ordem, pergunta.tamanhoMaximo, pergunta.categorias?.id]);

      for (var elem in pergunta.listOpcoes!) {
        if (elem.pergunta == null) {
          elem.pergunta = Pergunta(id: pergunta.id);
        } else {
          elem.pergunta?.id = pergunta.id;
        }
        await OpcaoDAOImpl().insert(elem);
      }
    } catch (ex) {
      throw Exception("Erro Pergunta (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Pergunta pergunta) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = 'UPDATE pergunta SET descricao = ?,tipoResposta = ?,obrigatorio = ?,ativa = ?,ordem = ?,tamanhoMaximo = ?,idCategoria = ? WHERE id = ?';
      await _db.rawUpdate(
          sql, [pergunta.descricao, pergunta.tipoResposta, pergunta.obrigatorio, pergunta.ativa, pergunta.ordem, pergunta.tamanhoMaximo, pergunta.categorias?.id, pergunta.id]);

      for (var e in pergunta.listOpcoes!) {
        await OpcaoDAOImpl().update(e);
      }
    } catch (ex) {
      throw Exception("Erro Pergunta (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Pergunta>> selectSimple(Pergunta pergunta, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Pergunta> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM pergunta WHERE id = ?", [pergunta.id]);
          break;
        case TipoConsultaDB.PorCategoria:
          resultado = await _db.rawQuery("SELECT * FROM pergunta WHERE idCategoria = ?", [pergunta.categorias?.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('pergunta');
          break;
        default:
          resultado = await _db.query('pergunta');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Pergunta(
              id: linha['id'],
              descricao: linha['descricao'],
              tipoResposta: linha['tipoResposta'],
              obrigatorio: (linha['obrigatorio'] == 0) ? false : true,
              ativa: (linha['ativa'] == 0) ? false : true,
              ordem: linha['ordem'],
              tamanhoMaximo: linha['tamanhoMaximo'],
              listOpcoes: [],
              categorias: CategoriaPergunta(id: linha['idCategoria'])),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Pergunta (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
