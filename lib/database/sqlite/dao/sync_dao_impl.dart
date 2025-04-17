import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/domain/interfaces/sync_dao.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/sync.dart';
import 'package:sqflite/sqflite.dart';

class SyncDAOImpl implements SyncDAO {
  late Database _db;

  @override
  Future<List<Sync>> selectAll(Sync sync, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<Sync> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM sync_entidades WHERE nomeEntidade = ?", [sync.nomeTabela]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('sync_entidades');
          break;
        default:
          resultado = await _db.query('sync_entidades');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Sync(
            nomeTabela: linha['nomeEntidade'],
            dataHora: linha['dataHoraLastSync'] != null ? DateTime.parse(linha['dataHoraLastSync']) : DateTime.parse('0001-01-01 00:00:00'),
            id: linha['idRegWeb'],
          ),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception('Erro Sync (selectAll): $ex');
    }
  }

  @override
  Future<Sync?> carregarSync(String entidade) async {
    try {
      var array = await selectAll(Sync(nomeTabela: entidade), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Sync(
          nomeTabela: array[0].nomeTabela,
          dataHora: array[0].dataHora,
          id: array[0].id,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception('Erro Sync (carregarSync): $ex');
    }
  }

  @override
  Future replace(Sync sync) async {
    try {
      _db = (await Connection.get())!;
      var sql = "REPLACE INTO sync_entidades (nomeEntidade, dataHoraLastSync, idRegWeb) VALUES (?, ?, ?)";

      await _db.rawQuery(sql, [
        sync.nomeTabela,
        DateFormat(dateFormatAPI).format(sync.dataHora!),
        sync.id,
      ]);
    } catch (ex) {
      throw Exception('Erro Sync (insert): $ex');
    }
  }

  @override
  Future remove(String nomeTabela) async {
    try {
      _db = (await Connection.get())!;
      var sql = "DELETE FROM sync_entidades WHERE nomeEntidade = ?";
      await _db.rawDelete(sql, [nomeTabela]);
    } catch (ex) {
      throw Exception('Erro Sync (remove): $ex');
    }
  }

  @override
  Future update(Sync sync) async {
    try {
      _db = (await Connection.get())!;
      var sql = "UPDATE sync_entidades SET dataHoraLastSync = ?, idRegWeb = ? WHERE nomeEntidade = ?";

      _db.rawUpdate(sql, [
        DateFormat(dateFormatAPI).format(sync.dataHora!),
        sync.id,
        sync.nomeTabela,
      ]);
    } catch (ex) {
      throw Exception('Erro Sync (update): $ex');
    }
  }
}
