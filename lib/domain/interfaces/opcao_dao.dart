import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class OpcaoDAO {
  Future insert(Opcao opcao);

  Future update(Opcao opcao);

  Future remove(String id);

  Future<List<Opcao>> selectAll(Opcao opcao, TipoConsultaDB tipoConsultaDB);

  Future<List<Opcao>> selectSimple(Opcao opcao, TipoConsultaDB tipoConsultaDB);

  Future<Opcao?> carregarOpcao(int id);
}
