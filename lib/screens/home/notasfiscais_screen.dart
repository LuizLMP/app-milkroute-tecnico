import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/globals_var.dart';
import 'package:milkroute_tecnico/model/estabelecimento.dart';
import 'package:milkroute_tecnico/model/notafiscal.dart';
import 'package:milkroute_tecnico/model/propriedade.dart';
import 'package:milkroute_tecnico/model/user.dart';
import 'package:milkroute_tecnico/screens/app/app_drawer.dart';
import 'package:milkroute_tecnico/services/estabelecimento_service.dart';
import 'package:milkroute_tecnico/services/notafiscal_service.dart';
import 'package:milkroute_tecnico/services/pdf_services.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;

class NotasFiscaisScreen extends StatefulWidget {
  const NotasFiscaisScreen({Key? key, this.user, this.propriedade}) : super(key: key);

  final User? user;
  final Propriedade? propriedade;

  @override
  State<NotasFiscaisScreen> createState() => _NotasFiscaisScreenState();
}

class _NotasFiscaisScreenState extends State<NotasFiscaisScreen> {
  final bool animate = true;
  final String nomeArquivoIR = "Extrato de Movimentações";
  String pathPDF = "";
  final NotaFiscalService _apiNotaFiscal = NotaFiscalService();
  final EstabelecimentoService _apiEstabel = EstabelecimentoService();

  Future<List<NotaFiscal>> _carregaNFs(
    Propriedade propriedade,
    User user,
  ) async {
    var listNotasFiscais = await _apiNotaFiscal.getListaNotasFiscais(propriedade.pessoa!.numeroDocumento!, user.token!, user.empresa!);

    listNotasFiscais = listNotasFiscais.where((element) => (element.dataEmissao?.year == GlobalData.periodo.year && element.statusNfe == "AUTORIZADO")).toList();

    listNotasFiscais.sort((a, b) {
      return b.dataEmissao!.compareTo(a.dataEmissao!);
    });

    return listNotasFiscais.toList();
  }

  Future<String> _carregaDANFE(User user, String chave, String nomeArquivo) async {
    var notaFiscal = await _apiNotaFiscal.getDANFE(chave, user.token!, user.empresa!);

    Directory tempDir = await getTemporaryDirectory();
    String pathDanfe = "${tempDir.path}/$nomeArquivo.pdf";

    final fileDecode = base64Decode(notaFiscal.danfePdf ?? "");
    var filePDF = File(pathDanfe);
    filePDF.writeAsBytesSync(fileDecode);

    return pathDanfe;
  }

  Future<String> _carregaNotasFiscaisIR(Propriedade propriedade, User user, int anoFiltro, String nomeArquivo) async {
    List<NotaFiscal> listNotasFiscais = await _apiNotaFiscal.getListaNotasFiscais(propriedade.pessoa!.numeroDocumento!, user.token!, user.empresa!);

    List<Estabelecimento> listEstabelecimento = await _apiEstabel.getEstabelecimento(propriedade.codProdutor.toString(), user.token!, user.empresa!);

    if (listEstabelecimento.isEmpty) {
      throw Exception('Nenhum estabelecimento encontrado para o produtor.');
    }

    listNotasFiscais = listNotasFiscais.where((element) => (element.dataEmissao?.year == anoFiltro && element.statusNfe == "AUTORIZADO")).toList();

    if (listNotasFiscais.isNotEmpty) {
      final data = await construirArquivoIRPDF(user, listEstabelecimento[0], listNotasFiscais, propriedade);
      return await _gravarArquivoNoDispositivo(nomeArquivo, data);
    } else {
      return throw Exception('Não há dados para serem impressos em arquivo PDF');
    }
  }

