import 'dart:convert';

List<DepartamentoClientes> departamentoClientesFromMap(String str) =>
    List<DepartamentoClientes>.from(
        json.decode(str).map((x) => DepartamentoClientes.fromJson(x)));

String departamentoClientesToMap(List<DepartamentoClientes> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class DepartamentoClientes {
  late int departamentoId;
  late String codDepartamento;
  late String descripcion;
  late int zonaId;

  DepartamentoClientes({
    required this.departamentoId,
    required this.codDepartamento,
    required this.descripcion,
    required this.zonaId,
  });

  factory DepartamentoClientes.fromJson(Map<String, dynamic> json) =>
      DepartamentoClientes(
        departamentoId: json["departamentoId"] as int? ?? 0,
        codDepartamento: json["codDepartamento"] as String? ?? '',
        descripcion: json["descripcion"] as String? ?? '',
        zonaId: json["zonaId"] as int? ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "departamentoId": departamentoId,
        "codDepartamento": codDepartamento,
        "descripcion": descripcion,
        "zonaId": zonaId,
      };

  DepartamentoClientes.empty() {
    departamentoId = 0;
    codDepartamento = '';
    descripcion = '';
    zonaId = 0;
  }
}
