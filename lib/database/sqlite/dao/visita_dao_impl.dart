import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/estabelecimento_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/propriedade_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/questionario_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/resposta_dao_impl.dart';
import 'package:milkroute_tecnico/domain/interfaces/visita_dao.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:sqflite/sqflite.dart';

class VisitaDAOImpl implements VisitaDAO {
  late Database _db;

  @override
  Future<List<Visita>> selectAll(Visita visita, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Visita> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM visita WHERE idAppTecnico = ?", [visita.idAppTecnico]);
          break;
        case TipoConsultaDB.PorQuestionario:
          resultado = await _db.rawQuery("SELECT * FROM visita WHERE idQuestionario = ?", [visita.questionario?.id]);
          break;
        case TipoConsultaDB.PorPendenciaSync:
          resultado = await _db.rawQuery("SELECT * FROM visita WHERE dataHoraIU != '0001-01-01 00:00:00'");
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('visita');
          break;

        default:
          resultado = await _db.query('visita');
          break;
      }

      for (var linha in resultado) {
        lista.add(Visita(
          idAppTecnico: linha['idAppTecnico'],
          idWeb: linha['idWeb'],
          nrVisita: linha['nrVisita'],
          dataInicio: linha['dataInicio'] != null ? DateTime.parse(linha['dataInicio']) : DateTime.parse('0001-01-01 00:00:00'),
          estabelecimento: await EstabelecimentoDAOImpl().carregarEstabelecimento(linha["idEstabelecimento"].toString()),
          propriedade: await PropriedadeDAOImpl().carregarPropriedade(linha['idPropriedade']),
          questionario: await QuestionarioDAOImpl().carregarQuestionario(linha['idQuestionario']),
          observacoes: linha['observacoes'],
          recomendacoes: linha['recomendacoes'],
          latitude: linha['latitude'],
          longitude: linha['longitude'],
          dataFinalizacao: linha['dataFinalizacao'] != null ? DateTime.parse(linha['dataFinalizacao']) : DateTime.parse('0001-01-01 00:00:00'),
          statusVisita: linha['statusVisita'],
          dataCriacao: linha['dataCriacao'] != null ? DateTime.parse(linha['dataCriacao']) : DateTime.parse('0001-01-01 00:00:00'),
          existente: linha['existente'] == 1 ? true : false,
          novo: linha['novo'] == 1 ? true : false,
          solicitado: linha['solicitado'] == 1 ? true : false,
          agendado: linha['agendado'] == 1 ? true : false,
          finalizado: linha['finalizado'] == 1 ? true : false,
          dataHoraIU: linha['dataHoraIU'] != null ? DateTime.parse(linha['dataHoraIU']) : DateTime.parse('0001-01-01 00:00:00'),
          listRespostas: await RespostaDAOImpl().selectAll(
            Resposta(visita: Visita(idAppTecnico: linha['idAppTecnico']), questionario: Questionario(id: linha['idQuestionario'])),
            TipoConsultaDB.PorVisita,
          ),
        ));
      }

      lista.sort(
        (a, b) {
          return a.dataInicio!.compareTo(b.dataInicio!);
        },
      );

