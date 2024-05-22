// To parse this JSON data, do
//
//     final informe = informeFromMap(jsonString);

import 'dart:convert';

List<Informe> informeFromMap(String str) => List<Informe>.from(json.decode(str).map((x) => Informe.fromJson(x)));

String informeToMap(List<Informe> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Informe {
    String objetoArbol;
    String nombre;
    String rol;
    String sistema;
    List<InformeHijo> hijos;

    Informe({
        required this.objetoArbol,
        required this.nombre,
        required this.rol,
        required this.sistema,
        required this.hijos,
    });

    factory Informe.fromJson(Map<String, dynamic> json) => Informe(
        objetoArbol: json["objetoArbol"],
        nombre: json["nombre"],
        rol: json["rol"],
        sistema: json["sistema"],
        hijos: List<InformeHijo>.from(json["hijos"].map((x) => InformeHijo.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "objetoArbol": objetoArbol,
        "nombre": nombre,
        "rol": rol,
        "sistema": sistema,
        "hijos": List<dynamic>.from(hijos.map((x) => x.toMap())),
    };
}

class InformeHijo {
    String objetoArbol;
    String? nombre;
    List<HijoHijo> hijos;
    int? informeId;
    String? informe;
    String? archivo;
    dynamic salida;
    String? formato;
    dynamic indicadorEmpresa;
    String? tipo;
    String? codInforme;
    String? claveImpresora;
    dynamic almacenId;
    List<TiposImpresion>? tiposImpresion;

    InformeHijo({
        required this.objetoArbol,
        this.nombre,
        required this.hijos,
        this.informeId,
        this.informe,
        this.archivo,
        this.salida,
        this.formato,
        this.indicadorEmpresa,
        this.tipo,
        this.codInforme,
        this.claveImpresora,
        this.almacenId,
        this.tiposImpresion,
    });

    factory InformeHijo.fromMap(Map<String, dynamic> json) => InformeHijo(
        objetoArbol: json["objetoArbol"],
        nombre: json["nombre"],
        hijos: List<HijoHijo>.from(json["hijos"].map((x) => HijoHijo.fromMap(x))),
        informeId: json["informeId"],
        informe: json["informe"],
        archivo: json["archivo"],
        salida: json["salida"],
        formato: json["formato"],
        indicadorEmpresa: json["indicadorEmpresa"],
        tipo: json["tipo"],
        codInforme: json["codInforme"],
        claveImpresora: json["claveImpresora"],
        almacenId: json["almacenId"],
        tiposImpresion: json["tiposImpresion"] == null ? [] : List<TiposImpresion>.from(json["tiposImpresion"]!.map((x) => TiposImpresion.fromMap(x))),
    );

    Map<String, dynamic> toMap() => {
        "objetoArbol": objetoArbol,
        "nombre": nombre,
        "hijos": List<dynamic>.from(hijos.map((x) => x.toMap())),
        "informeId": informeId,
        "informe": informe,
        "archivo": archivo,
        "salida": salida,
        "formato": formato,
        "indicadorEmpresa": indicadorEmpresa,
        "tipo": tipo,
        "codInforme": codInforme,
        "claveImpresora": claveImpresora,
        "almacenId": almacenId,
        "tiposImpresion": tiposImpresion == null ? [] : List<dynamic>.from(tiposImpresion!.map((x) => x.toMap())),
    };
}

class HijoHijo {
  late String objetoArbol;
  late int informeId;
  late String informe;
  late String archivo;
  late dynamic salida;
  late String formato;
  late dynamic indicadorEmpresa;
  late String tipo;
  late String codInforme;
  late String claveImpresora;
  late dynamic almacenId;
  late List<HijoHijo> hijos;
  late List<TiposImpresion> tiposImpresion;
  late String? grupo;
  late String? subGrupo;

  HijoHijo({
    required this.objetoArbol,
    required this.informeId,
    required this.informe,
    required this.archivo,
    required this.salida,
    required this.formato,
    required this.indicadorEmpresa,
    required this.tipo,
    required this.codInforme,
    required this.claveImpresora,
    required this.almacenId,
    required this.hijos,
    required this.tiposImpresion,
    this.grupo,
    this.subGrupo,
  });

  factory HijoHijo.fromMap(Map<String, dynamic> json) => HijoHijo(
    objetoArbol: json["objetoArbol"],
    informeId: json["informeId"],
    informe: json["informe"],
    archivo: json["archivo"],
    salida: json["salida"],
    formato: json["formato"],
    indicadorEmpresa: json["indicadorEmpresa"],
    tipo: json["tipo"],
    codInforme: json["codInforme"],
    claveImpresora: json["claveImpresora"],
    almacenId: json["almacenId"],
    hijos: List<HijoHijo>.from(json["hijos"].map((x) => HijoHijo.fromMap(x))),
    tiposImpresion: List<TiposImpresion>.from(json["tiposImpresion"].map((x) => TiposImpresion.fromMap(x))),
    grupo: json["grupo"],
    subGrupo: json["subGrupo"],
  );

  Map<String, dynamic> toMap() => {
    "objetoArbol": objetoArbol,
    "informeId": informeId,
    "informe": informe,
    "archivo": archivo,
    "salida": salida,
    "formato": formato,
    "indicadorEmpresa": indicadorEmpresa,
    "tipo": tipo,
    "codInforme": codInforme,
    "claveImpresora": claveImpresora,
    "almacenId": almacenId,
    "hijos": List<dynamic>.from(hijos.map((x) => x.toMap())),
    "tiposImpresion": List<dynamic>.from(tiposImpresion.map((x) => x.toMap())),
    "grupo": grupo,
    "subGrupo": subGrupo,
  };

  HijoHijo.empty(){
    objetoArbol = '';
    informeId = 0;
    informe = '';
    archivo = '';
    salida = null;
    formato = '';
    indicadorEmpresa = null;
    tipo = '';
    codInforme = '';
    claveImpresora = '';
    almacenId = 0;
    hijos = [];
    tiposImpresion = [];
    grupo = '';
    subGrupo = '';
  }
}

class TiposImpresion {
  late String tipo;
  late String descripcion;

  TiposImpresion({
    required this.tipo,
    required this.descripcion,
  });

  factory TiposImpresion.fromMap(Map<String, dynamic> json) => TiposImpresion(
    tipo: json["tipo"] as String? ?? '',
    descripcion: json["descripcion"] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    "tipo": tipo,
    "descripcion": descripcion,
  };

  TiposImpresion.empty(){
    tipo = '';
    descripcion = '';
  }
}