  Future<Uint8List> construirArquivoIRPDF(User user, Estabelecimento estabelecimento, List<NotaFiscal> listNotasFiscais, Propriedade produtor) async {
    final pdf = pw.Document();
    final double fontSizeDefault = 9;
    double sumVlrTotal = 0;
    double sumRetFunrural = 0;
    double sumVlrLiquido = 0;

    for (NotaFiscal nf in listNotasFiscais) {
      sumVlrTotal += nf.valorTotal!;
      sumRetFunrural += nf.valorFunrural!;
      sumVlrLiquido += nf.valorLiquido!;
    }

    final bgShape = await rootBundle.loadString("assets/images/resume.svg");

    pdf.addPage(pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4.applyMargin(left: 2.0 * PdfPageFormat.cm, top: 4.0 * PdfPageFormat.cm, right: 2.0 * PdfPageFormat.cm, bottom: 2.0 * PdfPageFormat.cm),
        buildBackground: (pw.Context context) {
          return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(
              children: [
                pw.Positioned(
                  child: pw.SvgImage(svg: bgShape),
                  left: 0,
                  top: 0,
                ),
                pw.Positioned(
                  child: pw.Transform.rotate(angle: pi, child: pw.SvgImage(svg: bgShape)),
                  right: 0,
                  bottom: 0,
                ),
              ],
            ),
          );
        },
      ),
      build: (pw.Context context) => [
        pw.Partitions(children: [
          pw.Partition(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 0),
                  child: pw.Table(border: pw.TableBorder.all(), children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Column(
                                children: [
                                  pw.Text(
                                    estabelecimento.pessoa!.nomeRazaoSocial!,
                                    style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold),
                                  ),
                                ],
                              ),
                              pw.SizedBox(width: 150),
                              pw.Column(
                                children: [
                                  pw.Text(
                                    "Período: 01/01/${GlobalData.periodo.year} à 31/12/${GlobalData.periodo.year}",
                                    style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 0),
                  child: pw.Table(border: pw.TableBorder.all(), children: []),
                ),
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 20),
                  child: pw.Table(
                    border: pw.TableBorder.all(),
                    children: [
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Row(children: [
                            pw.Text("Endereço: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                            pw.Text(estabelecimento.pessoa!.endereco!, style: pw.TextStyle(fontSize: fontSizeDefault)),
                          ]),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Row(children: [
                            pw.Text("Bairro: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                            pw.Text(estabelecimento.pessoa!.bairro!, style: pw.TextStyle(fontSize: fontSizeDefault)),
                          ]),
                        ),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Row(children: [
                            pw.Text("Cidade: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                            pw.Text(estabelecimento.pessoa!.cidade!.nome!, style: pw.TextStyle(fontSize: fontSizeDefault)),
                          ]),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Row(children: [
                            pw.Text("Estado: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                            pw.Text(estabelecimento.pessoa!.cidade!.estado!.sigla!, style: pw.TextStyle(fontSize: fontSizeDefault)),
                          ]),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Row(children: [
                            pw.Text("CEP: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                            pw.Text(estabelecimento.pessoa!.cep!, style: pw.TextStyle(fontSize: fontSizeDefault)),
                          ]),
                        ),
                      ]),
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Row(children: [
                            pw.Text("CNPJ: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                            pw.Text(estabelecimento.pessoa!.numeroDocumento!, style: pw.TextStyle(fontSize: fontSizeDefault)),
                          ]),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Row(children: [
                            pw.Text("Ins-Estadual:", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                            pw.Text(estabelecimento.pessoa!.inscricaoEstadual!, style: pw.TextStyle(fontSize: fontSizeDefault)),
                          ]),
                        ),
                      ]),
                    ],
                  ),
                ),
                pw.Padding(
                    padding: pw.EdgeInsets.only(top: 20),
                    child: pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Row(children: [
                              pw.Text("Fornecedor: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                              pw.Text(produtor.codigoNomeProdutor!, style: pw.TextStyle(fontSize: fontSizeDefault))
                            ]),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Row(children: [
                              pw.Text(
                                "CPF/CNPJ: ",
                                style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                user.username!,
                                style: pw.TextStyle(fontSize: fontSizeDefault),
                              ),
                            ]),
                          ),
                        ]),
                        pw.TableRow(children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Row(children: [
                              pw.Text("Endereço: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                              pw.Text(produtor.pessoa!.endereco!, style: pw.TextStyle(fontSize: fontSizeDefault))
                            ]),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Row(children: [
                              pw.Text("Cidade: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                              pw.Text(produtor.pessoa!.cidade!.nome!, style: pw.TextStyle(fontSize: fontSizeDefault)),
                            ]),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Row(children: [
                              pw.Text("Estado: ", style: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold)),
                              pw.Text(produtor.pessoa!.cidade!.estado!.sigla!, style: pw.TextStyle(fontSize: fontSizeDefault))
                            ]),
                          ),
                        ]),
                      ],
                    )),
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 20),
                  child: pw.Table.fromTextArray(
                    headerStyle: pw.TextStyle(fontSize: fontSizeDefault, fontWeight: pw.FontWeight.bold),
                    cellStyle: pw.TextStyle(fontSize: fontSizeDefault),
                    cellAlignment: pw.Alignment.bottomRight,
                    data: <List<String>>[
                      <String>['Data', 'Documento', 'Série', 'Espécie', 'Qt. Total', 'Vlr. Total', 'Retenção de Funrural', 'Vlr. Líquido'],
                      ...listNotasFiscais.map(
                        (nf) => [
                          DateFormat("dd/MM/yyyy").format(nf.dataEmissao!),
                          nf.nrNotaFiscal!,
                          nf.serie!,
                          nf.especie!,
                          NumberFormat('#,##0.00', 'pt_BR').format(nf.quantidadeTotal),
                          NumberFormat('#,##0.00', 'pt_BR').format(nf.valorTotal),
                          NumberFormat('#,##0.00', 'pt_BR').format(nf.valorFunrural),
                          NumberFormat('#,##0.00', 'pt_BR').format(nf.valorLiquido),
                        ],
                      ),
                      <String>[
                        '',
                        '',
                        '',
                        '',
                        '',
                        NumberFormat('#,##0.00', 'pt_BR').format(sumVlrLiquido),
                        NumberFormat('#,##0.00', 'pt_BR').format(sumRetFunrural),
                        NumberFormat('#,##0.00', 'pt_BR').format(sumVlrTotal),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          )
        ])
      ],
    ));

    return pdf.save();
  }

  Future<String> _gravarArquivoNoDispositivo(String nomeArquivo, Uint8List byteList) async {
    nomeArquivo = (nomeArquivo) ?? "informeRendimentos";

    Directory tempDir = await getTemporaryDirectory();
    String pathFile = "${tempDir.path}/$nomeArquivo.pdf";

    final filePDF = File(pathFile);
    // REABILITAR GRAVADOR QUE CONSTROI PDF
    // filePDF.writeAsBytesSync(fileDecode);
    await filePDF.writeAsBytes(byteList);

    return pathFile;
  }

  @override
  Widget build(BuildContext context) {
    var _auth = Provider.of<AuthModel>(context, listen: true);
    final colorScheme = Theme.of(context).colorScheme;
    User? user = _auth.user;

    // Ensure `propriedade` is not null
    Propriedade? propriedade = widget.propriedade;
    if (propriedade == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Erro"),
        ),
        body: Center(
          child: Text("Propriedade não encontrada."),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          toolbarHeight: 90,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(propriedade.pessoa?.nomeRazaoSocial ?? "Nome não disponível", style: TextStyle(fontSize: 25.0)),
              Text(
                "${propriedade.codProdutor} - ${(propriedade.nomePropriedade ?? 'Propriedade sem nome')}",
                style: TextStyle(fontSize: 12.0),
              ),
              Text('Ano ${DateFormat.y('pt_BR').format(GlobalData.periodo)}', style: TextStyle(fontSize: 12.0)),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  try {
                    final pathPDF = await _carregaNotasFiscaisIR(
                        propriedade, user!, GlobalData.periodo.year, nomeArquivoIR);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PDFScreen(path: pathPDF, nameFilePDF: nomeArquivoIR),
                        ));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro ao carregar PDF: ${e.toString()}")),
                    );
                  }
                },
                icon: const Icon(Icons.monetization_on)),
            IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  _showYearPicker(context, GlobalData.periodo);
                }),
          ],
        ),
        drawer: AppDrawer(),
        body: SafeArea(
          child: ListView(children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                children: <Widget>[
                  FutureBuilder<List<NotaFiscal>>(
                    future: _carregaNFs(propriedade, user!),
                    builder: (context, listNFs) {
                      if (listNFs.hasData) {
                        if (listNFs.data!.isNotEmpty) {
                          return Scrollbar(
                            child: ListView.builder(
                              physics: const ScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: listNFs.data!.length,
                              itemBuilder: ((context, index) {
                                final linha = listNFs.data![index];
                                final nomeArquivo = "DANFE Nota Fiscal ${linha.nrNotaFiscal}";

                                return Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: linha.corStatus ?? Colors.grey,
                                          child: linha.iconeStatus ?? Icon(Icons.error),
                                        ),
                                        title: Text(
                                          linha.nrNotaFiscal?.toString() ?? "Sem número",
                                          style: TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          children: <Widget>[
                                            Row(
                                              children: [
                                                Text('Data Emissão: '),
                                                Text(
                                                  linha.dataEmissao != null
                                                      ? DateFormat('dd/MM/yyyy').format(linha.dataEmissao!)
                                                      : "Data não disponível",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                              ],
                                            ),
                                            Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Status: ${linha.statusNfe ?? "Indisponível"}'))
                                          ],
                                        ),
                                        trailing: CircleAvatar(child: Icon(Icons.picture_as_pdf)),
                                        onTap: () async {
                                          try {
                                            final pathPDF = await _carregaDANFE(user, linha.chaveAcesso!, nomeArquivo);

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => PDFScreen(
                                                    path: pathPDF,
                                                    nameFilePDF: nomeArquivo,
                                                    nomeDocumento: nomeArquivo,
                                                  ),
                                                ));
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text("Erro ao abrir PDF: ${e.toString()}")),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          );
                        } else {
                          return Card(
                              child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              'Não há nenhuma Nota Fiscal emitida no ano de ${DateFormat.y('pt_BR').format(GlobalData.periodo)}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ));
                        }
                      } else {
                        return LoaderFeedbackCow(
                          mensagem: 'Carregando Notas Fiscais...',
                          size: 60,
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _showYearPicker(BuildContext context, DateTime _selectedDate) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Selecione o Ano"),
          content: Container(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 100, 1),
              lastDate: DateTime(DateTime.now().year + 100, 1),
              initialDate: DateTime.now(),
              selectedDate: _selectedDate,
              onChanged: (DateTime dateTime) {
                Navigator.pop(context);
                setState(() {
                  GlobalData.periodo = dateTime;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
