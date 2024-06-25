// To parse this JSON data, do
//
//     final materialesTipoPto = materialesTipoPtoFromJson(jsonString);

import 'dart:convert';

List<MaterialTipoPto> materialesTipoPtoFromJson(String str) => List<MaterialTipoPto>.from(json.decode(str).map((x) => MaterialTipoPto.fromJson(x)));

String materialesTipoPtoToJson(List<MaterialTipoPto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MaterialTipoPto {
  late int configTpiMaterialId;
  late int tipoPuntoInspeccionId;
  late int materialId;
  late String codMaterial;
  late String descripcion;
  late String unidad;
  late String dosis;

  MaterialTipoPto({
    required this.configTpiMaterialId,
    required this.tipoPuntoInspeccionId,
    required this.materialId,
    required this.codMaterial,
    required this.descripcion,
    required this.unidad,
    required this.dosis,
  });

  factory MaterialTipoPto.fromJson(Map<String, dynamic> json) => MaterialTipoPto(
    configTpiMaterialId: json["configTPIMaterialId"],
    tipoPuntoInspeccionId: json["tipoPuntoInspeccionId"],
    materialId: json["materialId"],
    codMaterial: json["codMaterial"],
    descripcion: json["descripcion"],
    unidad: json["unidad"],
    dosis: json["dosis"],
  );

  Map<String, dynamic> toJson() => {
    "configTPIMaterialId": configTpiMaterialId,
    "tipoPuntoInspeccionId": tipoPuntoInspeccionId,
    "materialId": materialId,
    "codMaterial": codMaterial,
    "descripcion": descripcion,
    "unidad": unidad,
    "dosis": dosis,
  };

  MaterialTipoPto.empty(){
    configTpiMaterialId = 0;
    tipoPuntoInspeccionId = 0;
    materialId = 0;
    codMaterial = '';
    descripcion = '';
    unidad = '';
    dosis = '';
  }
}
