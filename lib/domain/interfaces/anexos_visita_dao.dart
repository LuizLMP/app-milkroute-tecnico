import 'package:milkroute_tecnico/model/anexos_visita.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class AnexosVisitaDAO {
  Future insert(AnexosVisita anexosVisita);

  Future update(AnexosVisita anexosVisita);

  Future remove(AnexosVisita anexoVisita, TipoConsultaDB tipoConsultaDB);

  Future<List<AnexosVisita>> selectAll(AnexosVisita anexosVisita, TipoConsultaDB tipoConsultaDB);

  Future<AnexosVisita?> carregarAnexo(String idAppTecnico);
}
