import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/domain/interfaces/pais_dao.dart';
import 'package:milkroute_tecnico/model/pais.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class PaisDAOImpl implements PaisDAO {
  late Database _db;

  @override
  // ignore: missing_return
  Future<List<Pais>> selectAll(Pais pais, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Pais> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM pais WHERE nome = ?", [pais.nome]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('pais');
          break;
        default:
          resultado = await _db.query('pais');
          break;
      }

      for (var linha in resultado) {
        lista.add(Pais(nome: linha['nome']));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro País (SelectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<Pais?> carregarPais(String nome) async {
    try {
      var array = await PaisDAOImpl().selectAll(Pais(nome: nome), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Pais(
          nome: array[0].nome,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro País (loadPais): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String nome) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM pais WHERE nome = ?';
      await _db.rawDelete(sql, [nome]);
    } catch (ex) {
      throw Exception("Erro País (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Pais pais) async {
    try {
      _db = (await Connection.get())!;
      var sql;

      sql = 'REPLACE INTO pais (nome) VALUES (?)';
      await _db.rawInsert(sql, [pais.nome]);
    } catch (ex) {
      throw Exception("Erro País (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Pais pais) async {
    try {
      _db = (await Connection.get())!;
      var sql;

      sql = 'REPLACE INTO pais (nome) VALUES (?)';
      await _db.rawUpdate(sql, [pais.nome]);
    } catch (ex) {
      throw Exception("Erro País (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Pais>> selectSimple(Pais pais, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Pais> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM pais WHERE nome = ?", [pais.nome]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('pais');
          break;
        default:
          resultado = await _db.query('pais');
          break;
      }

      for (var linha in resultado) {
        lista.add(Pais(nome: linha['nome']));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro País (SelectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
