import 'package:milkroute_tecnico/model/categoriapergunta.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class CategoriaPerguntaDAO {
  Future insert(CategoriaPergunta categoriaPergunta);

  Future update(CategoriaPergunta categoriaPergunta);

  Future remove(String id);

  Future<List<CategoriaPergunta>> selectAll(CategoriaPergunta categoriaPergunta, TipoConsultaDB tipoConsultaDB);

  Future<List<CategoriaPergunta>> selectSimple(CategoriaPergunta categoriaPergunta, TipoConsultaDB tipoConsultaDB);

  Future<CategoriaPergunta?> carregarCategoriaPergunta(int id);
}
