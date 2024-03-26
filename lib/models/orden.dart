// To parse this JSON data, do
//
//     final orden = ordenFromMap(jsonString);

import 'dart:convert';

import 'cliente.dart';
import 'servicios_ordenes.dart';
import 'tecnico.dart';

List<Orden> ordenFromMap(String str) =>
    List<Orden>.from(json.decode(str).map((x) => Orden.fromJson(x)));

String ordenToMap(List<Orden> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Orden {
  late int ordenTrabajoId;
  late DateTime fechaOrdenTrabajo;
  late DateTime fechaDesde;
  late DateTime fechaHasta;
  late String instrucciones;
  late String comentarios;
  late String estado;
  late TipoOrden tipoOrden;
  late Cliente cliente;
  late Tecnico tecnico;
  late List<ServicioOrdenes> servicio;
  late int otRevisionId;
  late int planoId;
  late String origen;
  late List<int> servicios;

  Orden({
    required this.ordenTrabajoId,
    required this.fechaOrdenTrabajo,
    required this.fechaDesde,
    required this.fechaHasta,
    required this.instrucciones,
    required this.comentarios,
    required this.estado,
    required this.tipoOrden,
    required this.cliente,
    required this.tecnico,
    required this.servicio,
    required this.otRevisionId,
    required this.planoId,
    required this.origen,
    required this.servicios,
  });

  factory Orden.fromJson(Map<String, dynamic> json) => Orden(
        ordenTrabajoId: json["ordenTrabajoId"],
        fechaOrdenTrabajo: DateTime.parse(json["fechaOrdenTrabajo"]),
        fechaDesde: DateTime.parse(json["fechaDesde"]),
        fechaHasta: DateTime.parse(json["fechaHasta"]),
        instrucciones: json["instrucciones"] as String? ?? '',
        comentarios: json["comentarios"] as String? ?? '',
        estado: json["estado"],
        tipoOrden: TipoOrden.fromJson(json["tipoOrden"]),
        cliente: Cliente.fromJson(json["cliente"]),
        tecnico: Tecnico.fromJson(json["tecnico"]),
        servicio: List<ServicioOrdenes>.from(json["servicios"].map((x) => ServicioOrdenes.fromJson(x))),
        otRevisionId: json["otRevisionId"] as int? ?? 0,
        planoId: json["planoId"] as int? ?? 0,
        servicios: [],
        origen: json["origen"],
      );

  Map<String, dynamic> toMap() => {
    "fechaOrdenTrabajo": _formatFechaOrdenTrabajo(fechaOrdenTrabajo),
    "fechaDesde": _formatDateAndTime(fechaDesde),
    "fechaHasta": _formatDateAndTime(fechaHasta),
    "instrucciones": instrucciones,
    "servicios": servicio.map((e) => e.servicioId).toList(),
    "tecnicoId": tecnico.tecnicoId,
    "clienteId": cliente.clienteId,
    "comentarios": comentarios,
    "tipoOrdenId": tipoOrden.tipoOrdenId
      // "ordenTrabajoId": ordenTrabajoId,
      // "fechaOrdenTrabajo": fechaOrdenTrabajo.toIso8601String(),
      // "fechaDesde": fechaDesde.toIso8601String(),
      // "fechaHasta": fechaHasta.toIso8601String(),
      // "instrucciones": instrucciones,
      // "comentarios": comentarios,
      // "estado": estado,
      // "tipoOrden": tipoOrden.toMap(),
      // "cliente": cliente.toMap(),
      // "tecnico": tecnico.toMap(),
      // "otRevisionId": otRevisionId,
      // "planoId": planoId,
      // "servicios": servicio.map((e) => e.servicioId).toList(),
    };

    String _formatDateAndTime(DateTime? date) {
      return '${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')} ${date?.hour.toString().padLeft(2, '0')}:${date?.minute.toString().padLeft(2, '0')}:${date?.second.toString().padLeft(2, '0')}';
    }
    String _formatFechaOrdenTrabajo(DateTime? date) {
      return '${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')}';
    }


  Orden.empty() {
    ordenTrabajoId = 0;
    fechaOrdenTrabajo = DateTime.now();
    fechaDesde = DateTime.now();
    fechaHasta = DateTime.now();
    instrucciones = '';
    comentarios = '';
    estado = 'PENDIENTE';
    tipoOrden = TipoOrden.empty();
    cliente = Cliente.empty();
    tecnico = Tecnico.empty();
    otRevisionId = 0;
    planoId = 0;
    servicio = [];
    servicios = [];
    origen = '';
  }
}

class TipoOrden {
  late int tipoOrdenId;
  late String codTipoOrden;
  late String descripcion;

  TipoOrden({
    required this.tipoOrdenId,
    required this.codTipoOrden,
    required this.descripcion,
  });

  factory TipoOrden.fromJson(Map<String, dynamic> json) => TipoOrden(
        tipoOrdenId: json["tipoOrdenId"],
        codTipoOrden: json["codTipoOrden"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toMap() => {
        "tipoOrdenId": tipoOrdenId,
        "codTipoOrden": codTipoOrden,
        "descripcion": descripcion,
      };

  TipoOrden.empty() {
    tipoOrdenId = 0;
    codTipoOrden = '';
    descripcion = '';
  }
}
