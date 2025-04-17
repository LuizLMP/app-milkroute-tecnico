import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class RespostaDAO {
  Future insert(Resposta resposta);

  Future update(Resposta resposta);

  Future remove(String idAppTecnico, TipoConsultaDB tipoConsultaDB);

  Future<List<Resposta>> selectAll(Resposta resposta, TipoConsultaDB tipoConsultaDB);

  Future<List<Resposta>> selectSimple(Resposta resposta, TipoConsultaDB tipoConsultaDB);

  Future<Resposta?> carregarResposta(String idAppTecnico);
}
