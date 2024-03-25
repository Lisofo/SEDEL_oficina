// To parse this JSON data, do
//
//     final marca = marcaFromMap(jsonString);

import 'dart:convert';

List<Marca> marcaFromMap(String str) => List<Marca>.from(json.decode(str).map((x) => Marca.fromJson(x)));

String marcaToMap(List<Marca> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Marca {
    late int marcaId;
    late DateTime desde;
    late DateTime? hasta;
    late int tecnicoId;
    late String codTecnico;
    late String nombreTecnico;
    late int? ubicacionId;
    late String? ubicacion;
    late int? ubicacionIdHasta;
    late String? ubicacionHasta;
    late String? modo;

    Marca({
        required this.marcaId,
        required this.desde,
        required this.hasta,
        required this.tecnicoId,
        required this.codTecnico,
        required this.nombreTecnico,
        required this.ubicacionId,
        required this.ubicacion,
        required this.ubicacionIdHasta,
        required this.ubicacionHasta,
        required this.modo
    });

    factory Marca.fromJson(Map<String, dynamic> json) => Marca(
        marcaId: json["marcaId"] as int? ?? 0,
        desde: DateTime.parse(json["desde"]),
        hasta: json["hasta"] == null ? null : DateTime.parse(json["hasta"]),
        tecnicoId: json["tecnicoId"] as int? ?? 0,
        codTecnico: json["codTecnico"] as String? ?? '',
        nombreTecnico: json["nombreTecnico"] as String? ?? '',
        ubicacionId: json["ubicacionId"] as int? ?? 0,
        ubicacion: json["ubicacion"] as String? ?? '',
        ubicacionIdHasta: json["ubicacionIdHasta"] as int? ?? 0,
        ubicacionHasta: json["ubicacionHasta"] as String? ?? '',
        modo: json["modo"] as String? ?? '',
    );

    Map<String, dynamic> toMap() => {
        "marcaId": marcaId,
        "desde": desde.toIso8601String(),
        "hasta": hasta?.toIso8601String(),
        "tecnicoId": tecnicoId,
        'modo': 'A'
    };

    Marca.empty(){
      marcaId = 0;
      desde = DateTime.now();
      hasta = DateTime.now();
      tecnicoId = 0;
      codTecnico = '';
      nombreTecnico = '';
      ubicacionId = 0;
      ubicacion = '';
      ubicacionIdHasta = 0;
      ubicacionHasta = '';
    }
}
