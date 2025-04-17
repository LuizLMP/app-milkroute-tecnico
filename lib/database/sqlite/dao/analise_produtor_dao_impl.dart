import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/domain/interfaces/analise_produtor_dao.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/analise_leite.dart';
import 'package:sqflite/sqflite.dart';

class AnaliseLeiteProdutorDAOImpl implements AnaliseLeiteProdutorDAO {
  late Database _db;

  @override
  // ignore: missing_return
  Future<List<AnaliseLeiteProdutor>> selectAll(AnaliseLeiteProdutor analiseLeiteProdutor, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<AnaliseLeiteProdutor> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM analise_leite_produtor WHERE id = ?", [analiseLeiteProdutor.id]);
          break;
        case TipoConsultaDB.PorPropriedade:
          resultado = await _db.rawQuery("SELECT * FROM analise_leite_produtor WHERE codProdutor = ?", [analiseLeiteProdutor.codProdutor]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('analise_leite_produtor');
          break;
        default:
          resultado = await _db.query('analise_leite_produtor');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          AnaliseLeiteProdutor(
              id: linha['id'],
              codProdutor: linha['codProdutor'],
              nomePropriedade: linha['nomePropriedade'],
              codEstabel: linha['codEstabel'],
              codRota: linha['codRota'],
              denominacaoRota: linha['denominacaoRota'],
              codigo: linha['codigo'].toString(),
              data: linha['data'] != null ? DateTime.parse(linha['data']) : DateTime.parse('0001-01-01 00:00:00'),
              gordura: linha['gordura'],
              proteina: linha['proteina'],
              lactose: linha['lactose'],
              solidosTotais: linha['solidosTotais'],
              esd: linha['esd'],
              ccs: linha['ccs'],
              cbt: linha['cbt'],
              redutase: linha['redutase'],
              nu: linha['nu'],
              acidez: linha['acidez'],
              cri: linha['cri'],
              observacoes: linha['observacoes'].toString()),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro AnaliseLeiteProdutor (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<AnaliseLeiteProdutor?> carregarAnaliseLeiteProdutor(int id) async {
    try {
      var array = await AnaliseLeiteProdutorDAOImpl().selectAll(AnaliseLeiteProdutor(id: id), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return AnaliseLeiteProdutor(
            id: array[0].id,
            codProdutor: array[0].codProdutor,
            nomePropriedade: array[0].nomePropriedade,
            codEstabel: array[0].codEstabel,
            codRota: array[0].codRota,
            denominacaoRota: array[0].denominacaoRota,
            codigo: array[0].codigo,
            data: array[0].data,
            gordura: array[0].gordura,
            proteina: array[0].proteina,
            lactose: array[0].lactose,
            solidosTotais: array[0].solidosTotais,
            esd: array[0].esd,
            ccs: array[0].ccs,
            cbt: array[0].cbt,
            redutase: array[0].redutase,
            nu: array[0].nu,
            acidez: array[0].acidez,
            cri: array[0].cri,
            observacoes: array[0].observacoes);
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro AnaliseLeiteProdutor (loadCidade): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String id, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM analise_leite_produtor WHERE id = ?';
      await _db.rawDelete(sql, [id]);
    } catch (ex) {
      throw Exception("Erro AnaliseLeiteProdutor (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(AnaliseLeiteProdutor analiseLeite) async {
    try {
      _db = (await Connection.get())!;
      String sql;
      sql = '''
              REPLACE INTO analise_leite_produtor (
                id, codProdutor, nomePropriedade, codEstabel, codRota, denominacaoRota,
                codigo, data, gordura, proteina, lactose, solidosTotais, esd, ccs, cbt,
                redutase, nu, acidez, cri, observacoes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''';
      await _db.rawInsert(sql, [
        analiseLeite.id,
        analiseLeite.codProdutor,
        analiseLeite.nomePropriedade,
        analiseLeite.codEstabel,
        analiseLeite.codRota,
        analiseLeite.denominacaoRota,
        analiseLeite.codigo,
        DateFormat(dateFormatAPI).format(analiseLeite.data!),
        analiseLeite.gordura,
        analiseLeite.proteina,
        analiseLeite.lactose,
        analiseLeite.solidosTotais,
        analiseLeite.esd,
        analiseLeite.ccs,
        analiseLeite.cbt,
        analiseLeite.redutase,
        analiseLeite.nu,
        analiseLeite.acidez,
        analiseLeite.cri,
        analiseLeite.observacoes
      ]);
    } catch (ex) {
      throw Exception("Erro AnaliseLeiteProdutor (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)} | Registro: ${analiseLeite.toJson()}");
    }
  }

  @override
  Future update(AnaliseLeiteProdutor analiseLeite) async {
    try {
      _db = (await Connection.get())!;
      String sql;
      sql = '''
            UPDATE analise_leite_produtor SET 
            codProdutor = ?, nomePropriedade = ?, codEstabel = ?, codRota = ?, denominacaoRota = ?, 
            codigo = ?, data = ?, gordura = ?, proteina = ?, lactose = ?, solidosTotais = ?, 
            esd = ?, ccs = ?, cbt = ?, redutase = ?, nu = ?, acidez = ?, cri = ?, observacoes = ?          
            WHERE id = ?
          ''';
      await _db.rawUpdate(sql, [
        analiseLeite.codProdutor,
        analiseLeite.nomePropriedade,
        analiseLeite.codEstabel,
        analiseLeite.codRota,
        analiseLeite.denominacaoRota,
        analiseLeite.codigo,
        DateFormat(dateFormatAPI).format(analiseLeite.data!),
        analiseLeite.gordura,
        analiseLeite.proteina,
        analiseLeite.lactose,
        analiseLeite.solidosTotais,
        analiseLeite.esd,
        analiseLeite.ccs,
        analiseLeite.cbt,
        analiseLeite.redutase,
        analiseLeite.nu,
        analiseLeite.acidez,
        analiseLeite.cri,
        analiseLeite.observacoes,
        analiseLeite.id,
      ]);
    } catch (ex) {
      throw Exception("Erro AnaliseLeiteProdutor (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<AnaliseLeiteProdutor>> selectSimple(AnaliseLeiteProdutor analiseLeiteProdutor, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<AnaliseLeiteProdutor> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM analise_leite_produtor WHERE id = ?", [analiseLeiteProdutor.id]);
          break;
        case TipoConsultaDB.PorPropriedade:
          resultado = await _db.rawQuery("SELECT * FROM analise_leite_produtor WHERE codProdutor = ?", [analiseLeiteProdutor.codProdutor]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('analise_leite_produtor');
          break;
        default:
          resultado = await _db.query('analise_leite_produtor');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          AnaliseLeiteProdutor(
              id: linha['id'],
              codProdutor: linha['codProdutor'],
              nomePropriedade: linha['nomePropriedade'],
              codEstabel: linha['codEstabel'],
              codRota: linha['codRota'],
              denominacaoRota: linha['denominacaoRota'],
              codigo: linha['codigo'],
              data: linha['data'],
              gordura: linha['gordura'],
              proteina: linha['proteina'],
              lactose: linha['lactose'],
              solidosTotais: linha['solidosTotais'],
              esd: linha['esd'],
              ccs: linha['ccs'],
              cbt: linha['cbt'],
              redutase: linha['redutase'],
              nu: linha['nu'],
              acidez: linha['acidez'],
              cri: linha['cri'],
              observacoes: linha['observacoes']),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro AnaliseLeiteProdutor (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
