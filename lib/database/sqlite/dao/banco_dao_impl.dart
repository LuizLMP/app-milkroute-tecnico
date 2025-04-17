import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/domain/interfaces/banco_dao.dart';
import 'package:milkroute_tecnico/model/banco.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class BancoDAOImpl implements BancoDAO {
  late Database _db;

  @override
  // ignore: missing_return
  Future<List<Banco>> selectAll(Banco banco, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Banco> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM banco WHERE codFebraban = ?", [banco.codFebraban]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('banco');
          break;
        default:
          resultado = await _db.query('banco');
          break;
      }

      for (var linha in resultado) {
        lista.add(Banco(
          codFebraban: linha['codFebraban'],
          nomeBanco: linha['nomeBanco'],
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Banco (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<Banco?> carregarBanco(String codFebraban) async {
    try {
      var array = await selectAll(Banco(codFebraban: codFebraban), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Banco(
          nomeBanco: array[0].nomeBanco,
          codFebraban: array[0].codFebraban,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Banco (loadBanco): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String codFebraban) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM banco WHERE codFebraban = ?';
      await _db.rawDelete(sql, [codFebraban]);
    } catch (ex) {
      throw Exception("Erro Banco (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Banco banco) async {
    try {
      _db = (await Connection.get())!;
      String sql;
      sql = 'REPLACE INTO banco (codFebraban, nomeBanco) VALUES (?,?)';
      await _db.rawInsert(sql, [banco.codFebraban, banco.nomeBanco]);
    } catch (ex) {
      throw Exception("Erro Banco (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Banco banco) async {
    try {
      _db = (await Connection.get())!;
      String sql;
      sql = 'UPDATE banco SET nomeBanco = ? WHERE codFebraban = ?';
      await _db.rawUpdate(sql, [banco.nomeBanco, banco.codFebraban]);
    } catch (ex) {
      throw Exception("Erro Banco (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<void> insertAll(List<Banco> listBanco) async {
    try {
      _db = (await Connection.get())!;
      // Salva ou substitui o registro do banco usando 'REPLACE INTO'

      Batch batch = _db.batch();
      for (var banco in listBanco) {
        batch.rawInsert(
          'REPLACE INTO BANCO (codFebraban, nomeBanco) VALUES (?,?)',
          [banco.codFebraban, banco.nomeBanco],
        );
      }

      await batch.commit(noResult: true);
    } catch (ex) {
      throw Exception("Erro Banco (replace): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Banco>> selectSimple(Banco banco, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Banco> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM banco WHERE codFebraban = ?", [banco.codFebraban]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('banco');
          break;
        default:
          resultado = await _db.query('banco');
          break;
      }

      for (var linha in resultado) {
        lista.add(Banco(
          codFebraban: linha['codFebraban'],
          nomeBanco: linha['nomeBanco'],
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Banco (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
