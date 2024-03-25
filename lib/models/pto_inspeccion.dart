// To parse this JSON data, do
//
//     final ptoinspeccion = ptoinspeccionFromMap(jsonString);

import 'dart:convert';

List<Ptoinspeccion> ptoinspeccionFromMap(String str) => List<Ptoinspeccion>.from(json.decode(str).map((x) => Ptoinspeccion.fromJson(x)));

String ptoinspeccionToMap(List<Ptoinspeccion> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Ptoinspeccion {
   late int puntoInspeccionId;
   late int planoId;
   late String codPuntoInspeccion;
   late String zona;
   late String sector;
   late String codigoBarra;
   late int tipoPuntoInspeccionId;
   late String codTipoPuntoInspeccion;
   late String descTipoPunto;
   late int plagaObjetivoId;
   late String codPlagaObjetivo;
   late String descPlagaObjetivo;
   late DateTime desde;
   late String estado;
   late String subEstado;
   late String comentario;
   late bool seleccionado;

    Ptoinspeccion({
        required this.puntoInspeccionId,
        required this.planoId,
        required this.codPuntoInspeccion,
        required this.zona,
        required this.sector,
        required this.codigoBarra,
        required this.tipoPuntoInspeccionId,
        required this.codTipoPuntoInspeccion,
        required this.descTipoPunto,
        required this.plagaObjetivoId,
        required this.codPlagaObjetivo,
        required this.descPlagaObjetivo,
        required this.desde,
        required this.estado,
        required this.subEstado,
        required this.comentario,
        required this.seleccionado,
    });

    factory Ptoinspeccion.fromJson(Map<String, dynamic> json) => Ptoinspeccion(
        puntoInspeccionId: json["puntoInspeccionId"]as int? ?? 0,
        planoId: json["planoId"]as int? ?? 0,
        codPuntoInspeccion: json["codPuntoInspeccion"]as String? ?? '',
        zona: json["zona"]as String? ?? '',
        sector: json["sector"]as String? ?? '',
        codigoBarra: json["codigoBarra"]as String? ?? '',
        tipoPuntoInspeccionId: json["tipoPuntoInspeccionId"]as int? ?? 0,
        codTipoPuntoInspeccion: json["codTipoPuntoInspeccion"]as String? ?? '',
        descTipoPunto: json["descTipoPunto"]as String? ?? '',
        plagaObjetivoId: json["plagaObjetivoId"]as int? ?? 0,
        codPlagaObjetivo: json["codPlagaObjetivo"]as String? ?? '',
        descPlagaObjetivo: json["descPlagaObjetivo"]as String? ?? '',
        desde: DateTime.parse(json["desde"]),
        estado: json["estado"]as String? ?? '',
        subEstado: json["subEstado"]as String? ?? '',
        comentario: json["comentario"]as String? ?? '',
        seleccionado: false,
    );

    Map<String, dynamic> toMap() => {
        "puntoInspeccionId": puntoInspeccionId,
        "planoId": planoId,
        "codPuntoInspeccion": codPuntoInspeccion,
        "zona": zona,
        "sector": sector,
        "codigoBarra": codigoBarra,
        "tipoPuntoInspeccionId": tipoPuntoInspeccionId,
        "codTipoPuntoInspeccion": codTipoPuntoInspeccion,
        "descTipoPunto": descTipoPunto,
        "plagaObjetivoId": plagaObjetivoId,
        "codPlagaObjetivo": codPlagaObjetivo,
        "descPlagaObjetivo": descPlagaObjetivo,
        "desde": desde.toIso8601String(),
        "estado": estado,
        "subEstado": subEstado,
        "comentario": comentario,
    };

    Ptoinspeccion.empty(){
      puntoInspeccionId = 0;
      planoId = 0;
      codPuntoInspeccion = '';
      zona = '';
      sector = '';
      codigoBarra = '';
      tipoPuntoInspeccionId = 0;
      codTipoPuntoInspeccion = '';
      descTipoPunto = '';
      plagaObjetivoId = 0;
      codPlagaObjetivo = '';
      descPlagaObjetivo = '';
      desde = DateTime.now();
      estado = '';
      subEstado = '';
      comentario = '';
      seleccionado = false;
    }
}
