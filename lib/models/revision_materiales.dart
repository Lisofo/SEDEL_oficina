// To parse this JSON data, do
//
//     final revisionMateriales = revisionMaterialesFromMap(jsonString);

import 'dart:convert';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';

RevisionMaterial revisionMaterialesFromMap(String str) => RevisionMaterial.fromJson(json.decode(str));

String revisionMaterialesToMap(RevisionMaterial data) => json.encode(data.toMap());

class RevisionMaterial {
  late int otMaterialId;
  late int ordenTrabajoId;
  late int otRevisionId;
  late double cantidad;
  late String comentario;
  late String ubicacion;
  late String areaCobertura;
  late List<Plaga> plagas;
  late Materiales material;
  late Lote lote;
  late MetodoAplicacion metodoAplicacion;

  RevisionMaterial({
    required this.otMaterialId,
    required this.ordenTrabajoId,
    required this.otRevisionId,
    required this.cantidad,
    required this.comentario,
    required this.ubicacion,
    required this.areaCobertura,
    required this.plagas,
    required this.material,
    required this.lote,
    required this.metodoAplicacion,
  });

  factory RevisionMaterial.fromJson(Map<String, dynamic> json) =>
      RevisionMaterial(
        otMaterialId: json["otMaterialId"] as int? ?? 0,
        ordenTrabajoId: json["ordenTrabajoId"] as int? ?? 0,
        otRevisionId: json["otRevisionId"] as int? ?? 0,
        cantidad: json["cantidad"]?.toDouble() as double? ?? 0.0,
        comentario: json["comentario"] as String? ?? '',
        ubicacion: json["ubicacion"] as String? ?? '',
        areaCobertura: json["areaCobertura"] as String? ?? '',
        plagas: List<Plaga>.from(json["plagas"].map((x) => Plaga.fromJson(x))),
        material: Materiales.fromJson(json["material"]),
        lote: Lote.fromJson(json["lote"]),
        metodoAplicacion: MetodoAplicacion.fromJson(json["metodoAplicacion"]),
      );

  Map<String, dynamic> toMap() => {
        "otMaterialId": otMaterialId,
        "ordenTrabajoId": ordenTrabajoId,
        "otRevisionId": otRevisionId,
        "cantidad": cantidad,
        "comentario": comentario,
        "ubicacion": ubicacion,
        "areaCobertura": areaCobertura,
        "plagas": List<dynamic>.from(plagas.map((x) => x.toMap())),
        "material": material.toMap(),
        "lote": lote.toMap(),
        "metodoAplicacion": metodoAplicacion.toMap(),
      };

  RevisionMaterial.empty() {
    otMaterialId = 0;
    ordenTrabajoId = 0;
    otRevisionId = 0;
    cantidad = 0.0;
    comentario = '';
    ubicacion = '';
    areaCobertura = '';
    plagas = [];
    material = Materiales.empty();
    lote = Lote.empty();
    metodoAplicacion = MetodoAplicacion.empty();
  }

  @override
  String toString() {
    return material.descripcion;
  }
}

class Lote {
  late int materialLoteId;
  late String lote;
  late String estado;

  Lote({
    required this.materialLoteId,
    required this.lote,
    required this.estado,
  });

  factory Lote.fromJson(Map<String, dynamic> json) => Lote(
        materialLoteId: json["materialLoteId"] as int? ?? 0,
        lote: json["lote"] as String? ?? '',
        estado: json["estado"] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        "materialLoteId": materialLoteId,
        "lote": lote,
        'estado': estado,
      };

  Lote.empty() {
    materialLoteId = 0;
    lote = '';
    estado = '';
  }

  @override
  String toString() {
    return lote;
  }
}

class MetodoAplicacion {
  late int metodoAplicacionId;
  late String codMetodoAplicacion;
  late String descripcion;

  MetodoAplicacion({
    required this.metodoAplicacionId,
    required this.codMetodoAplicacion,
    required this.descripcion,
  });

  factory MetodoAplicacion.fromJson(Map<String, dynamic> json) =>
      MetodoAplicacion(
        metodoAplicacionId: json["metodoAplicacionId"] as int? ?? 0,
        codMetodoAplicacion: json["codMetodoAplicacion"] as String? ?? '',
        descripcion: json["descripcion"] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        "metodoAplicacionId": metodoAplicacionId,
        "codMetodoAplicacion": codMetodoAplicacion,
        "descripcion": descripcion,
      };

  MetodoAplicacion.empty() {
    metodoAplicacionId = 0;
    codMetodoAplicacion = '';
    descripcion = '';
  }

  @override
  String toString() {
    return descripcion;
  }
}

class MaterialDetalles {
  late int materialDetId;
  late String principioActivo;
  late double concentracion;

    MaterialDetalles({
        required this.materialDetId,
        required this.principioActivo,
        required this.concentracion,
    });

    factory MaterialDetalles.fromJson(Map<String, dynamic> json) => MaterialDetalles(
        materialDetId: json["materialDetId"] as int? ?? 0,
        principioActivo: json["principioActivo"] as String? ?? '',
        concentracion: json["concentracion"]?.toDouble() as double? ?? 0.0,
    );

    Map<String, dynamic> toMap() => {
        "materialDetId": materialDetId,
        "principioActivo": principioActivo,
        "concentracion": concentracion,
    };

    MaterialDetalles.empty(){
      materialDetId = 0;
      principioActivo = '';
      concentracion = 0.0;
    }
}

class MaterialHabilitacion {
   late int materialHabId;
   late String habilitacion;
   late String estado;

    MaterialHabilitacion({
        required this.materialHabId,
        required this.habilitacion,
        required this.estado,
    });

    factory MaterialHabilitacion.fromJson(Map<String, dynamic> json) => MaterialHabilitacion(
        materialHabId: json["materialHabId"] as int? ?? 0,
        habilitacion: json["habilitacion"]as String? ?? '',
        estado: json["estado"]as String? ?? '',
    );

    Map<String, dynamic> toMap() => {
        "materialHabId": materialHabId,
        "habilitacion": habilitacion,
        "estado": estado,
    };

  MaterialHabilitacion.empty(){
    materialHabId = 0;
    habilitacion = '';
    estado = '';
  }
}
