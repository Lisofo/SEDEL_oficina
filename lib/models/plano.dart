// To parse this JSON data, do
//
//     final plano = planoFromMap(jsonString);

import 'dart:convert';

List<Plano> planoFromMap(String str) => List<Plano>.from(json.decode(str).map((x) => Plano.fromJson(x)));

String planoToMap(List<Plano> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Plano {
   late int planoId;
   late int clienteId;
   late String codPlano;
   late String descripcion;
   late String estado;
   late DateTime desde;
   late DateTime? hasta;

    Plano({
        required this.planoId,
        required this.clienteId,
        required this.codPlano,
        required this.descripcion,
        required this.desde,
        required this.hasta,
        required this.estado,
    });

    factory Plano.fromJson(Map<String, dynamic> json) => Plano(
        planoId: json["planoId"]as int? ?? 0,
        clienteId: json["clienteId"]as int? ?? 0,
        codPlano: json["codPlano"]as String? ?? '',
        descripcion: json["descripcion"]as String? ?? '',
        desde: DateTime.parse(json["desde"]),
        hasta: (json["hasta"] == null || json['hasta'] == 'null') ? null : DateTime.tryParse(json['hasta']),
        estado: json["estado"]as String? ?? '',
    );

    Map<String, dynamic> toMap() => {
        "planoId": planoId,
        "clienteId": clienteId,
        "codPlano": codPlano,
        "descripcion": descripcion,
        "desde": desde.toIso8601String(),
        "hasta": hasta?.toIso8601String(),
        "estado": estado
    };

    Plano.empty(){
      planoId = 0;
      clienteId = 0;
      codPlano = '';
      descripcion = '';
      estado = '';
      desde = DateTime.now();
      hasta = DateTime.now();
    }
}
