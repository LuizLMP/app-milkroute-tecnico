import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/estado_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/cidade_dao.dart';
import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/model/estado.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:collection/collection.dart';

class CidadeDAOImpl implements CidadeDAO {
  late Database _db;

  @override
  // ignore: missing_return
  Future<List<Cidade>> selectAll(Cidade cidade, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Cidade> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM cidade WHERE codigoMunIbge = ?", [cidade.codigoMunIbge]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('cidade');
          break;
        default:
          resultado = await _db.query('cidade');
          break;
      }

      for (var linha in resultado) {
        lista.add(Cidade(
          codigoMunIbge: linha['codigoMunIbge'],
          nome: linha['nome'],
          estado: await EstadoDAOImpl().carregarEstado(linha['estado']),
        ));
      }

      return lista;
    } catch (ex) {
      print("Erro Cidade (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return [];
    }
  }

  @override
  // ignore: missing_return
  Future<Cidade?> carregarCidade(int codigoMunIbge) async {
    try {
      var array = await CidadeDAOImpl().selectAll(Cidade(codigoMunIbge: codigoMunIbge), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Cidade(
          nome: array[0].nome,
          codigoMunIbge: array[0].codigoMunIbge,
          estado: array[0].estado,
        );
      } else {
        return null;
      }
    } catch (ex) {
      print("Erro Cidade (loadCidade): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return null;
    }
  }

  @override
  Future remove(String codigoMunIbge) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM cidade WHERE codigoMunIbge = ?';
      await _db.rawDelete(sql, [codigoMunIbge]);
    } catch (ex) {
      print("Erro Cidade (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insertAll(List<Cidade> listCidades) async {
    if (listCidades.isNotEmpty) {
      try {
        _db = (await Connection.get())!;
        Map<String, List<Cidade>> mapEstados = groupBy(listCidades, (Cidade cidade) => cidade.estado!.sigla!);
        List<Estado> listEstados = mapEstados.keys.map((sigla) => Estado(sigla: sigla)).toList();

        await EstadoDAOImpl().insertAll(listEstados);

        Batch batch = _db.batch();
        for (var cidade in listCidades) {
          batch.rawInsert(
            'REPLACE INTO cidade (codigoMunIbge, nome, estado) VALUES (?,?,?)',
            [cidade.codigoMunIbge, cidade.nome, cidade.estado?.sigla],
          );
        }

        await batch.commit(noResult: true);
      } catch (ex) {
        print("Erro Cidade (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      }
    }
  }

  @override
  Future insertOnly(Cidade cidade) async {
    try {
      await EstadoDAOImpl().insertOnly(cidade.estado!);

      _db = (await Connection.get())!;
      var sql;
      sql = 'REPLACE INTO cidade (codigoMunIbge, nome, estado) VALUES (?,?,?)';
      await _db.rawInsert(sql, [cidade.codigoMunIbge, cidade.nome, cidade.estado?.sigla]);
    } catch (ex) {
      print("Erro Cidade (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Cidade cidade) async {
    try {
      await EstadoDAOImpl().update(cidade.estado!);

      _db = (await Connection.get())!;
      var sql;
      sql = 'UPDATE cidade SET nome = ?, estado = ? WHERE codigoMunIbge = ?';
      await _db.rawUpdate(sql, [cidade.nome, cidade.estado!.sigla, cidade.codigoMunIbge]);
    } catch (ex) {
      print("Erro Cidade (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Cidade>> selectSimple(Cidade cidade, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Cidade> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM cidade WHERE codigoMunIbge = ?", [cidade.codigoMunIbge]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('cidade');
          break;
        default:
          resultado = await _db.query('cidade');
          break;
      }

      for (var linha in resultado) {
        lista.add(Cidade(
          codigoMunIbge: linha['codigoMunIbge'],
          nome: linha['nome'],
          estado: Estado(nome: linha['estado']),
        ));
      }

      return lista;
    } catch (ex) {
      print("Erro Cidade (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return [];
    }
  }

  @override
  Future<List<Cidade>> selectByEstado(Cidade cidade, Estado estado) async {
    List<Map<String, dynamic>> resultado = [];
    List<Cidade> lista = [];
    try {
      _db = (await Connection.get())!;
      resultado = await _db.rawQuery("SELECT * FROM cidade WHERE estado = ?", [estado.sigla]);

      for (var linha in resultado) {
        lista.add(Cidade(
          codigoMunIbge: linha['codigoMunIbge'],
          nome: linha['nome'],
          estado: Estado(nome: linha['estado']),
        ));
      }

      return lista;
    } catch (ex) {
      print("Erro Cidade (selectByEstado): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
    return lista;
  }
}
