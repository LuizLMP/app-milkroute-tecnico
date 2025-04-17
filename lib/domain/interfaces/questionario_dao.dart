import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';

abstract class QuestionarioDAO {
  Future insert(Questionario questionario);

  Future update(Questionario questionario);

  Future remove(String id);

  Future<List<Questionario>> selectAll(Questionario questionario, TipoConsultaDB tipoConsultaDB);

  Future<List<Questionario>> selectSimple(Questionario questionario, TipoConsultaDB tipoConsultaDB);

  Future<Questionario?> carregarQuestionario(int id);

  Future<Questionario?> carregarQuestionarioSimple(int id);
}
