import 'package:flutter/material.dart';

import 'planificacion_orden_desktop.dart';
import 'planificacion_orden_mobile.dart';


class OrdenPlan extends StatefulWidget {
  const OrdenPlan({super.key});

  @override
  State<OrdenPlan> createState() => _OrdenPlanState();
}

class _OrdenPlanState extends State<OrdenPlan> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const OrdenPlanificacionMobile();
          } else if (constraints.maxWidth > 900) {
            return const OrdenPlanificacionDesktop();
          }
          return const OrdenPlanificacionDesktop();
        },
      )),
    );
  }
}
