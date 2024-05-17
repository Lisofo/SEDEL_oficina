import 'dart:convert';

List<Informe> informesFromJson(String str) => List<Informe>.from(json.decode(str).map((x) => Informe.fromJson(x)));

String informesToJson(List<Informe> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Informe {
  late String objetoArbol;
  late String nombre;
  late String rol;
  late String sistema;
  late List<InformeHijo> hijos;

  Informe({
    required this.objetoArbol,
    required this.nombre,
    required this.rol,
    required this.sistema,
    required this.hijos,
  });

  factory Informe.fromJson(Map<String, dynamic> json) => Informe(
    objetoArbol: json["objetoArbol"] as String? ?? '',
    nombre: json["nombre"] as String? ?? '',
    rol: json["rol"] as String? ?? '',
    sistema: json["sistema"] as String? ?? '',
    hijos: List<InformeHijo>.from(json["hijos"].map((x) => InformeHijo.fromJson(x))),
  );
  Map<String, dynamic> toJson() => {
    "objetoArbol": objetoArbol,
    "nombre": nombre,
    "rol": rol,
    "sistema": sistema,
    "hijos": List<dynamic>.from(hijos.map((x) => x.toJson())),
  };

  Informe.empty(){
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
    objetoArbol: json["objetoArbol"] as String? ?? '',
    nombre: json["nombre"] as String? ?? '',
    hijos: List<HijoHijo>.from(json["hijos"].map((x) => HijoHijo.fromJson(x))),
    informeId: json["informeId"] as int? ?? 0,
    informe: json["informe"] as String? ?? '',
    archivo: json["archivo"] as String? ?? '',
    salida: json["salida"] as int? ?? 0,
    formato: json["formato"] as String? ?? '',
    indicadorEmpresa: json["indicadorEmpresa"],
    tipo: json["tipo"] as String? ?? '',
    codInforme: json["codInforme"] as String? ?? '',
    claveImpresora: json["claveImpresora"] as String? ?? '',
    almacenId: json["almacenId"] as int? ?? 0,
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
    objetoArbol: json["objetoArbol"] as String? ?? '',
    informeId: json["informeId"] as int? ?? 0,
    informe: json["informe"] as String? ?? '',
    archivo: json["archivo"] as String? ?? '',
    salida: json["salida"],
    formato: json["formato"] as String? ?? '',
    indicadorEmpresa: json["indicadorEmpresa"],
    tipo: json["tipo"] as String? ?? '',
    codInforme: json["codInforme"] as String? ?? '',
    claveImpresora: json["claveImpresora"] as String? ?? '',
    almacenId: json["almacenId"] as int? ?? 0,
    hijos: List<HijoHijo>.from(json["hijos"].map((x) => HijoHijo.fromJson(x))),
    grupo: json["grupo"] as String? ?? '',
    subGrupo: json["subGrupo"] as String? ?? '',
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
