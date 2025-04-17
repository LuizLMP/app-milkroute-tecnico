import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/domain/interfaces/movimento_produtor_dao.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/movimento_leite.dart';
import 'package:sqflite/sqflite.dart';

class MovimentoLeiteProdutorDAOImpl implements MovimentoLeiteProdutorDAO {
  late Database _db;

  // ignore: missing_return
  @override
  Future<List<MovimentoLeiteProdutor>> selectAll(MovimentoLeiteProdutor movimentoLeiteProdutor, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<MovimentoLeiteProdutor> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM movimento_leite_produtor WHERE id = ?", [movimentoLeiteProdutor.id]);
          break;
        case TipoConsultaDB.PorPropriedade:
          resultado = await _db.rawQuery("SELECT * FROM movimento_leite_produtor WHERE codProdutor = ?", [movimentoLeiteProdutor.codProdutor]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('movimento_leite_produtor');
          break;
        default:
          resultado = await _db.query('movimento_leite_produtor');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          MovimentoLeiteProdutor(
              id: linha['id'],
              codProdutor: linha['codProdutor'],
              nomePropriedade: linha['nomePropriedade'],
              numeroDocumento: linha['numeroDocumento'],
              nrMapa: linha['nrMapa'],
              dataColeta: linha['dataColeta'] != null ? DateTime.parse(linha['dataColeta']) : DateTime.parse('0001-01-01 00:00:00'),
              quantidade: linha['quantidade'],
              media: linha['media'],
              ano: linha['ano'],
              mes: linha['mes']),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro MovimentoLeiteProdutor (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<MovimentoLeiteProdutor?> carregarMovimentoLeiteProdutor(int id) async {
    try {
      var array = await MovimentoLeiteProdutorDAOImpl().selectAll(MovimentoLeiteProdutor(id: id), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return MovimentoLeiteProdutor(
            id: array[0].id,
            codProdutor: array[0].codProdutor,
            nomePropriedade: array[0].nomePropriedade,
            numeroDocumento: array[0].numeroDocumento,
            nrMapa: array[0].nrMapa,
            dataColeta: array[0].dataColeta,
            quantidade: array[0].quantidade,
            media: array[0].media,
            ano: array[0].ano,
            mes: array[0].mes);
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro MovimentoLeiteProdutor (loadCidade): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String id, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM movimento_leite_produtor WHERE id = ?';
      await _db.rawDelete(sql, [id]);
    } catch (ex) {
      throw Exception("Erro MovimentoLeiteProdutor (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(MovimentoLeiteProdutor movimentoLeite) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = '''
          REPLACE INTO movimento_leite_produtor (id, codProdutor, nomePropriedade, numeroDocumento,
          nrMapa, dataColeta, quantidade, media, ano, mes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''';
      await _db.rawInsert(sql, [
        movimentoLeite.id,
        movimentoLeite.codProdutor,
        movimentoLeite.nomePropriedade,
        movimentoLeite.numeroDocumento,
        movimentoLeite.nrMapa,
        DateFormat(dateFormatAPI).format(movimentoLeite.dataColeta!),
        movimentoLeite.quantidade,
        movimentoLeite.media,
        movimentoLeite.ano,
        movimentoLeite.mes
      ]);
    } catch (ex) {
      throw Exception("Erro MovimentoLeiteProdutor (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(MovimentoLeiteProdutor movimentoLeite) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = '''
              UPDATE movimento_leite_produtor SET 
              codProdutor = ?, nomePropriedade = ?, numeroDocumento = ?, nrMapa = ?, 
              dataColeta = ?, quantidade = ?, media = ?, ano = ?, mes = ? 
              WHERE id = ?
            ''';
      await _db.rawUpdate(sql, [
        movimentoLeite.codProdutor,
        movimentoLeite.nomePropriedade,
        movimentoLeite.numeroDocumento,
        movimentoLeite.nrMapa,
        movimentoLeite.dataColeta,
        movimentoLeite.quantidade,
        movimentoLeite.media,
        movimentoLeite.ano,
        movimentoLeite.mes,
        movimentoLeite.id
      ]);
    } catch (ex) {
      throw Exception("Erro MovimentoLeiteProdutor (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)} | Registro: ${movimentoLeite.toJson()}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<MovimentoLeiteProdutor>> selectSimple(MovimentoLeiteProdutor movimentoLeiteProdutor, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<MovimentoLeiteProdutor> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM movimento_leite_produtor WHERE id = ?", [movimentoLeiteProdutor.id]);
          break;
        case TipoConsultaDB.PorPropriedade:
          resultado = await _db.rawQuery("SELECT * FROM movimento_leite_produtor WHERE codProdutor = ?", [movimentoLeiteProdutor.codProdutor]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('movimento_leite_produtor');
          break;
        default:
          resultado = await _db.query('movimento_leite_produtor');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          MovimentoLeiteProdutor(
              id: linha['id'],
              codProdutor: linha['codProdutor'],
              nomePropriedade: linha['nomePropriedade'],
              numeroDocumento: linha['numeroDocumento'],
              nrMapa: linha['nrMapa'],
              dataColeta: linha['dataColeta'],
              quantidade: linha['quantidade'],
              media: linha['media'],
              ano: linha['ano'],
              mes: linha['mes']),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro MovimentoLeiteProdutor (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
