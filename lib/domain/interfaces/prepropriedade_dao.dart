import 'package:milkroute_tecnico/model/prepropriedade.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class PrePropriedadeDAO {
  Future<void> insert(PrePropriedade prePropriedade);
  Future<void> update(PrePropriedade prePropriedade);
  Future<void> remove(String id);
  Future<List<PrePropriedade>> selectAll(PrePropriedade prePropriedade, TipoConsultaDB tipoConsultaDB);
  Future<List<PrePropriedade>> selectSimple(PrePropriedade prePropriedade, TipoConsultaDB tipoConsultaDB);
  Future<PrePropriedade?> carregarPrePropriedade(int id);
}
