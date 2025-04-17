import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/cidade_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/prepropriedade_dao.dart';
import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/model/prepropriedade.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:sqflite/sqflite.dart';

class PrePropriedadeDAOImpl implements PrePropriedadeDAO {
  late Database _db;

  @override
  Future<List<PrePropriedade>> selectAll(PrePropriedade prePropriedade, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<PrePropriedade> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM pre_propriedade WHERE id = ?", [prePropriedade.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('pre_propriedade');
          break;
        default:
          resultado = await _db.query('pre_propriedade');

          break;
      }

      for (var linha in resultado) {
        lista.add(
          PrePropriedade(
            id: linha['id'],
            numeroDocumento: linha['numeroDocumento'],
            inscEstadual: linha['inscEstadual'],
            rg: linha['rg'],
            nirf: linha['nirf'],
            nrRegProdutor: linha['nrRegProdutor'],
            nomeRazaoSocial: linha['nomeRazaoSocial'],
            nomePropriedade: linha['nomePropriedade'],
            endereco: linha['endereco'],
            numero: linha['numero'],
            bairro: linha['bairro'],
            complemento: linha['complemento'],
            cidade: await CidadeDAOImpl().carregarCidade(linha['codigoMunIbge']),
            cep: linha['cep'],
            telefone: linha['telefone'],
            celular: linha['celular'],
            email: linha['email'],
            banco: linha['banco'],
            agencia: linha['agencia'],
            dvAgencia: linha['dvAgencia'],
            contaBancaria: linha['contaBancaria'],
            dvContaBancaria: linha['dvContaBancaria'],
            observacoes: linha['observacoes'],
            aprovado: linha['aprovado'] == 1 ? true : false,
            reprovado: linha['reprovado'] == 1 ? true : false,
            dataCadastro: linha['dataCadastro'],
            dataAtualizacao: linha['dataAtualizacao'],
            messageProcessamento: linha['messageProcessamento'],
            situacao: linha['situacao'],
            situacaoPropriedade: linha['situacaoPropriedade'],
            origem: linha['origem'],
            diaPagamento: linha['diaPagamento'],
            volumeInicial: linha['volumeInicial'],
            capacidadeResfriador: linha['capacidadeResfriador'],
            nrOrdenhas: linha['nrOrdenhas'],
            tanqueExpansao: linha['tanqueExpansao'] == 1 ? true : false,
            tanqueImersao: linha['tanqueImersao'] == 1 ? true : false,
            latitude: double.tryParse(linha['latitude']),
            longitude: double.tryParse(linha['longitude']),
            novo: linha['novo'] == 1 ? true : false,
            existente: linha['existente'] == 1 ? true : false,
            pendente: linha['pendente'] == 1 ? true : false,
          ),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro PrePropriedade (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<List<PrePropriedade>> selectSimple(PrePropriedade prePropriedade, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<PrePropriedade> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM pre_propriedade WHERE id = ?", [prePropriedade.id]);
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('pre_propriedade');
          break;
        default:
          resultado = await _db.query('pre_propriedade');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          PrePropriedade(
            id: linha['id'],
            numeroDocumento: linha['numeroDocumento'],
            inscEstadual: linha['inscEstadual'],
            rg: linha['rg'],
            nirf: linha['nirf'],
            nrRegProdutor: linha['nrRegProdutor'],
            nomeRazaoSocial: linha['nomeRazaoSocial'],
            nomePropriedade: linha['nomePropriedade'],
            endereco: linha['endereco'],
            numero: linha['numero'],
            bairro: linha['bairro'],
            complemento: linha['complemento'],
            cidade: Cidade(codigoMunIbge: linha['codigoMunIbge']),
            cep: linha['cep'],
            telefone: linha['telefone'],
            celular: linha['celular'],
            email: linha['email'],
            banco: linha['banco'],
            agencia: linha['agencia'],
            dvAgencia: linha['dvAgencia'],
            contaBancaria: linha['contaBancaria'],
            dvContaBancaria: linha['dvContaBancaria'],
            observacoes: linha['observacoes'],
            aprovado: linha['aprovado'] == 1 ? true : false,
            reprovado: linha['reprovado'] == 1 ? true : false,
            dataCadastro: linha['dataCadastro'],
            dataAtualizacao: linha['dataAtualizacao'],
            messageProcessamento: linha['messageProcessamento'],
            situacao: linha['situacao'],
            situacaoPropriedade: linha['situacaoPropriedade'],
            origem: linha['origem'],
            diaPagamento: linha['diaPagamento'],
            volumeInicial: linha['volumeInicial'],
            capacidadeResfriador: linha['capacidadeResfriador'],
            nrOrdenhas: linha['nrOrdenhas'],
            tanqueExpansao: linha['tanqueExpansao'] == 1 ? true : false,
            tanqueImersao: linha['tanqueImersao'] == 1 ? true : false,
            latitude: double.tryParse(linha['latitude']),
            longitude: double.tryParse(linha['longitude']),
            novo: linha['novo'] == 1 ? true : false,
            existente: linha['existente'] == 1 ? true : false,
            pendente: linha['pendente'] == 1 ? true : false,
          ),
        );
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro PrePropriedade (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<PrePropriedade?> carregarPrePropriedade(int id) async {
    try {
      var arrayPropriedade = await PrePropriedadeDAOImpl().selectAll(PrePropriedade(id: id), TipoConsultaDB.PorPK);

      if (arrayPropriedade.isNotEmpty) {
        return PrePropriedade(
          id: arrayPropriedade[0].id,
          numeroDocumento: arrayPropriedade[0].numeroDocumento,
          inscEstadual: arrayPropriedade[0].inscEstadual,
          rg: arrayPropriedade[0].rg,
          nirf: arrayPropriedade[0].nirf,
          nrRegProdutor: arrayPropriedade[0].nrRegProdutor,
          nomeRazaoSocial: arrayPropriedade[0].nomeRazaoSocial,
          nomePropriedade: arrayPropriedade[0].nomePropriedade,
          endereco: arrayPropriedade[0].endereco,
          numero: arrayPropriedade[0].numero,
          bairro: arrayPropriedade[0].bairro,
          complemento: arrayPropriedade[0].complemento,
          cidade: arrayPropriedade[0].cidade,
          cep: arrayPropriedade[0].cep,
          telefone: arrayPropriedade[0].telefone,
          celular: arrayPropriedade[0].celular,
          email: arrayPropriedade[0].email,
          banco: arrayPropriedade[0].banco,
          agencia: arrayPropriedade[0].agencia,
          dvAgencia: arrayPropriedade[0].dvAgencia,
          contaBancaria: arrayPropriedade[0].contaBancaria,
          dvContaBancaria: arrayPropriedade[0].dvContaBancaria,
          observacoes: arrayPropriedade[0].observacoes,
          aprovado: arrayPropriedade[0].aprovado,
          reprovado: arrayPropriedade[0].reprovado,
          dataCadastro: arrayPropriedade[0].dataCadastro,
          dataAtualizacao: arrayPropriedade[0].dataAtualizacao,
          messageProcessamento: arrayPropriedade[0].messageProcessamento,
          situacao: arrayPropriedade[0].situacao,
          situacaoPropriedade: arrayPropriedade[0].situacaoPropriedade,
          origem: arrayPropriedade[0].origem,
          diaPagamento: arrayPropriedade[0].diaPagamento,
          volumeInicial: arrayPropriedade[0].volumeInicial,
          capacidadeResfriador: arrayPropriedade[0].capacidadeResfriador,
          nrOrdenhas: arrayPropriedade[0].nrOrdenhas,
          tanqueExpansao: arrayPropriedade[0].tanqueExpansao,
          tanqueImersao: arrayPropriedade[0].tanqueImersao,
          latitude: arrayPropriedade[0].latitude,
          longitude: arrayPropriedade[0].longitude,
          novo: arrayPropriedade[0].novo,
          existente: arrayPropriedade[0].existente,
          pendente: arrayPropriedade[0].pendente,
        );
      } else {
        return null;
      }
    } catch (ex) {
      throw Exception("Erro Propriedade (loadPropriedade): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<void> insert(PrePropriedade prePropriedade) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = '''
          REPLACE INTO pre_propriedade (
              id, numeroDocumento, inscEstadual, rg, nirf, nrRegProdutor, nomeRazaoSocial, nomePropriedade, 
              endereco, numero, bairro, complemento, codigoMunIbge, cep, telefone, celular, email, banco, agencia, 
              dvAgencia, contaBancaria, dvContaBancaria, observacoes, aprovado, reprovado, dataCadastro, dataAtualizacao, 
              messageProcessamento, situacao, situacaoPropriedade, origem, diaPagamento, volumeInicial, 
              capacidadeResfriador, nrOrdenhas, tanqueExpansao, tanqueImersao, latitude, longitude, novo, existente, pendente, 
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''';

      await _db.rawInsert(sql, [
        prePropriedade.id,
        prePropriedade.numeroDocumento,
        prePropriedade.inscEstadual,
        prePropriedade.rg,
        prePropriedade.nirf,
        prePropriedade.nrRegProdutor,
        prePropriedade.nomeRazaoSocial,
        prePropriedade.nomePropriedade,
        prePropriedade.endereco,
        prePropriedade.numero,
        prePropriedade.bairro,
        prePropriedade.complemento,
        prePropriedade.cidade?.codigoMunIbge,
        prePropriedade.cep,
        prePropriedade.telefone,
        prePropriedade.celular,
        prePropriedade.email,
        prePropriedade.banco,
        prePropriedade.agencia,
        prePropriedade.dvAgencia,
        prePropriedade.contaBancaria,
        prePropriedade.dvContaBancaria,
        prePropriedade.observacoes,
        (prePropriedade.aprovado == true) ? 1 : 0,
        (prePropriedade.reprovado == true) ? 1 : 0,
        prePropriedade.dataCadastro,
        prePropriedade.dataAtualizacao,
        prePropriedade.messageProcessamento,
        prePropriedade.situacao,
        prePropriedade.situacaoPropriedade,
        prePropriedade.origem,
        prePropriedade.diaPagamento,
        prePropriedade.volumeInicial,
        prePropriedade.capacidadeResfriador,
        prePropriedade.nrOrdenhas,
        (prePropriedade.tanqueExpansao == true) ? 1 : 0,
        (prePropriedade.tanqueImersao == true) ? 1 : 0,
        prePropriedade.latitude.toString(),
        prePropriedade.longitude.toString(),
        (prePropriedade.novo == true) ? 1 : 0,
        (prePropriedade.existente == true) ? 1 : 0,
        (prePropriedade.pendente == true) ? 1 : 0,
      ]);
    } catch (ex) {
      throw Exception("Erro Propriedade (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<void> update(PrePropriedade prePropriedade) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = '''
          UPDATE pre_propriedade SET
              id = ?, numeroDocumento = ?, inscEstadual = ?, rg = ?, nirf = ?, nrRegProdutor = ?, nomeRazaoSocial = ?, nomePropriedade = ?, 
              endereco = ?, numero = ?, bairro = ?, complemento = ?, codigoMunIbge = ?, cep = ?, telefone = ?, celular = ?, email = ?, banco = ?, agencia = ?, 
              dvAgencia = ?, contaBancaria = ?, dvContaBancaria = ?, observacoes = ?, aprovado = ?, reprovado = ?, dataCadastro = ?, dataAtualizacao = ?, 
              messageProcessamento = ?, situacao = ?, situacaoPropriedade = ?, origem = ?, diaPagamento = ?, volumeInicial = ?, 
              capacidadeResfriador = ? nrOrdenhas = ?, tanqueExpansao = ?, tanqueImersao = ?, latitude = ?, longitude = ?, novo = ?, existente = ?, pendente = ?, 
          WHERE id = ?
          ''';

      await _db.rawInsert(sql, [
        prePropriedade.id,
        prePropriedade.numeroDocumento,
        prePropriedade.inscEstadual,
        prePropriedade.rg,
        prePropriedade.nirf,
        prePropriedade.nrRegProdutor,
        prePropriedade.nomeRazaoSocial,
        prePropriedade.nomePropriedade,
        prePropriedade.endereco,
        prePropriedade.numero,
        prePropriedade.bairro,
        prePropriedade.complemento,
        prePropriedade.cidade?.codigoMunIbge,
        prePropriedade.cep,
        prePropriedade.telefone,
        prePropriedade.celular,
        prePropriedade.email,
        prePropriedade.banco,
        prePropriedade.agencia,
        prePropriedade.dvAgencia,
        prePropriedade.contaBancaria,
        prePropriedade.dvContaBancaria,
        prePropriedade.observacoes,
        (prePropriedade.aprovado == true) ? 1 : 0,
        (prePropriedade.reprovado == true) ? 1 : 0,
        prePropriedade.dataCadastro,
        prePropriedade.dataAtualizacao,
        prePropriedade.messageProcessamento,
        prePropriedade.situacao,
        prePropriedade.situacaoPropriedade,
        prePropriedade.origem,
        prePropriedade.diaPagamento,
        prePropriedade.volumeInicial,
        prePropriedade.capacidadeResfriador,
        prePropriedade.nrOrdenhas,
        (prePropriedade.tanqueExpansao == true) ? 1 : 0,
        (prePropriedade.tanqueImersao == true) ? 1 : 0,
        prePropriedade.latitude.toString(),
        prePropriedade.longitude.toString(),
        (prePropriedade.novo == true) ? 1 : 0,
        (prePropriedade.existente == true) ? 1 : 0,
        (prePropriedade.pendente == true) ? 1 : 0,
        prePropriedade.id
      ]);
    } catch (ex) {
      throw Exception("Erro PrePropriedade (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<void> remove(String id) async {
    _db = (await Connection.get())!;
    var sql = 'DELETE FROM pre_propriedade WHERE id = ?';
    await _db.rawDelete(sql, [id]);
  }
}
