import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/anexos_visita_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/respostaitem_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/visita_dao_impl.dart';
import 'package:milkroute_tecnico/model/anexos_visita.dart';
import 'package:milkroute_tecnico/model/categoriapergunta.dart';
import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/type/tipo_resposta.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFService {
  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Erro ao abrir o arquivo! Motivo: $e');
    }

    return completer.future;
  }

  Future<PDFScreen> getRelatorioVisitaPDF(
      Visita visita, String nomeArquivo) async {
    final String tituloRelatorio =
        "${visita.propriedade?.codProdutor} - ${visita.propriedade?.pessoa?.nomeRazaoSocial}";
    final String dataVisita =
        DateFormat("dd/MM/yyyy").format(visita.dataFinalizacao!);

    visita = await VisitaDAOImpl().carregarVisita(visita.idAppTecnico!);

    final pathPDF = await _pdfRelatorioVisita(
        visita, nomeArquivo, tituloRelatorio, dataVisita);

    return PDFScreen(path: pathPDF, nameFilePDF: nomeArquivo);
  }

  Future<String> _pdfRelatorioVisita(Visita visita, String nomeArquivo,
      String tituloRelatorio, String dataVisita) async {
    if (visita.questionario!.listCategorias!.isNotEmpty) {
      final data = await _construirArquivoRelatorioVisitaPDF(
          visita, tituloRelatorio, dataVisita);
      return await _gravarArquivoNoDispositivo(nomeArquivo, data);
    } else {
      return throw Exception(
          'Não há dados para serem impressos em arquivo PDF');
    }
  }

  Future<String> _gravarArquivoNoDispositivo(
      String nomeArquivo, Uint8List byteList) async {
    nomeArquivo = (nomeArquivo) ?? "relVisita";

    Directory tempDir = await getTemporaryDirectory();
    String pathFile = "${tempDir.path}/$nomeArquivo.pdf";

    final filePDF = File(pathFile);
    // REABILITAR GRAVADOR QUE CONSTROI PDF
    // filePDF.writeAsBytesSync(fileDecode);
    await filePDF.writeAsBytes(byteList);

    return pathFile;
  }

  Future<Uint8List> _construirArquivoRelatorioVisitaPDF(
      Visita visita, String tituloRelatorio, String dataVisita) async {
    try {
      final pdf = pw.Document();
      const LIMITREGPAGE = 5;
      final List<PerguntaRespostaScreen> listPerguntaRespostaScreen = [];
      String? nomeCategoria = "";

      for (CategoriaPergunta categoriaPergunta
          in visita.questionario!.listCategorias!) {
        for (Pergunta pergunta in categoriaPergunta.listPerguntas!) {
          List<RespostaItem> listRespostaItem = [];

          listRespostaItem = await RespostaItemDAOImpl().selectAll(
              RespostaItem(
                  pergunta: pergunta, resposta: visita.listRespostas?[0]),
              TipoConsultaDB.PorPergunta);

          if (listRespostaItem.isEmpty) {
            listRespostaItem.add(RespostaItem(
                pergunta: pergunta,
                resposta: visita.listRespostas?[0],
                descricao: "SEM RESPOSTA",
                opcao: Opcao(
                  descricao: "SEM RESPOSTA",
                )));
          }

          listPerguntaRespostaScreen.add(
            PerguntaRespostaScreen(
              categoriaPergunta: categoriaPergunta,
              pergunta: pergunta,
              listRespostaItem: listRespostaItem,
            ),
          );
        }
      }

      List<List<PerguntaRespostaScreen>> listPages = [];
      int qtdePages = (listPerguntaRespostaScreen.length ~/ LIMITREGPAGE) + 1;
      int restoDiv = listPerguntaRespostaScreen.length % LIMITREGPAGE;

      for (var i = 0; i < qtdePages; i++) {
        int inicio = i * LIMITREGPAGE;
        int fim = (i == (qtdePages - 1))
            ? (inicio + restoDiv)
            : (inicio + LIMITREGPAGE);

        listPages.add(listPerguntaRespostaScreen.sublist(inicio, fim));
      }

      String? caminhoAssinatura = await _getCaminhoAssinatura(
          visita.listRespostas![0].visita!.idAppTecnico!);

      if (visita.listRespostas!.isNotEmpty) {
        final logo = (await rootBundle
                .load("assets/images/avatar_milkroute_tecnico.png"))
            .buffer
            .asUint8List();

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) => [
              pw.Partitions(
                children: [
                  pw.Partition(
                    child: pw.Column(
                      children: [
                        pw.Image(
                          pw.MemoryImage(logo),
                          width: 100,
                          height: 100,
                          fit: pw.BoxFit.cover,
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.only(top: 20.0),
                          child: pw.Text("Relatório de Visita Técnica",
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 35,
                              )),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.only(top: 5.0),
                          child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Column(children: [
                                  pw.Text(tituloRelatorio,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 20)),
                                  pw.Text(dataVisita,
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 20)),
                                ])
                              ]),
                        ),
                        for (List<PerguntaRespostaScreen> listPageRespostas
                            in listPages)
                          pw.Container(
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.start,
                              children: [
                                for (PerguntaRespostaScreen linha
                                    in listPageRespostas)
                                  pw.Builder(
                                    builder: (context) {
                                      bool mostraNomeCategoria = false;

                                      if (nomeCategoria !=
                                          linha.categoriaPergunta?.descricao) {
                                        nomeCategoria =
                                            linha.categoriaPergunta?.descricao;
                                        mostraNomeCategoria = true;
                                      }

                                      return pw.Container(
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            if (mostraNomeCategoria)
                                              pw.Container(
                                                padding: pw.EdgeInsets.only(
                                                    left: 10, top: 25),
                                                child: pw.Text(
                                                  nomeCategoria!,
                                                  style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            pw.Container(
                                              padding:
                                                  pw.EdgeInsets.only(left: 25),
                                              child: pw.Container(
                                                alignment: pw.Alignment.topLeft,
                                                padding: pw.EdgeInsets.all(10),
                                                margin:
                                                    pw.EdgeInsets.only(top: 10),
                                                decoration: pw.BoxDecoration(
                                                    border: pw.Border.all(),
                                                    borderRadius: const pw
                                                        .BorderRadius.all(
                                                      pw.Radius.circular(5),
                                                    )),
                                                child: _printPerguntaResposta(
                                                  context: context,
                                                  linha: linha,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                              ],
                            ),
                          ),
                        pw.Container(
                          padding: pw.EdgeInsets.only(top: 50),
                          child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                "Assinatura do Produtor",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 20),
                              ),
                              pw.Padding(
                                  padding: pw.EdgeInsets.only(top: 30),
                                  child: (caminhoAssinatura != null)
                                      ? pw.Image(
                                          pw.MemoryImage(
                                            File((caminhoAssinatura))
                                                .readAsBytesSync(),
                                          ),
                                        )
                                      : pw.Text('Sem assinatura')),
                              pw.Text(
                                  "__________________________________________________________"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
        return pdf.save();
      } else {
        throw Exception('Não há respostas a serem exibidas para esta visita!');
      }
    } catch (e) {
      throw Exception('Erro ao construir o relatório em PDF! Motivo: $e');
    }
  }

  pw.Widget _printPerguntaResposta(
      {pw.Context? context, PerguntaRespostaScreen? linha}) {
    RespostaItem respostaItem;
    String? printResposta = "";

    respostaItem = linha!.listRespostaItem![0];

    switch (linha.pergunta?.tipoPergunta) {
      case TipoPergunta.MultiplaEscolha:
        for (RespostaItem respostaItem in linha.listRespostaItem!) {
          if (respostaItem.visualizaResposta == true) {
            printResposta =
                "${printResposta ?? ""}${respostaItem.opcao?.descricao}, ";
          }
        }
        break;

      case TipoPergunta.Combo:
        printResposta = respostaItem.opcao!.descricao;
        break;
      case TipoPergunta.Data:
        printResposta = respostaItem.descricao;
        break;
      case TipoPergunta.EscolhaUma:
        printResposta = respostaItem.opcao?.descricao;
        break;
      case TipoPergunta.Texto:
        printResposta = respostaItem.descricao;
        break;
      default:
        printResposta = "";
        break;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 450,
          child: pw.Text(
            "${linha.pergunta?.descricao}: ",
            style: pw.TextStyle(fontSize: 15.0, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(
          width: 450,
          child: pw.Text(
            printResposta!,
            style: pw.TextStyle(fontSize: 15.0),
            overflow: pw.TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  Future<String?> _getCaminhoAssinatura(String idAppTecnico) async {
    try {
      List<AnexosVisita> listAnexoVisita = [];
      listAnexoVisita = await AnexosVisitaDAOImpl().selectAll(
          AnexosVisita(idAppTecnicoVisita: idAppTecnico),
          TipoConsultaDB.PorVisita);

      AnexosVisita anexoVisita = listAnexoVisita.firstWhere(
        (element) => element.caminhoArquivo!.contains("assinatura"),
        orElse: () => AnexosVisita(caminhoArquivo: ""),
      );

      return anexoVisita.caminhoArquivo;
    } catch (ex) {
      print("Erro na busca da imagem da assinatura. Motivo: $ex");
      return null;
    }
  }
}

class PDFScreen extends StatefulWidget {
  PDFScreen({Key? key, this.path, this.nameFilePDF, this.nomeDocumento})
      : super(key: key);
  final String? path;
  final String? nameFilePDF;
  final String? nomeDocumento;

  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: IconButton(
            onPressed: () => Navigator.pop(context, true),
            icon: Icon(Icons.arrow_back_rounded),
          ),
          title: Text(widget.nameFilePDF!),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: (() async {
                Share.shareXFiles(
                  [XFile(widget.path!)],
                  text: widget.nameFilePDF,
                  subject: widget.nomeDocumento,
                );
              }),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 16),
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height - kToolbarHeight - 200,
                  child: PDFView(
                    filePath: widget.path,
                    enableSwipe: true,
                    swipeHorizontal: false, // Permitir rolagem vertical
                    autoSpacing: true,
                    pageFling: true,
                    pageSnap: true,
                    defaultPage: currentPage,
                    fitPolicy: FitPolicy.BOTH,
                    preventLinkNavigation: false,
                    onRender: (_pages) {
                      setState(() {
                        pages = _pages!;
                        isReady = true;
                      });
                    },
                    onError: (error) {
                      setState(() {
                        errorMessage = error.toString();
                      });
                      print(error.toString());
                    },
                    onPageError: (page, error) {
                      setState(() {
                        errorMessage = '$page: ${error.toString()}';
                      });
                      print('$page: ${error.toString()}');
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      _controller.complete(pdfViewController);
                    },
                    onLinkHandler: (String? uri) {
                      if (uri != null) {
                        print('Ir para URL: $uri');
                      }
                    },
                    onPageChanged: (page, total) {
                      print('Mudar página: $page/${total ?? 'unknown'}');
                      setState(() {
                        currentPage = page!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PerguntaRespostaScreen {
  PerguntaRespostaScreen(
      {this.categoriaPergunta, this.pergunta, this.listRespostaItem});
  CategoriaPergunta? categoriaPergunta;
  Pergunta? pergunta;
  List<RespostaItem>? listRespostaItem;
}
