class Banco {
  String? nomeBanco;
  String? codFebraban;

  Banco({this.nomeBanco, this.codFebraban});

  Map<String, dynamic> toMap() {
    return {
      'codFebraban': codFebraban,
      'nomeBanco': nomeBanco,
    };
  }

  Banco.fromJson(Map<String, dynamic> json) {
    nomeBanco = json['nomeBanco'];
    codFebraban = json['codFebraban'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nomeBanco'] = nomeBanco;
    data['codFebraban'] = codFebraban;
    return data;
  }
}
