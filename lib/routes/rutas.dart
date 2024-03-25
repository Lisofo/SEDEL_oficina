import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/Monitoreo%20Diario/monitoreo.dart';
import 'package:sedel_oficina_maqueta/pages/PyR/indisponibilidades/edit_indisponibilidad.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/clientes/clientes.dart';
import 'package:sedel_oficina_maqueta/pages/menu/menu.dart';

import '../pages/Monitoreo Diario/mapa.dart';
import '../pages/PyR/indisponibilidades/indisponibilidades.dart';
import '../pages/PyR/ordenesPlanificacion/orden/orden_trabajo.dart';
import '../pages/PyR/ordenesPlanificacion/orden_planificacion.dart';
import '../pages/PyR/planificador/planificador.dart';
import '../pages/login/login.dart';

Map<String, WidgetBuilder> getAppRoute() {
  return <String, WidgetBuilder>{
    '/': (context) => const Login(),
    'menu': (context) => const MenuPage(),
    'planificador': (context) => const PlanificadorPage(),
    'ordenesTrabajo': (context) => const OrdenesPlanificacion(),
    'ordenPlanificacion': (context) => const OrdenPlan(),
    // 'ordenRevision':(context) => OrdenRevision(),
    'indisponibilidades': (context) => const IndisponibilidadesPage(),
    'editIndisponibilidades':(context) => const EditIndisponibilidad(),
    'mapa': (context) => const MapaPage(),
    'ordenesMontitoreo': (context) => const MonitoreoPage(),
    'clientes':(context) => const ClientesPage(),
  };
}
