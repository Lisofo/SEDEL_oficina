// To parse this JSON data, do
//
//     final serviciosClientes = serviciosClientesFromMap(jsonString);

import 'dart:convert';

List<ServicioCliente> serviciosClientesFromMap(String str) =>
    List<ServicioCliente>.from(
        json.decode(str).map((x) => ServicioCliente.fromJson(x)));

String serviciosClientesToMap(List<ServicioCliente> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ServicioCliente {
  late int clienteServicioId;
  late int servicioId;
  late DateTime? desde;
  late DateTime? hasta;
  late String comentario;
  late String codServicio;
  late String servicio;

  ServicioCliente({
    required this.clienteServicioId,
    required this.servicioId,
    required this.desde,
    required this.hasta,
    required this.comentario,
    required this.codServicio,
    required this.servicio,
  });

  factory ServicioCliente.fromJson(Map<String, dynamic> json) =>
      ServicioCliente(
        clienteServicioId: json["clienteServicioId"] as int? ?? 0,
        servicioId: json["servicioId"] as int? ?? 0,
        desde: (json["desde"] == null || json['desde'] == 'null') ? null : DateTime.tryParse(json['desde']),
        hasta: (json["hasta"] == null || json['hasta'] == 'null') ? null : DateTime.tryParse(json['hasta']),
        comentario: json["comentario"] as String? ?? '',
        codServicio: json["codServicio"] as String? ?? '',
        servicio: json["servicio"] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        "clienteServicioId": clienteServicioId,
        "servicioId": servicioId,
        "desde": _formatDate(desde!),
        "hasta": hasta != null ? _formatDate(hasta!) : null,
        "comentario": comentario,
        "codServicio": codServicio,
        "servicio": servicio,
      };

  ServicioCliente.empty() {
    clienteServicioId = 0;
    servicioId = 0;
    desde = DateTime.now();
    hasta = DateTime.now();
    comentario = '';
    codServicio = '';
    servicio = '';
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
