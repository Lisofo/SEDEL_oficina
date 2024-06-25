// To parse this JSON data, do
//
//     final plagaTipoPto = plagaTipoPtoFromJson(jsonString);

import 'dart:convert';

List<PlagaTipoPto> plagaTipoPtoFromJson(String str) => List<PlagaTipoPto>.from(json.decode(str).map((x) => PlagaTipoPto.fromJson(x)));

String plagaTipoPtoToJson(List<PlagaTipoPto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PlagaTipoPto {
  late int configTpiPlagaId;
  late int tipoPuntoInspeccionId;
  late int plagaId;
  late String codPlaga;
  late String descripcion;

    PlagaTipoPto({
        required this.configTpiPlagaId,
        required this.tipoPuntoInspeccionId,
        required this.plagaId,
        required this.codPlaga,
        required this.descripcion,
    });

    factory PlagaTipoPto.fromJson(Map<String, dynamic> json) => PlagaTipoPto(
        configTpiPlagaId: json["configTPIPlagaId"] as int? ?? 0,
        tipoPuntoInspeccionId: json["tipoPuntoInspeccionId"] as int? ?? 0,
        plagaId: json["plagaId"] as int? ?? 0,
        codPlaga: json["codPlaga"] as String? ?? '',
        descripcion: json["descripcion"] as String? ?? '',
    );

    Map<String, dynamic> toJson() => {
        "configTPIPlagaId": configTpiPlagaId,
        "tipoPuntoInspeccionId": tipoPuntoInspeccionId,
        "plagaId": plagaId,
        "codPlaga": codPlaga,
        "descripcion": descripcion,
    };

  PlagaTipoPto.empty() {
    configTpiPlagaId = 0;
    tipoPuntoInspeccionId = 0;
    plagaId = 0;
    codPlaga = '';
    descripcion = '';
  }
}
