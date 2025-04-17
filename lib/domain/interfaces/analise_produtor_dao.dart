import 'package:milkroute_tecnico/model/analise_leite.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class AnaliseLeiteProdutorDAO {
  Future insert(AnaliseLeiteProdutor analiseLeite);

  Future update(AnaliseLeiteProdutor analiseLeite);

  Future remove(String id, TipoConsultaDB tipoConsultaDB);

  Future<List<AnaliseLeiteProdutor>> selectAll(AnaliseLeiteProdutor analiseLeite, TipoConsultaDB tipoConsultaDB);

  Future<List<AnaliseLeiteProdutor>> selectSimple(AnaliseLeiteProdutor analiseLeite, TipoConsultaDB tipoConsultaDB);

  Future<AnaliseLeiteProdutor?> carregarAnaliseLeiteProdutor(int id);
}
