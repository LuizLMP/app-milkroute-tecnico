import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/cidade_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/pessoa_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/estabelecimento_dao.dart';
import 'package:milkroute_tecnico/model/pessoa.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:sqflite/sqflite.dart';

class EstabelecimentoDAOImpl implements EstabelecimentoDAO {
  late Database _db;

  // ignore: missing_return
  @override
  Future<List<Estabelecimento>> selectAll(Estabelecimento estabelecimento, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Estabelecimento> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM estabelecimento WHERE codEstabel = ?", [estabelecimento.codEstabel]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('estabelecimento');
          break;
        default:
          resultado = await _db.query('estabelecimento');
          break;
      }

      for (var linha in resultado) {
        lista.add(Estabelecimento(
          codEstabel: linha['codEstabel'].toString(),
          pessoa: await PessoaDAOImpl().carregarPessoa(linha['idPessoa']),
          regimeEspecialColeta: linha['regimeEspecialColeta'],
          latitude: linha['latitude'],
          longitude: linha['longitude'],
          imagem: linha['imagem'],
          ambienteIntegracao: linha['ambienteIntegracao'],
          codigoNomeEstabel: linha['codigoNomeEstabel'],
          tecnico: Tecnico(id: linha['idTecnico']),
        ));
      }

      return lista;
    } catch (ex) {
      print("Erro Estabelecimento (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return [];
    }
  }

  @override
  Future<List<Estabelecimento>> selectSimple(Estabelecimento estabelecimento, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Estabelecimento> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM estabelecimento WHERE codEstabel = ?", [estabelecimento.codEstabel]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('estabelecimento');
          break;
        default:
          resultado = await _db.query('estabelecimento');
          break;
      }

      for (var linha in resultado) {
        lista.add(Estabelecimento(
          codEstabel: linha['codEstabel'],
          pessoa: Pessoa(codigoProdutor: linha['idPessoa']),
          regimeEspecialColeta: linha['regimeEspecialColeta'],
          latitude: linha['latitude'],
          longitude: linha['longitude'],
          imagem: linha['imagem'],
          ambienteIntegracao: linha['ambienteIntegracao'],
          codigoNomeEstabel: linha['codigoNomeEstabel'],
          tecnico: Tecnico(id: linha['idTecnico']),
        ));
      }

      return lista;
    } catch (ex) {
      print("Erro Estabelecimento (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return [];
    }
  }

  @override
  Future<Estabelecimento?> carregarEstabelecimento(String codEstabel) async {
    try {
      var array = await EstabelecimentoDAOImpl().selectAll(Estabelecimento(codEstabel: codEstabel), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Estabelecimento(
          codEstabel: array[0].codEstabel,
          pessoa: array[0].pessoa,
          regimeEspecialColeta: array[0].regimeEspecialColeta,
          latitude: array[0].latitude,
          longitude: array[0].longitude,
          imagem: array[0].imagem,
          ambienteIntegracao: array[0].ambienteIntegracao,
          codigoNomeEstabel: array[0].codigoNomeEstabel,
          tecnico: array[0].tecnico,
        );
      } else {
        return null;
      }
    } catch (ex) {
      print("Erro Estabelecimento (carregarEstabelecimento): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return null;
    }
  }

  @override
  Future insert(Estabelecimento estabelecimento) async {
    try {
      Pessoa? pessoa = estabelecimento.pessoa;
      pessoa?.codigoProdutor = int.parse(estabelecimento.codEstabel!);

      await CidadeDAOImpl().insertOnly(pessoa!.cidade!);
      await PessoaDAOImpl().insert(pessoa);

      _db = (await Connection.get())!;
      var sql = '''INSERT INTO estabelecimento (codEstabel, idPessoa, regimeEspecialColeta, latitude, longitude, imagem, ambienteIntegracao, codigoNomeEstabel, idTecnico) 
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''';
      _db.rawInsert(sql, [
        estabelecimento.codEstabel,
        estabelecimento.pessoa?.codigoProdutor,
        estabelecimento.regimeEspecialColeta,
        estabelecimento.latitude,
        estabelecimento.longitude,
        estabelecimento.imagem,
        estabelecimento.ambienteIntegracao,
        estabelecimento.codigoNomeEstabel,
        (estabelecimento.tecnico == null) ? null : estabelecimento.tecnico?.id
      ]);
    } catch (ex) {
      print("Erro Estabelecimento (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String codEstabel) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM estabelecimento WHERE codEstabel = ?';
      await _db.rawDelete(sql, [codEstabel]);
    } catch (ex) {
      print("Erro Estabelecimento (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Estabelecimento estabelecimento) async {
    try {
      await PessoaDAOImpl().update(estabelecimento.pessoa!);

      _db = (await Connection.get())!;
      var sql = '''
              UPDATE estabelecimento 
              SET idPessoa = ?, regimeEspecialColeta = ?, latitude = ?, longitude = ?, 
              imagem = ?, ambienteIntegracao = ?, codigoNomeEstabel = ?, idTecnico = ? WHERE codEstabel = ?
            ''';

      await _db.rawUpdate(sql, [
        estabelecimento.pessoa?.codigoProdutor,
        estabelecimento.regimeEspecialColeta,
        estabelecimento.latitude,
        estabelecimento.longitude,
        estabelecimento.imagem,
        estabelecimento.ambienteIntegracao,
        estabelecimento.codigoNomeEstabel,
        estabelecimento.tecnico?.id,
        estabelecimento.codEstabel,
      ]);
    } catch (ex) {
      print("Erro Estabelecimento (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
