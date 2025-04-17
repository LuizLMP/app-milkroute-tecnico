import 'package:milkroute_tecnico/model/pessoa.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class PessoaDAO {
  Future insert(Pessoa pessoa);

  Future update(Pessoa pessoa);

  Future remove(int codigoProdutor);

  Future<List<Pessoa>> selectAll(Pessoa pessoa, TipoConsultaDB tipoConsultaDB);

  Future<List<Pessoa>> selectSimple(Pessoa pessoa, TipoConsultaDB tipoConsultaDB);

  Future<Pessoa?> carregarPessoa(int codigoProdutor);
}
