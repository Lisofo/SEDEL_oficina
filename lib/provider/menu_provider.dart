import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sedel_oficina_maqueta/services/menu_services.dart';

class MenuProvider with ChangeNotifier {
  List<dynamic> opciones = [];
  List<dynamic> opcionesRevision = [];

  MenuProvider();

  Future<List<dynamic>> cargarData(BuildContext context, String token) async {
  final menu = await MenuServices().getMenu(context, token);
  if (menu != null) {
    opciones = menu.rutas;
    return opciones;
  } else {
    return [];
  }
}

  Future<List<dynamic>> cargarMenuRevision(String codTipoOrden) async {
    final resp = await rootBundle.loadString('data/menu_revision.json');

    Map dataMap = json.decode(resp);
    opcionesRevision = dataMap['rutas'];
    return opcionesRevision
        .where((menu) => menu['tipoOrden'].toString().contains(codTipoOrden))
        .toList();
  }

  String _menu = '';
  String get menu => _menu;

  void setPage(String codPages) {
    _menu = codPages;
    notifyListeners();
  }
}

final menuProvider = MenuProvider();
