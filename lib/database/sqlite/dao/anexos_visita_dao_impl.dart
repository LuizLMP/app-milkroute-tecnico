import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/constants.dart';
import 'package:milkroute_tecnico/database/sqlite/connection.dart';
import 'package:milkroute_tecnico/domain/interfaces/anexos_visita_dao.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/anexos_visita.dart';
import 'package:sqflite/sqflite.dart';

class AnexosVisitaDAOImpl implements AnexosVisitaDAO {
  late Database _db;

  // ignore: missing_return
  @override
  Future<List<AnexosVisita>> selectAll(AnexosVisita anexosVisita, TipoConsultaDB tipoConsultaDB) async {
    try {
      List<Map<String, dynamic>> resultado = [];
      List<AnexosVisita> lista = [];

      _db = (await Connection.get())!;
      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          resultado = await _db.rawQuery("SELECT * FROM anexos_visita WHERE idAppTecnico = ?", [anexosVisita.idAppTecnicoVisita]);
          break;
        case TipoConsultaDB.PorVisita:
          resultado = await _db.rawQuery("SELECT * FROM anexos_visita WHERE idAppTecnicoVisita = ?", [anexosVisita.idAppTecnicoVisita]);
          break;
        case TipoConsultaDB.PorPendenciaSync:
          resultado = await _db.rawQuery("SELECT * FROM anexos_visita WHERE dataHoraIU != '0001-01-01 00:00:00'");
          break;
        case TipoConsultaDB.Tudo:
          resultado = await _db.query('anexos_visita');
          break;
        default:
          resultado = await _db.query('anexos_visita');
          break;
      }

      for (var linha in resultado) {
        lista.add(
          AnexosVisita(
            idAppTecnico: linha['idAppTecnico'],
            idAppTecnicoVisita: linha['idAppTecnicoVisita'],
            nomeArquivo: linha['nomeArquivo'],
            caminhoArquivo: linha['caminhoArquivo'],
            dataHoraIU: linha['dataHoraIU'] != null ? DateTime.parse(linha['dataHoraIU']) : DateTime.parse('0001-01-01 00:00:00'),
            tipoArquivo: linha['tipoArquivo'] == 'Assinatura' ? TipoArquivo.Assinatura : TipoArquivo.Anexo,
          ),
        );
      }

      return lista;
    } catch (ex) {
      print("Erro AnexosVisita (selectAll): " + ex.toString().substring(ex.toString().indexOf(':') + 1));
      throw Exception(ex);
    }
  }

  // ignore: missing_return
  @override
  Future<AnexosVisita?> carregarAnexo(String idAppTecnico) async {
    try {
      var array = await selectAll(AnexosVisita(idAppTecnicoVisita: idAppTecnico), TipoConsultaDB.PorPK);

      if (array.isNotEmpty) {
        return AnexosVisita(
          idAppTecnico: array[0].idAppTecnico,
          idAppTecnicoVisita: array[0].idAppTecnicoVisita,
          nomeArquivo: array[0].nomeArquivo,
          caminhoArquivo: array[0].caminhoArquivo,
          dataHoraIU: array[0].dataHoraIU,
          tipoArquivo: array[0].tipoArquivo,
        );
      } else {
        return null;
      }
    } catch (ex) {
      print("Erro AnexosVisita (carregarResposta): " + ex.toString().substring(ex.toString().indexOf(':') + 1));
      throw Exception(ex);
    }
  }

  @override
  Future insert(AnexosVisita anexosVisita) async {
    try {
      _db = (await Connection.get())!;
      var sql = ''' INSERT INTO anexos_visita (idAppTecnico, idAppTecnicoVisita, nomeArquivo, caminhoArquivo, dataHoraIU, tipoArquivo) 
                    VALUES (?, ?, ?, ?, ?, ?)''';
      await _db.rawInsert(sql, [
        anexosVisita.idAppTecnico,
        anexosVisita.idAppTecnicoVisita,
        anexosVisita.nomeArquivo,
        anexosVisita.caminhoArquivo,
        (anexosVisita.dataHoraIU == null) ? "0001-01-01 00:00:00" : DateFormat(dateFormatAPI).format(anexosVisita.dataHoraIU!),
        anexosVisita.tipoArquivo == TipoArquivo.Assinatura ? 'Assinatura' : 'Anexo',
      ]);
    } catch (ex) {
      print("Erro AnexosVisita (insert): " + ex.toString().substring(ex.toString().indexOf(':') + 1));
    }
  }

  @override
  Future remove(AnexosVisita anexosVisita, TipoConsultaDB tipoConsultaDB) async {
    try {
      _db = (await Connection.get())!;
      String whereTipoArquivo = anexosVisita.tipoArquivo == TipoArquivo.Assinatura ? 'Assinatura' : 'Anexo';

      switch (tipoConsultaDB) {
        case TipoConsultaDB.PorPK:
          await _db.rawDelete("DELETE FROM anexos_visita WHERE idAppTecnico = ? AND tipoArquivo = ?", [anexosVisita.idAppTecnico, whereTipoArquivo]);
          break;
        case TipoConsultaDB.PorVisita:
          await _db.rawDelete("DELETE FROM anexos_visita WHERE idAppTecnicoVisita = ? AND tipoArquivo = ?", [anexosVisita.idAppTecnicoVisita, whereTipoArquivo]);
          break;
        default:
          await _db.rawDelete("DELETE FROM anexos_visita WHERE idAppTecnico = ? AND tipoArquivo = ?", [anexosVisita.idAppTecnico, whereTipoArquivo]);
          break;
      }
    } catch (ex) {
      print("Erro AnexosVisita (remove): " + ex.toString().substring(ex.toString().indexOf(':') + 1));
    }
  }

  @override
  Future update(AnexosVisita anexosVisita) async {
    try {
      _db = (await Connection.get())!;
      var sql = ''' UPDATE anexos_visita 
                    SET idAppTecnico = ?, idAppTecnicoVisita = ?, nomeArquivo = ?, 
                    caminhoArquivo = ?, dataHoraIU = ?, tipoArquivo = ?
                    WHERE idAppTecnico = ?''';

      return _db.rawUpdate(sql, [
        anexosVisita.idAppTecnico,
        anexosVisita.idAppTecnicoVisita,
        anexosVisita.nomeArquivo,
        anexosVisita.caminhoArquivo,
        (anexosVisita.dataHoraIU == null) ? "0001-01-01 00:00:00" : DateFormat(dateFormatAPI).format(anexosVisita.dataHoraIU!),
        anexosVisita.tipoArquivo == TipoArquivo.Assinatura ? 'Assinatura' : 'Anexo',
        anexosVisita.idAppTecnico,
      ]);
    } catch (ex) {
      print("Erro AnexosVisita (update): ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
    }
  }
}
