import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class RespostaItemDAO {
  Future insert(RespostaItem respostaItem);

  Future update(RespostaItem respostaItem);

  Future remove(String id, TipoConsultaDB tipoConsultaDB);

  Future<List<RespostaItem>> selectAll(RespostaItem respostaItem, TipoConsultaDB tipoConsultaDB);

  Future<List<RespostaItem>> selectSimple(RespostaItem respostaItem, TipoConsultaDB tipoConsultaDB);

  Future<RespostaItem?> carregarRespostaItem(String idAppTecnico);
}
