import 'package:milkroute_tecnico/model/banco.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class BancoDAO {
  Future insert(Banco banco);

  Future insertAll(List<Banco> listBanco);

  Future update(Banco banco);

  Future remove(String codFebraban);

  Future<List<Banco>> selectAll(Banco banco, TipoConsultaDB tipoConsultaDB);

  Future<List<Banco>> selectSimple(Banco banco, TipoConsultaDB tipoConsultaDB);

  Future<Banco?> carregarBanco(String codFebraban);
}
