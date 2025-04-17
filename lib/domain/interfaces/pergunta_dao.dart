import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class PerguntaDAO {
  Future insert(Pergunta pergunta);

  Future update(Pergunta pergunta);

  Future remove(String id);

  Future<List<Pergunta>> selectAll(Pergunta pergunta, TipoConsultaDB tipoConsultaDB);

  Future<List<Pergunta>> selectSimple(Pergunta pergunta, TipoConsultaDB tipoConsultaDB);

  Future<Pergunta?> carregarPergunta(int id);
}
