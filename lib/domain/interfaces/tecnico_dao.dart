import 'package:milkroute_tecnico/model/tecnico.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class TecnicoDAO {
  Future insert(Tecnico tecnico);

  Future update(Tecnico tecnico);

  Future remove(String id);

  Future<List<Tecnico>> selectAll(Tecnico tecnico, TipoConsultaDB tipoConsultaDB);

  Future<List<Tecnico>> selectSimple(Tecnico tecnico, TipoConsultaDB tipoConsultaDB);

  Future<Tecnico?> carregarTecnico(int id);
}
