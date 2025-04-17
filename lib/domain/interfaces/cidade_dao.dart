import 'package:milkroute_tecnico/model/cidade.dart';
import 'package:milkroute_tecnico/model/estado.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class CidadeDAO {
  Future insertAll(List<Cidade> listCidade);

  Future insertOnly(Cidade cidade);

  Future update(Cidade cidade);

  Future remove(String codigoMunIbge);

  Future<List<Cidade>> selectAll(Cidade cidade, TipoConsultaDB tipoConsultaDB);

  Future<List<Cidade>> selectSimple(Cidade cidade, TipoConsultaDB tipoConsultaDB);

  Future<List<Cidade>> selectByEstado(Cidade cidade, Estado estado);

  Future<Cidade?> carregarCidade(int codigoMunIbge);
}
