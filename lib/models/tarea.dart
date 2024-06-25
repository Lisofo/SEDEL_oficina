import 'dart:convert';

List<Tarea> tareaFromMap(String str) =>
    List<Tarea>.from(json.decode(str).map((x) => Tarea.fromJson(x)));

String tareaToMap(List<Tarea> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Tarea {
  late int tareaId;
  late String codTarea;
  late String descripcion;
  late bool activoActividad;
  late bool activoMantenimiento;

  Tarea({
    required this.tareaId,
    required this.codTarea,
    required this.descripcion,
    this.activoActividad = false,
    this.activoMantenimiento = false,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
        tareaId: json["tareaId"],
        codTarea: json["codTarea"],
        descripcion: json["descripcion"],
        activoActividad: false,
        activoMantenimiento: false,
      );

  Map<String, dynamic> toMap() => {
        "tareaId": tareaId,
        "codTarea": codTarea,
        "descripcion": descripcion,
      };

  Tarea.empty() {
    tareaId = 0;
    codTarea = '';
    descripcion = '';
    activoActividad = false;
    activoMantenimiento = false;
  }

  @override
  String toString() {
    return descripcion;
  }
}
