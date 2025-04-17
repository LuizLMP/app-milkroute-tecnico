import 'package:milkroute_tecnico/model/pessoa.dart';
import 'package:milkroute_tecnico/model/tecnico.dart';

class Estabelecimento {
  String? codEstabel;
  Pessoa? pessoa;
  String? regimeEspecialColeta;
  double? latitude;
  double? longitude;
  String? imagem;
  String? ambienteIntegracao;
  String? codigoNomeEstabel;
  Tecnico? tecnico;

  Estabelecimento({
    this.codEstabel,
    this.pessoa,
    this.regimeEspecialColeta,
    this.latitude,
    this.longitude,
    this.imagem,
    this.ambienteIntegracao,
    this.codigoNomeEstabel,
    this.tecnico,
  });

  Estabelecimento.fromJson(Map<String, dynamic> json) {
    codEstabel = json['codEstabel'];
    pessoa = json['pessoa'] != null ? Pessoa.fromJson(json['pessoa']) : null;
    regimeEspecialColeta = json['regimeEspecialColeta'];
    latitude = json['latitude'] as double;
    longitude = json['longitude'] as double;
    imagem = json['imagem'];
    ambienteIntegracao = json['ambienteIntegracao'];
    codigoNomeEstabel = json['codigoNomeEstabel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['codEstabel'] = codEstabel;
    if (pessoa != null) {
      data['pessoa'] = pessoa?.toJson();
    }
    data['regimeEspecialColeta'] = regimeEspecialColeta;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['imagem'] = imagem;
    data['ambienteIntegracao'] = ambienteIntegracao;
    data['codigoNomeEstabel'] = codigoNomeEstabel;
    return data;
  }
}
