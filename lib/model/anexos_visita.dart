class AnexosVisita {
  String? idAppTecnico;
  String? idAppTecnicoVisita;
  String? nomeArquivo;
  String? caminhoArquivo;
  DateTime? dataHoraIU = DateTime.parse('0001-01-01 00:00:00');
  TipoArquivo? tipoArquivo;

  AnexosVisita({
    this.idAppTecnico,
    this.idAppTecnicoVisita,
    this.nomeArquivo,
    this.caminhoArquivo,
    this.dataHoraIU,
    this.tipoArquivo,
  });
}

enum TipoArquivo { Anexo, Assinatura }
