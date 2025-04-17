import 'package:milkroute_tecnico/model/pais.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class PaisDAO {
  Future insert(Pais pais);

  Future update(Pais pais);

  Future remove(String nome);

  Future<List<Pais>> selectAll(Pais pais, TipoConsultaDB tipoConsultaDB);

  Future<List<Pais>> selectSimple(Pais pais, TipoConsultaDB tipoConsultaDB);

  Future<Pais?> carregarPais(String nome);
}
