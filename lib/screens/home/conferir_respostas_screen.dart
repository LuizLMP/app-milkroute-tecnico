import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:milkroute_tecnico/auth.dart';
import 'package:milkroute_tecnico/controller/syncController.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/anexos_visita_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/categoriapergunta_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/respostaitem_dao_impl.dart';
import 'package:milkroute_tecnico/database/sqlite/dao/visita_dao_impl.dart';
import 'package:milkroute_tecnico/model/anexos_visita.dart';
import 'package:milkroute_tecnico/model/categoriapergunta.dart';
import 'package:milkroute_tecnico/model/opcao.dart';
import 'package:milkroute_tecnico/model/pergunta.dart';
import 'package:milkroute_tecnico/model/questionario.dart';
import 'package:milkroute_tecnico/model/resposta.dart';
import 'package:milkroute_tecnico/model/resposta_item.dart';
import 'package:milkroute_tecnico/model/type/tipo_consulta.dart';
import 'package:milkroute_tecnico/model/visita.dart';
import 'package:milkroute_tecnico/screens/home/visitas_screen.dart';
import 'package:milkroute_tecnico/utils.dart';
import 'package:milkroute_tecnico/widgets/answer_constructor.dart';
import 'package:milkroute_tecnico/widgets/dialogs.dart';
import 'package:milkroute_tecnico/widgets/loader_feedback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:signature/signature.dart';

class ConferirRespostas extends StatefulWidget {
  const ConferirRespostas(
      {super.key, this.questionario, this.resposta, this.blockRespostas});
  final Questionario? questionario;
  final Resposta? resposta;
  final bool? blockRespostas;

  @override
  State<ConferirRespostas> createState() => _ConferirRespostasState();
}

