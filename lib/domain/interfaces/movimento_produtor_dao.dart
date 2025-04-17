import 'package:milkroute_tecnico/model/movimento_leite.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class MovimentoLeiteProdutorDAO {
  Future insert(MovimentoLeiteProdutor movimentoLeiteProdutor);

  Future update(MovimentoLeiteProdutor movimentoLeiteProdutor);

  Future remove(String id, TipoConsultaDB tipoConsultaDB);

  Future<List<MovimentoLeiteProdutor>> selectAll(MovimentoLeiteProdutor movimentoLeiteProdutor, TipoConsultaDB tipoConsultaDB);

  Future<List<MovimentoLeiteProdutor>> selectSimple(MovimentoLeiteProdutor movimentoLeiteProdutor, TipoConsultaDB tipoConsultaDB);

  Future<MovimentoLeiteProdutor?> carregarMovimentoLeiteProdutor(int id);
}
