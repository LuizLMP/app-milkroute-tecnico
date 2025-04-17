import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class EstabelecimentoDAO {
  Future insert(Estabelecimento estabelecimento);

  Future update(Estabelecimento estabelecimento);

  Future remove(String id);

  Future<List<Estabelecimento>> selectAll(Estabelecimento estabelecimento, TipoConsultaDB tipoConsultaDB);

  Future<List<Estabelecimento>> selectSimple(Estabelecimento estabelecimento, TipoConsultaDB tipoConsultaDB);

  Future<Estabelecimento?> carregarEstabelecimento(String codEstabel);
}
