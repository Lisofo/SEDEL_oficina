// To parse this JSON data, do
//
//     final informe = informeFromJson(jsonString);

import 'dart:convert';

List<ConstanciaVisita> informeFromJson(String str) => List<ConstanciaVisita>.from(json.decode(str).map((x) => ConstanciaVisita.fromJson(x)));

String informeToJson(List<ConstanciaVisita> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ConstanciaVisita {
  late String filename;
  late String filepath;
  late int ordenTrabajoId;
  late DateTime fechaOrdenTrabajo;

  ConstanciaVisita({
    required this.filename,
    required this.filepath,
    required this.ordenTrabajoId,
    required this.fechaOrdenTrabajo,
  });

  factory ConstanciaVisita.fromJson(Map<String, dynamic> json) => ConstanciaVisita(
    filename: json["filename"] as String? ?? '',
    filepath: json["filepath"] as String? ?? '',
    ordenTrabajoId: json["ordenTrabajoId"] as int? ?? 0,
    fechaOrdenTrabajo: DateTime.parse(json["fechaOrdenTrabajo"]),
  );

  Map<String, dynamic> toJson() => {
    "filename": filename,
    "filepath": filepath,
    "ordenTrabajoId": ordenTrabajoId,
    "fechaOrdenTrabajo": fechaOrdenTrabajo.toIso8601String(),
  };

  ConstanciaVisita.empty(){
    filename = '';
    filepath = '';
    ordenTrabajoId = 0;
    fechaOrdenTrabajo = DateTime.now();
  }
}
