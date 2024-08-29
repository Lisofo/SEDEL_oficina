// To parse this JSON data, do
//
//     final frecuencia = frecuenciaFromJson(jsonString);

import 'dart:convert';

List<Frecuencia> frecuenciaFromJson(String str) => List<Frecuencia>.from(json.decode(str).map((x) => Frecuencia.fromJson(x)));

String frecuenciaToJson(List<Frecuencia> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Frecuencia {
  late int clienteServFrecuenciaId;
  late int clienteServicioId;
  late int clienteId;
  late int servicioId;
  late String codServicio;
  late String servicio;
  late int frecuenciaId;
  late String codFrecuencia;
  late String frecuencia;
  late DateTime? desde;
  late DateTime? hasta;
  late String repetir;
  late bool? d;
  late bool? l;
  late bool? ma;
  late bool? mi;
  late bool? j;
  late bool? v;
  late bool? s;
  late int? meses;
  late String? comentario;

  Frecuencia({
    required this.clienteServFrecuenciaId,
    required this.clienteServicioId,
    required this.clienteId,
    required this.servicioId,
    required this.codServicio,
    required this.servicio,
    required this.frecuenciaId,
    required this.codFrecuencia,
    required this.frecuencia,
    required this.desde,
    required this.hasta,
    required this.repetir,
    required this.d,
    required this.l,
    required this.ma,
    required this.mi,
    required this.j,
    required this.v,
    required this.s,
    required this.meses,
    required this.comentario,
  });

  factory Frecuencia.fromJson(Map<String, dynamic> json) => Frecuencia(
    clienteServFrecuenciaId: json["clienteServFrecuenciaId"] as int? ?? 0,
    clienteServicioId: json["clienteServicioId"] as int? ?? 0,
    clienteId: json["clienteId"] as int? ?? 0,
    servicioId: json["servicioId"] as int? ?? 0,
    codServicio: json["codServicio"] as String? ?? '',
    servicio: json["servicio"] as String? ?? '',
    frecuenciaId: json["frecuenciaId"] as int? ?? 0,
    codFrecuencia: json["codFrecuencia"] as String? ?? '',
    frecuencia: json["frecuencia"] as String? ?? '',
    desde: DateTime.parse(json["desde"]),
    hasta: DateTime.parse(json["hasta"]),
    repetir: json["repetir"] as String? ?? '',
    d: json["D"] as bool? ?? false,
    l: json["L"] as bool? ?? false,
    ma: json["MA"] as bool? ?? false,
    mi: json["MI"] as bool? ?? false,
    j: json["J"] as bool? ?? false,
    v: json["V"] as bool? ?? false,
    s: json["S"] as bool? ?? false,
    meses: json["meses"] as int? ?? 0,
    comentario: json["comentario"] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    "frecuenciaId": frecuenciaId,
    "codFrecuencia": codFrecuencia,
    "frecuencia": frecuencia,
    "desde": _formatDateAndTime(desde),
    "hasta": _formatDateAndTime(hasta),
    "repetir": repetir,
    "D": devolucion(d),
    "L": devolucion(l),
    "MA": devolucion(ma),
    "MI": devolucion(mi),
    "J": devolucion(j),
    "V": devolucion(v),
    "S": devolucion(s),
    "meses": meses,
    "comentario": comentario,
  };

  Frecuencia.empty(){
    clienteServFrecuenciaId = 0;
    clienteServicioId = 0;
    clienteId = 0;
    servicioId = 0;
    codServicio = '';
    servicio = '';
    frecuenciaId = 0;
    codFrecuencia = '';
    frecuencia = '';
    desde = null;
    hasta = null;
    repetir = '';
    d = false;
    l = false;
    ma = false;
    mi = false;
    j = false;
    v = false;
    s = false;
    meses = 0;
    comentario = '';
  }

  int devolucion (bool? fecha) {
    late int devuelto = 0;
    if(fecha == true){
      devuelto = 1;
    } else {
      devuelto = 0;
    }
    return devuelto;
  }

  String _formatDateAndTime(DateTime? date) {
    return '${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')}';
  }

}

class SubFrecuencia {
  late int frecuenciaId;
  late String codFrecuencia;
  late String descripcion;

  SubFrecuencia({
    required this.frecuenciaId,
    required this.codFrecuencia,
    required this.descripcion
  });

  SubFrecuencia.empty(){
    frecuenciaId = 0;
    codFrecuencia = '';
    descripcion = '';
  }
}

class FechasFrecuencias {
  late String fecha;
  late bool activo;

  FechasFrecuencias({
    required this.fecha,
    required this.activo,
  });

  FechasFrecuencias.empty(){
    fecha = '';
    activo = false;
  }
}