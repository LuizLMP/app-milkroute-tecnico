import 'package:milkroute_tecnico/model/sync.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class SyncDAO {
  Future replace(Sync sync);

  Future update(Sync sync);

  Future remove(String nomeTabela);

  Future<List<Sync>> selectAll(Sync sync, TipoConsultaDB tipoConsultaDB);

  Future<Sync?> carregarSync(String entidade);
}
