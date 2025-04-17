import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/visita.dart';

abstract class VisitaDAO {
  Future insert(Visita visita);

  Future batchInsert(Visita visita);

  Future update(Visita visita);

  Future remove(String id);

  Future<List<Visita>> selectAll(Visita visita, TipoConsultaDB tipoConsultaDB);

  Future<List<Visita>> selectSimple(Visita visita, TipoConsultaDB tipoConsultaDB);

  Future<Visita> carregarVisita(String idAppTecnico);
}
