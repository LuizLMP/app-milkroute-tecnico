import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/cidade_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/pessoa_dao.dart';
import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/model/pessoa.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class PessoaDAOImpl implements PessoaDAO {
  late Database _db;

  @override
  Future<List<Pessoa>> selectAll(Pessoa pessoa, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Pessoa> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM pessoa WHERE codProdutor = ?", [pessoa.codigoProdutor]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('pessoa');
          break;
        default:
          resultado = await _db.query('pessoa');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Pessoa(
              codigoProdutor: linha['codProdutor'],
              numeroDocumento: linha['numeroDocumento'],
              nomeRazaoSocial: linha['nomeRazaoSocial'],
              nomeFantasia: linha['nomeFantasia'],
              contato: linha['contato'],
              endereco: linha['endereco'],
              numero: linha['numero'],
              bairro: linha['bairro'],
              complemento: linha['complemento'],
              pontoReferencia: linha['pontoReferencia'],
              cidade: await CidadeDAOImpl().carregarCidade(linha['codigoMunIbge']),
              cep: linha['cep'],
              email: linha['email'],
              telefone: linha['telefone'],
              celular: linha['celular'],
              telefoneComercial: linha['telefoneComercial'],
              inscricaoEstadual: linha['inscricaoEstadual'],
              inscricaoMunicipal: linha['inscricaoMunicipal'],
              dataNascimentoFundacao: linha['dataNascimentoFundacao'],
              nomeMae: linha['nomeMae'],
              nomePai: linha['nomePai']),
        );
      }

      lista.sort(
        (a, b) {
          return a.nomeRazaoSocial!.compareTo(b.nomeRazaoSocial!);
        },
      );

      return lista;
    } catch (ex) {
      throw Exception("Erro Produtor (SelectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<Pessoa?> carregarPessoa(int codigoProdutor) async {
    try {
      var array = await PessoaDAOImpl().selectAll(Pessoa(codigoProdutor: codigoProdutor), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Pessoa(
          codigoProdutor: array[0].codigoProdutor,
          numeroDocumento: array[0].numeroDocumento,
          nomeRazaoSocial: array[0].nomeRazaoSocial,
          nomeFantasia: array[0].nomeFantasia,
          contato: array[0].contato,
          endereco: array[0].endereco,
          numero: array[0].numero,
          bairro: array[0].bairro,
          complemento: array[0].complemento,
          pontoReferencia: array[0].pontoReferencia,
          cidade: array[0].cidade,
          cep: array[0].cep,
          email: array[0].email,
          telefone: array[0].telefone,
          celular: array[0].celular,
          telefoneComercial: array[0].telefoneComercial,
          inscricaoEstadual: array[0].inscricaoEstadual,
          inscricaoMunicipal: array[0].inscricaoMunicipal,
          tipoDocumento: array[0].tipoDocumento,
          dataNascimentoFundacao: array[0].dataNascimentoFundacao,
          nomeMae: array[0].nomeMae,
          nomePai: array[0].nomePai,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Produtor (carregarPessoa): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(int codigoProduto) async {
    try {
      _db = (await Connection.get())!;
      var sql = 'DELETE FROM pessoa WHERE codProdutor = ?';
      await _db.rawDelete(sql, [codigoProduto]);
    } catch (ex) {
      throw Exception("Erro Produtor (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Pessoa pessoa) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = ''' REPLACE INTO pessoa (
                  codProdutor, numeroDocumento, nomeRazaoSocial, nomeFantasia, contato, endereco, numero, 
                  bairro, complemento, pontoReferencia, codigoMunIbge, cep, email, telefone, celular, 
                  telefoneComercial, inscricaoEstadual, inscricaoMunicipal, dataNascimentoFundacao, 
                  nomeMae, nomePai
                  ) VALUES (
                    ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
                  )
            ''';
      await _db.rawInsert(sql, [
        pessoa.codigoProdutor,
        pessoa.numeroDocumento,
        pessoa.nomeRazaoSocial?.replaceAll("/", "-"),
        pessoa.nomeFantasia?.replaceAll("/", "-"),
        pessoa.contato,
        pessoa.endereco,
        pessoa.numero,
        pessoa.bairro,
        pessoa.complemento,
        pessoa.pontoReferencia,
        (pessoa.cidade == null) ? null : pessoa.cidade?.codigoMunIbge,
        pessoa.cep,
        pessoa.email,
        pessoa.telefone,
        pessoa.celular,
        pessoa.telefoneComercial,
        pessoa.inscricaoEstadual,
        pessoa.inscricaoMunicipal,
        pessoa.dataNascimentoFundacao,
        pessoa.nomeMae,
        pessoa.nomePai
      ]);
    } catch (ex) {
      throw Exception("Erro Produtor (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Pessoa pessoa) async {
    try {
      await CidadeDAOImpl().update(pessoa.cidade!);

      _db = (await Connection.get())!;
      var sql;
      sql = '''
              UPDATE pessoa 
              SET 
                numeroDocumento = ?, nomeRazaoSocial = ?, nomeFantasia = ?, contato = ?, endereco = ?, numero = ?, 
                bairro = ?, complemento = ?, pontoReferencia = ?, codigoMunIbge = ?, cep = ?, email = ?, telefone = ?,
                celular = ?, telefoneComercial = ?, inscricaoEstadual = ?, inscricaoMunicipal = ?,
                dataNascimentoFundacao = ?, nomeMae = ?, nomePai = ?
              WHERE
                codProdutor = ?
            ''';

      await _db.rawUpdate(sql, [
        pessoa.numeroDocumento,
        pessoa.nomeRazaoSocial,
        pessoa.nomeFantasia,
        pessoa.contato,
        pessoa.endereco,
        pessoa.numero,
        pessoa.bairro,
        pessoa.complemento,
        pessoa.pontoReferencia,
        pessoa.cidade?.codigoMunIbge,
        pessoa.cep,
        pessoa.email,
        pessoa.telefone,
        pessoa.celular,
        pessoa.telefoneComercial,
        pessoa.inscricaoEstadual,
        pessoa.inscricaoMunicipal,
        pessoa.dataNascimentoFundacao,
        pessoa.nomeMae,
        pessoa.nomePai,
        pessoa.codigoProdutor
      ]);
    } catch (ex) {
      throw Exception("Erro Produtor (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  // ignore: missing_return
  Future<List<Pessoa>> selectSimple(Pessoa pessoa, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Pessoa> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM pessoa WHERE codProdutor = ?", [pessoa.codigoProdutor]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('pessoa');
          break;
        default:
          resultado = await _db.query('pessoa');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          Pessoa(
              codigoProdutor: linha['codProdutor'],
              numeroDocumento: linha['numeroDocumento'],
              nomeRazaoSocial: linha['nomeRazaoSocial'],
              nomeFantasia: linha['nomeFantasia'],
              contato: linha['contato'],
              endereco: linha['endereco'],
              numero: linha['numero'],
              bairro: linha['bairro'],
              complemento: linha['complemento'],
              pontoReferencia: linha['pontoReferencia'],
              cidade: Cidade(codigoMunIbge: linha['codigoMunIbge']),
              cep: linha['cep'],
              email: linha['email'],
              telefone: linha['telefone'],
              celular: linha['celular'],
              telefoneComercial: linha['telefoneComercial'],
              inscricaoEstadual: linha['inscricaoEstadual'],
              inscricaoMunicipal: linha['inscricaoMunicipal'],
              dataNascimentoFundacao: linha['dataNascimentoFundacao'],
              nomeMae: linha['nomeMae'],
              nomePai: linha['nomePai']),
        );
      }

      lista.sort(
        (a, b) {
          return a.nomeRazaoSocial!.compareTo(b.nomeRazaoSocial!);
        },
      );

      return lista;
    } catch (ex) {
      throw Exception("Erro Produtor (SelectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
