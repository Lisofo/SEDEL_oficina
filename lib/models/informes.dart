import 'dart:convert';

List<Informes> informesFromJson(String str) => List<Informes>.from(json.decode(str).map((x) => Informes.fromJson(x)));

String informesToJson(List<Informes> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Informes {
  late String objetoArbol;
  late String nombre;
  late String rol;
  late String sistema;
  late List<InformeHijo> hijos;

  Informes({
    required this.objetoArbol,
    required this.nombre,
    required this.rol,
    required this.sistema,
    required this.hijos,
  });

  factory Informes.fromJson(Map<String, dynamic> json) => Informes(
    objetoArbol: json["objetoArbol"],
    nombre: json["nombre"],
    rol: json["rol"],
    sistema: json["sistema"],
    hijos: List<InformeHijo>.from(json["hijos"].map((x) => InformeHijo.fromJson(x))),
  );
  Map<String, dynamic> toJson() => {
    "objetoArbol": objetoArbol,
    "nombre": nombre,
    "rol": rol,
    "sistema": sistema,
    "hijos": List<dynamic>.from(hijos.map((x) => x.toJson())),
  };

  Informes.empty(){
    objetoArbol = '';
    nombre = '';
    rol = '';
    sistema = '';
    hijos = [];
  }
}

class InformeHijo {
  late String objetoArbol;
  late String? nombre;
  late List<HijoHijo> hijos;
  late int? informeId;
  late String? informe;
  late String? archivo;
  late dynamic salida;
  late String? formato;
  late dynamic indicadorEmpresa;
  late String? tipo;
  late String? codInforme;
  late String? claveImpresora;
  late dynamic almacenId;

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
  });

  factory InformeHijo.fromJson(Map<String, dynamic> json) => InformeHijo(
    objetoArbol: json["objetoArbol"],
    nombre: json["nombre"],
    hijos: List<HijoHijo>.from(json["hijos"].map((x) => HijoHijo.fromJson(x))),
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
  );

  Map<String, dynamic> toJson() => {
    "objetoArbol": objetoArbol,
    "nombre": nombre,
    "hijos": List<dynamic>.from(hijos.map((x) => x.toJson())),
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
  };

  InformeHijo.empty(){
    objetoArbol = '';
    nombre = '';
    hijos = [];
    informeId = 0;
    informe = '';
    archivo = '';
    salida = null;
    formato = '';
    indicadorEmpresa = null;
    tipo = '';
    codInforme = '';
    claveImpresora = '';
    almacenId = null;
  }
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
    this.grupo,
    this.subGrupo,
  });

  factory HijoHijo.fromJson(Map<String, dynamic> json) => HijoHijo(
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
    hijos: List<HijoHijo>.from(json["hijos"].map((x) => HijoHijo.fromJson(x))),
    grupo: json["grupo"],
    subGrupo: json["subGrupo"],
  );

  Map<String, dynamic> toJson() => {
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
    "hijos": List<dynamic>.from(hijos.map((x) => x.toJson())),
    "grupo": grupo,
    "subGrupo": subGrupo,
  };

  HijoHijo.empty(){
    objetoArbol = '';
    informeId = 0;
    informe = '';
    archivo = '';
    salida = [];
    formato = '';
    indicadorEmpresa = [];
    tipo = '';
    codInforme = '';
    claveImpresora = '';
    almacenId = 0;
    hijos = [];
    grupo = '';
    subGrupo = '';
  }
}