      return lista;
    } catch (ex) {
      throw Exception("Erro Visita (selectAll): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<Visita> carregarVisita(String idAppTecnico) async {
    try {
      var array = await VisitaDAOImpl().selectAll(Visita(idAppTecnico: idAppTecnico), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return Visita(
            idAppTecnico: array[0].idAppTecnico,
            idWeb: array[0].idWeb,
            nrVisita: array[0].nrVisita,
            dataInicio: array[0].dataInicio,
            estabelecimento: array[0].estabelecimento,
            propriedade: array[0].propriedade,
            questionario: array[0].questionario,
            observacoes: array[0].observacoes,
            recomendacoes: array[0].recomendacoes,
            latitude: array[0].latitude,
            longitude: array[0].longitude,
            dataFinalizacao: array[0].dataFinalizacao,
            listRespostas: array[0].listRespostas,
            statusVisita: array[0].statusVisita,
            dataCriacao: array[0].dataCriacao,
            existente: array[0].existente,
            novo: array[0].novo,
            solicitado: array[0].solicitado,
            agendado: array[0].agendado,
            finalizado: array[0].finalizado,
            dataHoraIU: array[0].dataHoraIU);
      } else {
        return Visita();
      }
    } catch (ex) {
      throw Exception("Erro Visita (loadVisita): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future remove(String idAppTecnico) async {
    try {
      _db = (await Connection.get())!;
      await RespostaDAOImpl().remove(idAppTecnico, TipoConsultaDB.PorVisita);

      var sql = 'DELETE FROM visita WHERE idAppTecnico = ?';
      await _db.rawDelete(sql, [idAppTecnico]);
    } catch (ex) {
      throw Exception("Erro Visita (remove): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future insert(Visita visita) async {
    try {
      await PropriedadeDAOImpl().insert(visita.propriedade!);

      var listQuestionarios = await QuestionarioDAOImpl().selectAll(Questionario(), TipoConsultaDB.Tudo);

      if (listQuestionarios.any((elem) => elem.id == visita.questionario?.id) == false) {
        if (visita.questionario != null) {
          await QuestionarioDAOImpl().insert(visita.questionario!);
        }
      }

      _db = (await Connection.get())!;
      String sql;

      sql = '''
              REPLACE INTO visita (
                idAppTecnico, idWeb, nrVisita, dataInicio, idEstabelecimento, idPropriedade, idQuestionario, observacoes, 
                recomendacoes, latitude, longitude, dataFinalizacao, statusVisita, dataCriacao, existente, novo, 
                solicitado, agendado, finalizado, dataHoraIU
              ) VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
              )
          ''';

      await _db.rawInsert(sql, [
        visita.idAppTecnico,
        visita.idWeb,
        visita.nrVisita,
        (visita.dataInicio == null) ? null : DateFormat(dateFormatAPI).format(visita.dataInicio!),
        visita.estabelecimento?.codEstabel,
        visita.propriedade?.id,
        visita.questionario?.id,
        visita.observacoes,
        visita.recomendacoes,
        visita.latitude,
        visita.longitude,
        (visita.dataFinalizacao == null) ? null : DateFormat(dateFormatAPI).format(visita.dataFinalizacao!),
        visita.statusVisita,
        (visita.dataCriacao == null) ? null : DateFormat(dateFormatAPI).format(visita.dataCriacao!),
        visita.existente,
        visita.novo,
        visita.solicitado,
        visita.agendado,
        visita.finalizado,
        (visita.dataHoraIU == null) ? null : DateFormat(dateFormatAPI).format(visita.dataHoraIU!)
      ]);

      if (visita.listRespostas != null) {
        for (var elem in visita.listRespostas!) {
          if (elem.visita == null) {
            elem.visita = Visita(idAppTecnico: visita.idAppTecnico);
          } else {
            elem.visita?.idAppTecnico = visita.idAppTecnico;
          }

          await RespostaDAOImpl().insert(elem);
        }
      }

      return visita;
    } catch (ex) {
      throw Exception("Erro Visita (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future batchInsert(Visita visita) async {
    // Para melhora da performance, no batchInsert é necessário que os questionários sejam inseridos no SQLite antes visita!
    try {
      await PropriedadeDAOImpl().insert(visita.propriedade!);

      _db = (await Connection.get())!;
      var sql;

      sql = '''
              REPLACE INTO visita (
                idAppTecnico, idWeb, nrVisita, dataInicio, idEstabelecimento, idPropriedade, idQuestionario, observacoes, 
                recomendacoes, latitude, longitude, dataFinalizacao, statusVisita, dataCriacao, existente, novo, 
                solicitado, agendado, finalizado, dataHoraIU
              ) VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
              )
          ''';

      await _db.rawInsert(sql, [
        visita.idAppTecnico,
        visita.idWeb,
        visita.nrVisita,
        (visita.dataInicio == null) ? null : DateFormat(dateFormatAPI).format(visita.dataInicio!),
        visita.estabelecimento?.codEstabel,
        visita.propriedade?.id,
        visita.questionario?.id,
        visita.observacoes,
        visita.recomendacoes,
        visita.latitude,
        visita.longitude,
        (visita.dataFinalizacao == null) ? null : DateFormat(dateFormatAPI).format(visita.dataFinalizacao!),
        visita.statusVisita,
        (visita.dataCriacao == null) ? null : DateFormat(dateFormatAPI).format(visita.dataCriacao!),
        visita.existente,
        visita.novo,
        visita.solicitado,
        visita.agendado,
        visita.finalizado,
        (visita.dataHoraIU == null) ? null : DateFormat(dateFormatAPI).format(visita.dataHoraIU!)
      ]);

      if (visita.listRespostas != null) {
        for (var elem in visita.listRespostas!) {
          if (elem.visita == null) {
            elem.visita = Visita(idAppTecnico: visita.idAppTecnico);
          } else {
            elem.visita?.idAppTecnico = visita.idAppTecnico;
          }

          await RespostaDAOImpl().insert(elem);
        }
      }

      return visita;
    } catch (ex) {
      throw Exception("Erro Visita (insert): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future update(Visita visita) async {
    try {
      _db = (await Connection.get())!;
      var sql;
      sql = '''
              UPDATE visita SET
                idWeb = ?, nrVisita = ?, dataInicio = ?, idEstabelecimento = ?, idPropriedade = ?, idQuestionario = ?,observacoes = ?,
                recomendacoes = ?, latitude = ?, longitude = ?, dataFinalizacao = ?, statusVisita = ?,
                dataCriacao = ?, existente = ?, novo = ?, solicitado = ?, agendado = ?, finalizado = ?,
                dataHoraIU = ?
              WHERE idAppTecnico = ?
          ''';
      // sql = '''
      //         UPDATE visita SET
      //           idWeb = ?, nrVisita = ?, dataInicio = ?, idPropriedade = ?, idQuestionario = ?,observacoes = ?,
      //           recomendacoes = ?, latitude = ?, longitude = ?, dataFinalizacao = ?, statusVisita = ?,
      //           dataCriacao = ?, existente = ?, novo = ?, solicitado = ?, agendado = ?, finalizado = ?,
      //           dataHoraIU = ?
      //         WHERE idAppTecnico = ?
      //     ''';
      await _db.rawUpdate(sql, [
        visita.idWeb,
        visita.nrVisita,
        DateFormat(dateFormatAPI).format(visita.dataInicio!),
        visita.estabelecimento?.codEstabel,
        visita.propriedade?.id,
        visita.questionario?.id,
        visita.observacoes,
        visita.recomendacoes,
        visita.latitude,
        visita.longitude,
        DateFormat(dateFormatAPI).format(visita.dataFinalizacao!),
        visita.statusVisita,
        DateFormat(dateFormatAPI).format(visita.dataCriacao!),
        (visita.existente == true) ? 1 : 0,
        (visita.novo == true) ? 1 : 0,
        (visita.solicitado == true) ? 1 : 0,
        (visita.agendado == true) ? 1 : 0,
        (visita.finalizado == true) ? 1 : 0,
        DateFormat(dateFormatAPI).format(visita.dataHoraIU!),
        visita.idAppTecnico
      ]);

      for (var elem in visita.listRespostas!) {
        elem.visita?.idAppTecnico = visita.idAppTecnico;
        await RespostaDAOImpl().update(elem);
      }
    } catch (ex) {
      throw Exception("Erro Visita (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }

  @override
  Future<List<Visita>> selectSimple(Visita visita, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      List<Map<String, dynamic>> resultado = [];
      List<Visita> lista = [];

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM visita WHERE idAppTecnico = ?", [visita.idAppTecnico]);
          break;
        case TipoConsultaDB.PorQuestionario:
          resultado = await _db.rawQuery("SELECT * FROM visita WHERE idQuestionario = ?", [visita.questionario?.id]);
          break;
        case TipoConsultaDB.PorPendenciaSync:
          resultado = await _db.rawQuery("SELECT * FROM visita WHERE dataHoraIU <> '0001-01-01 00:00:00'");
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('visita');
          break;

        default:
          resultado = await _db.query('visita');
          break;
      }

      for (var linha in resultado) {
        lista.add(Visita(
          idAppTecnico: linha['idAppTecnico'],
          idWeb: linha['idWeb'],
          nrVisita: linha['nrVisita'],
          dataInicio: linha['dataInicio'] != null ? DateTime.parse(linha['dataInicio']) : DateTime.parse('0001-01-01 00:00:00'),
          estabelecimento: await EstabelecimentoDAOImpl().carregarEstabelecimento(linha['idEstabelecimento'].toString()),
          propriedade: await PropriedadeDAOImpl().carregarPropriedade(linha['idPropriedade']),
          questionario: await QuestionarioDAOImpl().carregarQuestionarioSimple(linha['idQuestionario']),
          observacoes: linha['observacoes'],
          recomendacoes: linha['recomendacoes'],
          latitude: linha['latitude'],
          longitude: linha['longitude'],
          dataFinalizacao: linha['dataFinalizacao'] != null ? DateTime.parse(linha['dataFinalizacao']) : DateTime.parse('0001-01-01 00:00:00'),
          statusVisita: linha['statusVisita'],
          dataCriacao: linha['dataCriacao'] != null ? DateTime.parse(linha['dataCriacao']) : DateTime.parse('0001-01-01 00:00:00'),
          existente: linha['existente'] == 1 ? true : false,
          novo: linha['novo'] == 1 ? true : false,
          solicitado: linha['solicitado'] == 1 ? true : false,
          agendado: linha['agendado'] == 1 ? true : false,
          finalizado: linha['finalizado'] == 1 ? true : false,
          dataHoraIU: linha['dataHoraIU'] != null ? DateTime.parse(linha['dataHoraIU']) : DateTime.parse('0001-01-01 00:00:00'),
          listRespostas: [],
        ));
      }

      return lista;
    } catch (ex) {
      throw Exception("Erro Visita (selectSimple): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
