import 'package:flutter/material.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/type/tipo_resposta.dart';

// ignore: must_be_immutable
class AnswerConstructor extends StatefulWidget {
  AnswerConstructor({super.key, required this.pergunta, required this.resposta, required this.listRespostaItem});
  Pergunta pergunta;
  Resposta resposta;
  List<RespostaItem> listRespostaItem;

  @override
  State<AnswerConstructor> createState() => _AnswerConstructorState();
}

class _AnswerConstructorState extends State<AnswerConstructor> {
  @override
  Widget build(BuildContext context) {
    final String flagPerguntaObrig = (widget.pergunta.obrigatorio!) ? " *" : "";
    final String labelPergunta = widget.pergunta.descricao!;
    final _fontStyleQuestion = TextStyle(fontSize: 18.0);
    final _fontStyleAnswer = TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold);
    final _aligmentAnswer = CrossAxisAlignment.start;
    final _paddingAnswer = EdgeInsets.fromLTRB(0, 8.0, 0, 8.0);
    RespostaItem respostaSalva;

    respostaSalva = widget.listRespostaItem[0];

    final Icon flagPossuiResposta = (respostaSalva.opcao?.descricao == "SEM RESPOSTA" && widget.pergunta.obrigatorio == true)
        ? Icon(Icons.pending, color: Colors.red)
        : (respostaSalva.opcao?.descricao == "SEM RESPOSTA")
            ? Icon(Icons.warning_rounded, color: Colors.yellow.shade700)
            : Icon(Icons.check_circle, color: Colors.green);

    if (widget.listRespostaItem.isNotEmpty) {
      switch (widget.pergunta.tipoPergunta) {
        case TipoPergunta.Combo:
          return ListTile(
            leading: flagPossuiResposta,
            title: Padding(
              padding: _paddingAnswer,
              child: Column(
                crossAxisAlignment: _aligmentAnswer,
                children: [
                  Text("$labelPergunta$flagPerguntaObrig: ", style: _fontStyleQuestion),
                  Text(respostaSalva.opcao!.descricao!, style: _fontStyleAnswer),
                ],
              ),
            ),
          );

        case TipoPergunta.Data:
          return ListTile(
            leading: flagPossuiResposta,
            title: Padding(
              padding: _paddingAnswer,
              child: Column(
                crossAxisAlignment: _aligmentAnswer,
                children: [
                  Text(
                    labelPergunta + flagPerguntaObrig + ": ",
                    style: _fontStyleQuestion,
                  ),
                  Text(
                    (respostaSalva.descricao == "SEM RESPOSTA") ? "SEM RESPOSTA" : (respostaSalva.descricao ?? ""),
                    style: _fontStyleAnswer,
                  )
                ],
              ),
            ),
          );

        case TipoPergunta.EscolhaUma:
          return ListTile(
            leading: flagPossuiResposta,
            title: Padding(
              padding: _paddingAnswer,
              child: Column(
                crossAxisAlignment: _aligmentAnswer,
                children: [
                  Text(labelPergunta + flagPerguntaObrig + ": ", style: _fontStyleQuestion),
                  Text(
                    respostaSalva.opcao!.descricao!,
                    style: _fontStyleAnswer,
                  )
                ],
              ),
            ),
          );
        case TipoPergunta.MultiplaEscolha:
          return ListTile(
            leading: flagPossuiResposta,
            title: Padding(
              padding: _paddingAnswer,
              child: Column(
                crossAxisAlignment: _aligmentAnswer,
                children: [
                  Text(labelPergunta + flagPerguntaObrig + ": ", style: _fontStyleQuestion),
                  for (RespostaItem itensCheck in widget.listRespostaItem)
                    if (itensCheck.visualizaResposta == true)
                      Text(
                        "${itensCheck.opcao!.descricao}, ",
                        style: _fontStyleAnswer,
                      )
                ],
              ),
            ),
          );

        case TipoPergunta.Texto:
          return ListTile(
            leading: flagPossuiResposta,
            title: Padding(
              padding: _paddingAnswer,
              child: Column(
                crossAxisAlignment: _aligmentAnswer,
                children: [
                  Text(labelPergunta + flagPerguntaObrig + ": ", style: _fontStyleQuestion),
                  Text(
                    respostaSalva.descricao!,
                    style: _fontStyleAnswer,
                  )
                ],
              ),
            ),
          );

        default:
          return Row(
            children: [
              Text(
                "Problemas com o carregamento da pergunta. Procure o estabelecimento responsável para solução do problema!",
                style: TextStyle(color: Colors.red),
              ),
            ],
          );
      }
    } else {
      return Card(
          child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(
          'Não há nenhuma pergunta respondida.',
          style: TextStyle(fontSize: 16),
        ),
      ));
    }
  }
}
