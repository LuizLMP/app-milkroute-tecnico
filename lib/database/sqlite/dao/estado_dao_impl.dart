import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/pais_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/estado_dao.dart';
import 'package:milkroute_tecnico/model/estado.dart';
import 'package:milkroute_tecnico/model/pais.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class EstadoDAOImpl implements EstadoDAO {
  late Database _db;

  // ignore: missing_return
  @override
  Future<List<Estado>> selectAll(Estado estado, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Estado> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM estado WHERE sigla = ?", [estado.sigla]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('estado');
          break;
        default:
          resultado = await _db.query('estado');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Estado(
            sigla: linha['sigla'],
            nome: linha['nome'],
            pais: await PaisDAOImpl().carregarPais(linha['pais']),
          ),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Estado (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  // ignore: missing_return
  @override
  Future<Estado?> carregarEstado(String sigla) async {
    try {
      var array = await EstadoDAOImpl().selectAll(Estado(sigla: sigla), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Estado(
          sigla: array[0].sigla,
          nome: array[0].nome,
          pais: array[0].pais,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Estado (loadEstado): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String sigla) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM estado WHERE sigla = ?';
      await _db.rawDelete(sql, [sigla]);
    } catch (ex) {
      throw Exception("Erro Estado (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insertAll(List<Estado> listEstado) async {
    try {
      Pais pais = Pais(nome: "Brasil");
      await PaisDAOImpl().insert(pais);

      _db = (await Connection.get())!;
      Batch batch = _db.batch();
      for (var estado in listEstado) {
        batch.rawInsert(
          'REPLACE INTO estado (sigla, nome, pais) VALUES (?,?,?)',
          [estado.sigla, "", pais.nome],
        );
      }
      await batch.commit(noResult: true);
    } catch (ex) {
      throw Exception("Erro Estado (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insertOnly(Estado estado) async {
    try {
      await PaisDAOImpl().insert(estado.pais!);

      _db = (await Connection.get())!;
      var sql;
      sql = 'REPLACE INTO estado (sigla, nome, pais) VALUES (?,?,?)';
      await _db.rawInsert(sql, [estado.sigla, estado.nome, estado.pais?.nome]);
    } catch (ex) {
      throw Exception("Erro Estado (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Estado estado) async {
    try {
      PaisDAOImpl().update(estado.pais!);

      _db = (await Connection.get())!;
      String sql;
      sql = 'UPDATE estado SET nome = ?, pais = ? WHERE sigla = ?';
      await _db.rawUpdate(sql, [estado.nome, estado.pais?.nome, estado.sigla]);
    } catch (ex) {
      throw Exception("Erro Estado (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Estado>> selectSimple(Estado estado, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Estado> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM estado WHERE sigla = ?", [estado.sigla]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('estado');
          break;
        default:
          resultado = await _db.query('estado');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Estado(
            sigla: linha['sigla'],
            nome: linha['nome'],
            pais: Pais(nome: linha['pais']),
          ),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Estado (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
