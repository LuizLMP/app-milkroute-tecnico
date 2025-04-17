import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/pessoa_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/propriedade_dao.dart';
import 'package:milkroute_tecnico/model/pessoa.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class PropriedadeDAOImpl implements PropriedadeDAO {
  late Database _db;

  @override
  Future<List<Propriedade>> selectAll(Propriedade propriedade, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Propriedade> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM propriedade WHERE id = ?", [propriedade.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('propriedade');
          break;
        default:
          resultado = await _db.query('propriedade');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Propriedade(
              id: linha['id'],
              pessoa: await PessoaDAOImpl().carregarPessoa(linha['codProdutor']),
              codProdutor: linha['codProdutor'],
              nomePropriedade: linha['nomePropriedade'],
              ativa: linha['ativa'] == 1 ? true : false,
              latitude: double.tryParse(linha['latitude']),
              longitude: double.tryParse(linha['longitude']),
              propriedadeBeneficiaria: (linha['idPropriedadeBeneficiaria'] == null) ? null : await PropriedadeDAOImpl().carregarPropriedade(linha['idPropriedadeBeneficiaria']),
              dataCadastro: linha['dataCadastro'],
              volumeMedio: linha['volumeMedio'],
              possuiBeneficiario: linha['possuiBeneficiario'] == 1 ? true : false,
              nomeAbreviado: linha['nomeAbreviado'],
              situacao: linha['situacao'],
              firstName: linha['firstName'],
              lastName: linha['lastName'],
              codigoNomeProdutor: linha['codigoNomeProdutor']),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Propriedade (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<Propriedade?> carregarPropriedade(int id) async {
    try {
      var arrayPropriedade = await PropriedadeDAOImpl().selectAll(Propriedade(id: id), TipoConsultaDB.PorPK);

      if (arrayPropriedade.isNotEmpty) {
        return Propriedade(
            id: arrayPropriedade[0].id,
            pessoa: arrayPropriedade[0].pessoa,
            codProdutor: arrayPropriedade[0].codProdutor,
            nomePropriedade: arrayPropriedade[0].nomePropriedade,
            ativa: arrayPropriedade[0].ativa,
            latitude: arrayPropriedade[0].latitude,
            longitude: arrayPropriedade[0].longitude,
            propriedadeBeneficiaria: arrayPropriedade[0].propriedadeBeneficiaria,
            dataCadastro: arrayPropriedade[0].dataCadastro,
            volumeMedio: arrayPropriedade[0].volumeMedio,
            possuiBeneficiario: arrayPropriedade[0].possuiBeneficiario,
            codigoNomeProdutor: arrayPropriedade[0].codigoNomeProdutor,
            nomeAbreviado: arrayPropriedade[0].nomeAbreviado,
            situacao: arrayPropriedade[0].situacao,
            firstName: arrayPropriedade[0].firstName,
            lastName: arrayPropriedade[0].lastName);
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Propriedade (loadPropriedade): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(int codProdutor) async {
    _db = (await Connection.get())!;
    var sql = 'DELETE FROM propriedade WHERE codProdutor = ?';
    await _db.rawDelete(sql, [codProdutor]);
  }

  @override
  Future insert(Propriedade propriedade) async {
    try {
      Pessoa? produtor = propriedade.pessoa;
      produtor?.codigoProdutor = propriedade.codProdutor;

      await PessoaDAOImpl().insert(produtor!);

      _db = (await Connection.get())!;
      String sql;
      sql = '''
          REPLACE INTO propriedade (
              id, codProdutor, nomePropriedade, ativa, latitude, longitude, idPropriedadeBeneficiaria, 
              dataCadastro, volumeMedio, possuiBeneficiario, nomeAbreviado, situacao, firstName, 
              lastName, codigoNomeProdutor
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''';

      await _db.rawInsert(sql, [
        propriedade.id,
        propriedade.codProdutor,
        propriedade.nomePropriedade,
        propriedade.ativa,
        propriedade.latitude.toString(),
        propriedade.longitude.toString(),
        (propriedade.propriedadeBeneficiaria == null) ? null : propriedade.propriedadeBeneficiaria?.id,
        propriedade.dataCadastro,
        propriedade.volumeMedio,
        propriedade.possuiBeneficiario,
        propriedade.nomeAbreviado,
        propriedade.situacao,
        propriedade.firstName,
        propriedade.lastName,
        propriedade.codigoNomeProdutor
      ]);
    } catch (ex) {
      throw Exception("Erro Propriedade (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Propriedade propriedade) async {
    _db = (await Connection.get())!;
    String sql;
    sql = '''
          UPDATE propriedade
          SET
            nomePropriedade = ?, ativa = ?, latitude = ?, longitude = ?,
            idPropriedadeBeneficiaria = ?, dataCadastro = ?, volumeMedio = ?, possuiBeneficiario = ?, 
            nomeAbreviado = ?, situacao = ?, firstName = ?, lastName = ?, codigoNomeProdutor = ?
          WHERE
            id = ?
        ''';

    await _db.rawUpdate(sql, [
      propriedade.nomePropriedade,
      propriedade.ativa,
      propriedade.latitude,
      propriedade.longitude,
      propriedade.propriedadeBeneficiaria?.id,
      propriedade.dataCadastro,
      propriedade.volumeMedio,
      propriedade.possuiBeneficiario,
      propriedade.nomeAbreviado,
      propriedade.situacao,
      propriedade.firstName,
      propriedade.lastName,
      propriedade.codProdutor,
      propriedade.codigoNomeProdutor,
      propriedade.id
    ]);
  }

  @override
  Future<List<Propriedade>> selectSimple(Propriedade propriedade, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Propriedade> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM propriedade WHERE id = ?", [propriedade.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('propriedade');
          break;
        default:
          resultado = await _db.query('propriedade');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Propriedade(
              id: linha['id'],
              pessoa: null,
              codProdutor: linha['codProdutor'],
              nomePropriedade: linha['nomePropriedade'],
              ativa: linha['ativa'] == 1 ? true : false,
              latitude: double.tryParse(linha['latitude']),
              longitude: double.tryParse(linha['longitude']),
              propriedadeBeneficiaria: null,
              dataCadastro: linha['dataCadastro'],
              volumeMedio: linha['volumeMedio'],
              possuiBeneficiario: linha['possuiBeneficiario'] == 1 ? true : false,
              nomeAbreviado: linha['nomeAbreviado'],
              situacao: linha['situacao'],
              firstName: linha['firstName'],
              lastName: linha['lastName'],
              codigoNomeProdutor: linha['codigoNomeProdutor']),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Propriedade (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
