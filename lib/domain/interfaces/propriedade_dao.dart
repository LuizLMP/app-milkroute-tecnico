import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class PropriedadeDAO {
  Future insert(Propriedade propriedade);

  Future update(Propriedade propriedade);

  Future remove(int id);

  Future<List<Propriedade>> selectAll(Propriedade propriedade, TipoConsultaDB tipoConsultaDB);

  Future<List<Propriedade>> selectSimple(Propriedade propriedade, TipoConsultaDB tipoConsultaDB);

  Future<Propriedade?> carregarPropriedade(int id);
}
