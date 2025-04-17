import 'package:milkroute_tecnico/model/estado.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class EstadoDAO {
  Future insertAll(List<Estado> listEstado);

  Future insertOnly(Estado estado);

  Future update(Estado estado);

  Future remove(String sigla);

  Future<List<Estado>> selectAll(Estado estado, TipoConsultaDB tipoConsultaDB);

  Future<List<Estado>> selectSimple(Estado estado, TipoConsultaDB tipoConsultaDB);

  Future<Estado?> carregarEstado(String sigla);
}