class _ConferirRespostasState extends State<ConferirRespostas> {
  bool _estaSalvandoVisita = false;
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 4,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
    strokeCap: StrokeCap.round,
  );

  Future<bool> _verificaObrigatoriasNaoRespondidas(
      Questionario questionario, Resposta resposta) async {
    bool flagPendencia = false;

    List<CategoriaPergunta> listCategorias = await CategoriaPerguntaDAOImpl()
        .selectAll(CategoriaPergunta(questionario: questionario),
            TipoConsultaDB.PorQuestionario);

    for (CategoriaPergunta categoriaPergunta in listCategorias) {
      for (Pergunta pergunta in categoriaPergunta.listPerguntas!) {
        if (pergunta.obrigatorio == true) {
          List<RespostaItem> returnResposta = await RespostaItemDAOImpl()
              .selectAll(RespostaItem(pergunta: pergunta, resposta: resposta),
                  TipoConsultaDB.PorPergunta);

          if (returnResposta.isEmpty) {
            flagPendencia = true;
          }
        }
      }
    }

    return flagPendencia;
  }

  Future<List<RespostaItem>> _carregaResposta(
      Pergunta pergunta, Resposta resposta) async {
    List<RespostaItem> listRespostaItem = [];

    listRespostaItem = await RespostaItemDAOImpl().selectAll(
        RespostaItem(pergunta: pergunta, resposta: resposta),
        TipoConsultaDB.PorPergunta);

    if (listRespostaItem.isEmpty) {
      listRespostaItem.add(RespostaItem(
          pergunta: pergunta,
          resposta: resposta,
          descricao: "SEM RESPOSTA",
          opcao: Opcao(
            descricao: "SEM RESPOSTA",
          )));
    }

    return listRespostaItem.toList();
  }

  Future<Position> getCoordenadas() async {
    try {
      LocationPermission permissoes;

      bool ativado = await Geolocator.isLocationServiceEnabled();
      if (!ativado) {
        return Future.error(
            "Não foi possível capturar a localização. Por favor, habilite a localização do seu dispositivo!");
      }

      permissoes = await Geolocator.checkPermission();
      if (permissoes == LocationPermission.denied ||
          permissoes == LocationPermission.deniedForever) {
        permissoes = await Geolocator.requestPermission();
        if (permissoes == LocationPermission.denied ||
            permissoes == LocationPermission.deniedForever) {
          return Future.error(
              "Não foi possível capturar a localização. Por favor, habilite a permissão de acesso a geolocalização do seu aplicativo Milkroute Técnico!");
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (ex) {
      throw Exception(ex);
    }
  }

  Future<bool> _finalizarVisita(
      Position localizacao, DateTime dataConclusao, Resposta resposta) async {
    try {
      List<Visita> carregaVisita = await VisitaDAOImpl()
          .selectAll(resposta.visita!, TipoConsultaDB.PorPK);

      if (carregaVisita.isNotEmpty) {
        Visita salvaVisita = carregaVisita[0];
        salvaVisita.latitude = localizacao.latitude;
        salvaVisita.longitude = localizacao.longitude;
        salvaVisita.dataFinalizacao = dataConclusao;
        salvaVisita.finalizado = true;
        salvaVisita.statusVisita = "FINALIZADO";
        //salvaVisita.statusVisita = "SOLICITADO";
        salvaVisita.dataHoraIU = DateTime.now();
        await VisitaDAOImpl().update(salvaVisita);

        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print(
          "Erro _finalizarVisita: ${ex.toString().substring(ex.toString().indexOf(':') + 1)}");
      return false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final _auth = context.read<AuthModel>();

    return Container(
      child: Column(children: <Widget>[
        ListTile(
            title: Text('Confira as respostas antes de concluir a visita!')),
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "(*) Pergunta obrigatória",
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
        ),
        Divider(
          color: colorScheme.primary,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          child: Column(
            children: <Widget>[
              for (final categoria in widget.questionario!.listCategorias!)
                Container(
                  child: Column(
                    children: [
                      for (final pergunta in categoria.listPerguntas!)
                        FutureBuilder<List<RespostaItem>>(
                          future: _carregaResposta(pergunta, widget.resposta!),
                          builder: (context, retunrRespostaItem) {
                            List<RespostaItem>? listRespostaItem = [];
                            bool mostrarResposta = true;

                            if (retunrRespostaItem.hasData) {
                              listRespostaItem = retunrRespostaItem.data;

                              if (listRespostaItem!.isEmpty ||
                                  listRespostaItem[0].descricao ==
                                      "SEM RESPOSTA") {
                                mostrarResposta = false;
                              }

                              return Visibility(
                                visible: pergunta.ativa! && mostrarResposta,
                                child: Container(
                                  child: AnswerConstructor(
                                    pergunta: pergunta,
                                    resposta: widget.resposta!,
                                    listRespostaItem: listRespostaItem,
                                  ),
                                ),
                              );
                            } else {
                              return LoaderFeedbackCow(
                                mensagem: "Carregando respostas..!",
                                size: 60,
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Divider(
          color: colorScheme.primary,
        ),
        if (widget.blockRespostas! || _estaSalvandoVisita == true)
          ElevatedButton(onPressed: null, child: Text('Anexar Fotos'))
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Escolha uma opção'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: colorScheme.primary,
                                    ),
                                    Padding(padding: EdgeInsets.all(8.0)),
                                    Text('Câmera'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(ImageSource.camera);
                                },
                              ),
                              Padding(padding: EdgeInsets.all(8.0)),
                              GestureDetector(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.image,
                                      color: colorScheme.primary,
                                    ),
                                    Padding(padding: EdgeInsets.all(8.0)),
                                    Text('Galeria'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context)
                                      .pop(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).then((value) async {
                    if (value != null) {
                      if (await _saveImage(
                          value, widget.resposta!.visita!.idAppTecnico!)) {
                        setState(() {});
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Erro ao salvar imagem!'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  });
                },
                child: Text('Anexar Fotos'),
              ),
              Container(
                child: IconButton(
                    icon: Icon(Icons.help_outlined),
                    iconSize: 20.0,
                    color: colorScheme.primary,
                    onPressed: () {
                      return dialogInfo(
                        context,
                        "Voltar",
                        Text("Guia de ações"),
                        Text(
                            "- Para excluir uma foto, pressione e segure em cima da imagem desejada\n"),
                      );
                    }),
              ),
            ],
          ),
        FutureBuilder<List<FileSystemEntity>>(
          future:
              _carregarThumnnailsAnexos(widget.resposta!.visita!.idAppTecnico!),
          builder: (context, listFotos) {
            if (listFotos.hasData) {
              if (listFotos.data!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 3,
                        padding: const EdgeInsets.all(10.0),
                        childAspectRatio: 1.1,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        children:
                            List.generate(listFotos.data!.length, (index) {
                          final imagem = listFotos.data![index];
                          final foto = imagem.path.split('/').last;
                          String addresFile = imagem.path;

                          if (widget.blockRespostas!) {
                            return Container(
                              margin: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                  image: FileImage(File(addresFile)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onLongPress: () async {
                                if (await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirmação'),
                                      content: Text('Deseja apagar a imagem?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text('Sim'),
                                        ),
                                      ],
                                    );
                                  },
                                )) {
                                  if (await _deleteAnexo(foto,
                                      widget.resposta!.visita!.idAppTecnico!)) {
                                    setState(() {});
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Erro ao apagar imagens!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                    image: FileImage(File(addresFile)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Nenhuma foto salva!'),
                  ),
                );
              }
            } else {
              return LoaderFeedbackCow(
                mensagem: "Carregando quantidade de arquivos...",
                size: 60,
              );
            }
          },
        ),
        Divider(
          color: colorScheme.primary,
        ),
        Stack(
          children: [
            Column(
              children: [
                Center(
                  child: Text(
                    'Assinatura do Produtor',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.blockRespostas! || _estaSalvandoVisita)
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      TextButton(onPressed: null, child: Icon(Icons.edit)),
                      TextButton(onPressed: null, child: Icon(Icons.delete)),
                    ],
                  )
                else
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Campo de assinatura'),
                                  content: Container(
                                    height: 200,
                                    width: 300,
                                    child: Signature(
                                      controller: _controller,
                                      height: 200,
                                      width: 300,
                                      backgroundColor: Colors.grey[200]!,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Voltar'),
                                    ),
                                    TextButton(
                                      onPressed: () => _controller.clear(),
                                      child: Text('Limpar campo'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Finalizar'),
                                    ),
                                  ],
                                );
                              },
                            ).then((value) async {
                              if (value) {
                                final signatureBytes =
                                    await _controller.toPngBytes();
                                if (signatureBytes != null &&
                                    await _saveAssinatura(
                                        signatureBytes,
                                        widget
                                            .resposta!.visita!.idAppTecnico!)) {
                                  setState(() {});
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        'Erro: Nenhuma assinatura inserida!'),
                                    backgroundColor: Colors.red,
                                  ));
                                }
                              }
                            });
                          },
                          child: Icon(Icons.edit)),
                      TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirmação'),
                                  content: Text('Deseja apagar a assinatura?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Sim'),
                                    ),
                                  ],
                                );
                              },
                            ).then((value) async {
                              if (value) {
                                _controller.clear();
                                if (!await _deleteAssinatura(
                                    widget.resposta!.visita!.idAppTecnico!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Erro ao apagar assinatura!'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                setState(() {});
                              }
                            });
                          },
                          child: Icon(Icons.delete, color: Colors.red)),
                    ],
                  ),
                FutureBuilder(
                  future: _carregarAssinatura(
                      widget.resposta!.visita!.idAppTecnico!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              for (final assinatura in snapshot.data!)
                                Container(
                                  child: Image.file(
                                    File(assinatura.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Nenhuma assinatura salva!'),
                          ),
                        );
                      }
                    } else {
                      return LoaderFeedbackCow(
                        mensagem: "Carregando assinatura...",
                        size: 60,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        Divider(
          color: colorScheme.primary,
        ),
        FutureBuilder(
          future: _verificaObrigatoriasNaoRespondidas(
              widget.questionario!, widget.resposta!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                if (snapshot.data == false) {
                  if (widget.blockRespostas!) {
                    return ElevatedButton(
                        onPressed: null, child: Text('Visita Finalizada'));
                  } else {
                    if (_estaSalvandoVisita == true) {
                      return ElevatedButton(
                          onPressed: null, child: Text('Salvando visita...'));
                    } else {
                      return ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _estaSalvandoVisita = true;
                          });
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year - 1),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                  cancelText: 'Cancelar',
                                  keyboardType: TextInputType.datetime,
                                  helpText:
                                      'Informe a data de conclusão da visita')
                              .then((pickedDate) async {
                            print(pickedDate);

                            if (pickedDate == null) {
                              setState(() {
                                _estaSalvandoVisita = false;
                              });
                            } else {
                              Position coordenadasLocalVisita =
                                  await getCoordenadas();

                              bool returnSalvaVisita = await _finalizarVisita(
                                  coordenadasLocalVisita,
                                  pickedDate,
                                  widget.resposta!);

                              if (returnSalvaVisita) {
                                await SyncController().atualizaLoaderBar(
                                    "Enviando dados de Visitas", 1);
                                //await SyncController.instance.syncDados(_auth.user);
                                return Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => VisitasScreen()));
                              }
                            }
                          });
                        },
                        child: Text('Concluir visita'),
                      );
                    }
                  }
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                          'Existem perguntas obrigatórias sem resposta. Preencha as respostas solicitadas para concluir a visita!'),
                    ),
                  );
                }
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                        'Foram encontrados problemas para a validação do Questionário de Visita. Revise o preenchimento das perguntas e tente novamente!'),
                  ),
                );
              }
            } else {
              return LoaderFeedbackCow(
                mensagem: "Validando respostas! Aguarde...",
                size: 60,
              );
            }
          },
        ),
      ]),
    );
  }

  Future<List<FileSystemEntity>> _carregarThumnnailsAnexos(
      String idAppTecnico) async {
    try {
      List<FileSystemEntity> filesSelect = [];
      Directory tempDir = Directory(
          path.join((await getTemporaryDirectory()).path, "images/thumbnails"));
      List<FileSystemEntity> files = tempDir.listSync();
      for (FileSystemEntity file in files) {
        String fileName = file.path.split('/').last;

        if (fileName.contains(idAppTecnico)) {
          filesSelect.add(file);
        }
      }

      return filesSelect;
    } catch (ex) {
      print("Erro na busca de imagens para esta visita. Motivo: $ex");
      return [];
    }
  }

  Future<bool> _saveImage(value, String idVisita) async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: value);
      if (image != null) {
        final Directory appDir = await getTemporaryDirectory();
        final String hashImage = image.name.split('.').first;
        final String appDirPath = appDir.path;
        final String imagesDirPath = '$appDirPath/images';
        final String thumbsImagesDirPath = '$imagesDirPath/thumbnails';
        final Directory imagesDir = Directory(imagesDirPath);
        final Directory thumbsImagesDir = Directory(thumbsImagesDirPath);
        if (!await imagesDir.exists()) {
          await imagesDir.create(recursive: true);
        }
        if (!await thumbsImagesDir.exists()) {
          await thumbsImagesDir.create(recursive: true);
        }

        final String imagePath =
            '$imagesDirPath/$idVisita' + '_' + '$hashImage.jpg';
        final String thumbnailPath =
            '$thumbsImagesDirPath/$idVisita' + '_' + '$hashImage.jpg';
        await image.saveTo(imagePath);

        // Compress the image using the `image` package
        final originalImage = File(image.path).readAsBytesSync();
        final decodedImage = img.decodeImage(originalImage);
        if (decodedImage != null) {
          final thumbnail =
              img.copyResize(decodedImage, width: 200, height: 200);
          final compressedThumbnail = File(thumbnailPath)
            ..writeAsBytesSync(img.encodeJpg(thumbnail, quality: 25));
        }

        await AnexosVisitaDAOImpl().insert(AnexosVisita(
          idAppTecnico: hashImage,
          idAppTecnicoVisita: idVisita,
          nomeArquivo: image.name,
          caminhoArquivo: imagePath,
          tipoArquivo: TipoArquivo.Anexo,
          dataHoraIU: DateTime.now(),
        ));
      }
      return true;
    } catch (ex) {
      print("Erro ao salvar imagem. Motivo: $ex");
      return false;
    }
  }

  Future<bool> _deleteAnexo(String nomeAnexo, String idAppTecnico) async {
    try {
      final Directory appDir = await getTemporaryDirectory();
      final String appDirPath = appDir.path;
      final String imagesDirPath = '$appDirPath/images';
      final String imagesThumbsDirPath = '$appDirPath/images/thumbnails';
      final String imageCachePath = '$appDirPath/${nomeAnexo.split('_').last}';
      final String imagePath = '$imagesDirPath/$nomeAnexo';
      final String imageThumbsPath = '$imagesThumbsDirPath/$nomeAnexo';

      await File(imageCachePath).delete(); // APAGA DO CACHE
      await File(imagePath).delete(); // APAGAR A IMAGEM ORIGINAL
      await File(imageThumbsPath).delete(); // APAGAR A THUMBNAIL
      String idAppTecnicoAnexo = (nomeAnexo.split('_').last).split('.').first;

      await AnexosVisitaDAOImpl().remove(
          AnexosVisita(
            idAppTecnico: idAppTecnicoAnexo,
            tipoArquivo: TipoArquivo.Anexo,
          ),
          TipoConsultaDB.PorPK);

      return true;
    } catch (ex) {
      print("Erro ao deletar imagens. Motivo: $ex");
      return false;
    }
  }

  Future<bool> _saveAssinatura(Uint8List pngBytes, String idVisita) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      final String hashImage = HashGenerator().geradorSha1Random(idVisita);
      final String tempDirPath = tempDir.path;
      final String signDirPath = '$tempDirPath/sign';
      final Directory signDir = Directory(signDirPath);

      if (!await signDir.exists()) {
        await signDir.create(recursive: true);
      }

      final String nameFile = 'assinatura_$idVisita' + '_$hashImage.png';
      final String signImagePath = '$signDirPath/$nameFile';
      final fileImage = File(signImagePath);

      List<FileSystemEntity> files = signDir.listSync();

      for (FileSystemEntity file in files) {
        String fileName = file.path.split('/').last;

        if (fileName.contains(idVisita)) {
          await fileImage.delete();
        }
      }

      await fileImage.writeAsBytes(pngBytes);

      await AnexosVisitaDAOImpl().insert(AnexosVisita(
        idAppTecnico: hashImage,
        idAppTecnicoVisita: idVisita,
        nomeArquivo: nameFile,
        caminhoArquivo: signImagePath,
        tipoArquivo: TipoArquivo.Assinatura,
        dataHoraIU: DateTime.now(),
      ));

      return true;
    } catch (ex) {
      print("Erro ao salvar assinatura. Motivo: $ex");
      return false;
    }
  }

  Future<List<FileSystemEntity>> _carregarAssinatura(
      String idAppTecnico) async {
    try {
      List<FileSystemEntity> filesSelect = [];
      Directory tempDir =
          Directory(path.join((await getTemporaryDirectory()).path, "sign"));
      List<FileSystemEntity> files = tempDir.listSync();
      for (FileSystemEntity file in files) {
        String fileName = file.path.split('/').last;

        if (fileName.contains(idAppTecnico)) {
          filesSelect.add(file);
        }
      }

      return filesSelect;
    } catch (ex) {
      print("Erro na busca de imagens para esta visita. Motivo: $ex");
      return [];
    }
  }

  Future<bool> _deleteAssinatura(String idAppTecnico) async {
    try {
      Directory tempDir =
          Directory(path.join((await getTemporaryDirectory()).path, "sign"));
      List<FileSystemEntity> files = tempDir.listSync();
      for (FileSystemEntity file in files) {
        String fileName = file.path.split('/').last;

        if (fileName.contains(idAppTecnico)) {
          await File(file.path).delete();

          await AnexosVisitaDAOImpl().remove(
              AnexosVisita(
                idAppTecnicoVisita: idAppTecnico,
                tipoArquivo: TipoArquivo.Assinatura,
              ),
              TipoConsultaDB.PorVisita);
        }
      }

      return true;
    } catch (ex) {
      print("Erro ao deletar assinatura. Motivo: $ex");
      return false;
    }
  }
}
