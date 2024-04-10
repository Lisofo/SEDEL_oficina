// To parse this JSON data, do
//
//     final revisionOrden = revisionOrdenFromMap(jsonString);

import 'dart:convert';

List<RevisionOrden> revisionOrdenFromMap(String str) => List<RevisionOrden>.from(json.decode(str).map((x) => RevisionOrden.fromJson(x)));

String revisionOrdenToMap(List<RevisionOrden> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class RevisionOrden {
    late int otRevisionId;
    late int ordenTrabajoId;
    late int ordinal;
    late int usuarioId;
    late String login;
    late String nombre;
    late String apellido;
    late String comentario;
    late String tipoRevision;

    RevisionOrden({
        required this.otRevisionId,
        required this.ordenTrabajoId,
        required this.ordinal,
        required this.usuarioId,
        required this.login,
        required this.nombre,
        required this.apellido,
        required this.comentario,
        required this.tipoRevision
    });

    factory RevisionOrden.fromJson(Map<String, dynamic> json) => RevisionOrden(
        otRevisionId: json["otRevisionId"] as int? ?? 0,
        ordenTrabajoId: json["ordenTrabajoId"] as int? ?? 0,
        ordinal: json["ordinal"] as int? ?? 0,
        usuarioId: json["usuarioId"] as int? ?? 0,
        login: json["login"] as String? ?? '',
        nombre: json["nombre"] as String? ?? '',
        apellido: json["apellido"] as String? ?? '',
        comentario: json["comentario"] as String? ?? '',
        tipoRevision: json['tipoRevision'] as String? ?? '',
    );

    Map<String, dynamic> toMap() => {
        "otRevisionId": otRevisionId,
        "ordenTrabajoId": ordenTrabajoId,
        "ordinal": ordinal,
        "usuarioId": usuarioId,
        "login": login,
        "nombre": nombre,
        "apellido": apellido,
        "comentario": comentario,
    };

    RevisionOrden.empty(){
      otRevisionId = 0;
      ordenTrabajoId = 0;
      ordinal = 0;
      usuarioId = 0;
      login = '';
      nombre = '';
      apellido = '';
      comentario = '';
      tipoRevision = '';
    }
}
