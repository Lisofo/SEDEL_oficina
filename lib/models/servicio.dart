// To parse this JSON data, do
//
//     final servicio = servicioFromMap(jsonString);

import 'dart:convert';

List<Servicio> servicioFromMap(String str) =>
    List<Servicio>.from(json.decode(str).map((x) => Servicio.fromJson(x)));

String servicioToMap(List<Servicio> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Servicio {
  late int servicioId;
  late String codServicio;
  late String descripcion;
  late TipoServicio tipoServicio;
  late int tipoServicioId;

  Servicio({
    required this.servicioId,
    required this.codServicio,
    required this.descripcion,
    required this.tipoServicio,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) => Servicio(
        servicioId: json["servicioId"],
        codServicio: json["codServicio"],
        descripcion: json["descripcion"],
        tipoServicio: TipoServicio.fromMap(json["tipoServicio"]),
      );

  Map<String, dynamic> toMap() => {
        "servicioId": servicioId,
        "codServicio": codServicio,
        "descripcion": descripcion,
        "tipoServicio": tipoServicio.toMap(),
        "tipoServicioId": tipoServicioId,
      };

  Servicio.empty() {
    servicioId = 0;
    codServicio = '';
    descripcion = '';
    tipoServicio = TipoServicio.empty();
    tipoServicioId = 0;
  }

  @override
  String toString() {
    return descripcion;
  }
}

class TipoServicio {
  late int tipoServicioId;
  late String codTipoServicio;
  late String descripcion;

  TipoServicio({
    required this.tipoServicioId,
    required this.codTipoServicio,
    required this.descripcion,
  });

  factory TipoServicio.fromMap(Map<String, dynamic> json) => TipoServicio(
        tipoServicioId: json["tipoServicioId"],
        codTipoServicio: json["codTipoServicio"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toMap() => {
        "tipoServicioId": tipoServicioId,
        "codTipoServicio": codTipoServicio,
        "descripcion": descripcion,
      };

  TipoServicio.empty() {
    tipoServicioId = 0;
    codTipoServicio = '';
    descripcion = '';
  }
}
