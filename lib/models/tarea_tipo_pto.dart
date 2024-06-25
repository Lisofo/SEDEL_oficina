// To parse this JSON data, do
//
//     final tareaTipoPto = tareaTipoPtoFromJson(jsonString);

import 'dart:convert';

List<TareaTipoPto> tareaTipoPtoFromJson(String str) => List<TareaTipoPto>.from(json.decode(str).map((x) => TareaTipoPto.fromJson(x)));

String tareaTipoPtoToJson(List<TareaTipoPto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TareaTipoPto {
  late int configTpiTareaId;
  late int tipoPuntoInspeccionId;
  late String modo;
  late int tareaId;
  late String codTarea;
  late String descripcion;

  TareaTipoPto({
    required this.configTpiTareaId,
    required this.tipoPuntoInspeccionId,
    required this.modo,
    required this.tareaId,
    required this.codTarea,
    required this.descripcion,
  });

  factory TareaTipoPto.fromJson(Map<String, dynamic> json) => TareaTipoPto(
    configTpiTareaId: json["configTPITareaId"] as int? ?? 0,
    tipoPuntoInspeccionId: json["tipoPuntoInspeccionId"] as int? ?? 0,
    modo: json["modo"] as String? ?? '',
    tareaId: json["tareaId"] as int? ?? 0,
    codTarea: json["codTarea"] as String? ?? '',
    descripcion: json["descripcion"] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    "configTPITareaId": configTpiTareaId,
    "tipoPuntoInspeccionId": tipoPuntoInspeccionId,
    "modo": modo,
    "tareaId": tareaId,
    "codTarea": codTarea,
    "descripcion": descripcion,
  };

  TareaTipoPto.empty() {
  configTpiTareaId = 0;
  tipoPuntoInspeccionId = 0;
  modo = '';
  tareaId = 0;
  codTarea = '';
  descripcion = '';
  }
}
