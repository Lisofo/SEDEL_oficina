import 'dart:convert';
import 'cliente.dart';
import 'tecnico.dart';

List<Indisponibilidad> indisponibilidadFromMap(String str) =>
    List<Indisponibilidad>.from(
        json.decode(str).map((x) => Indisponibilidad.fromJson(x)));

String indisponibilidadToMap(List<Indisponibilidad> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Indisponibilidad {
  late int indisponibilidadId;
  late DateTime desde;
  late DateTime hasta;
  late String comentario;
  late TipoIndisponibilidad tipoIndisponibilidad;
  late Cliente? cliente;
  late Tecnico? tecnico;
  late int tipoIndisponibilidadId;
  late int clienteId;
  late int tecnicoId;

  Indisponibilidad({
    required this.indisponibilidadId,
    required this.desde,
    required this.hasta,
    required this.comentario,
    required this.tipoIndisponibilidad,
    required this.tipoIndisponibilidadId,
    required this.clienteId,
    required this.tecnicoId,
    this.cliente,
    this.tecnico,
  });

  factory Indisponibilidad.fromJson(Map<String, dynamic> json) =>
      Indisponibilidad(
        indisponibilidadId: json["indisponibilidadId"],
        desde: DateTime.parse(json["desde"]),
        hasta: DateTime.parse(json["hasta"]),
        comentario: json["comentario"],
        tipoIndisponibilidad:
            TipoIndisponibilidad.fromJson(json["tipoIndisponibilidad"]),
        cliente: json["cliente"] == null
            ? Cliente.empty()
            : Cliente.fromJson(json["cliente"]),
        tecnico: json["tecnico"] == null
            ? Tecnico.empty()
            : Tecnico.fromJson(json["tecnico"]),
        tipoIndisponibilidadId: 0,
        clienteId: 0,
        tecnicoId: 0,
      );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> commonFields = {
      "indisponibilidadId": indisponibilidadId,
      "desde": _formatDateAndTime(desde),
      "hasta": _formatDateAndTime(hasta),
      "comentario": comentario,
      "tipoIndisponibilidadId": tipoIndisponibilidadId,
    };

    if (tipoIndisponibilidadId == 2) {
      commonFields["clienteId"] = clienteId == 0 ? null : clienteId;
    } else if (tipoIndisponibilidadId == 3) {
      commonFields["tecnicoId"] = tecnicoId == 0 ? null : tecnicoId;
    }

    return commonFields;
  }

  Indisponibilidad.empty() {
    indisponibilidadId = 0;
    tecnicoId = 0;
    clienteId = 0;
    desde = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    hasta = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
    comentario = '';
    tipoIndisponibilidad = TipoIndisponibilidad.empty();
    cliente = Cliente.empty();
    tecnico = Tecnico.empty();
  }
}

String _formatDateAndTime(DateTime? date) {
  return '${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')}T${date?.hour.toString().padLeft(2, '0')}:${date?.minute.toString().padLeft(2, '0')}:${date?.second.toString().padLeft(2, '0')}';
}

class TipoIndisponibilidad {
  late int tipoIndisponibilidadId;
  late String codTipoIndisponibilidad;
  late String descripcion;

  TipoIndisponibilidad({
    required this.tipoIndisponibilidadId,
    required this.codTipoIndisponibilidad,
    required this.descripcion,
  });

  factory TipoIndisponibilidad.fromJson(Map<String, dynamic> json) =>
      TipoIndisponibilidad(
        tipoIndisponibilidadId: json["tipoIndisponibilidadId"],
        codTipoIndisponibilidad: json["codTipoIndisponibilidad"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toMap() => {
        "tipoIndisponibilidadId": tipoIndisponibilidadId,
        "codTipoIndisponibilidad": codTipoIndisponibilidad,
        "descripcion": descripcion,
      };

  TipoIndisponibilidad.empty() {
    tipoIndisponibilidadId = 0;
    codTipoIndisponibilidad = '';
    descripcion = '';
  }
}
