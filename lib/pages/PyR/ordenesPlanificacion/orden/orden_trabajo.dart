import 'package:flutter/material.dart';

import 'orden_plan_desktop.dart';
import 'orden_plan_mobile.dart';

class OrdenesPlanificacion extends StatefulWidget {
  const OrdenesPlanificacion({super.key});

  @override
  State<OrdenesPlanificacion> createState() => _OrdenesPlanificacionState();
}

class _OrdenesPlanificacionState extends State<OrdenesPlanificacion> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const OrdenPlanMobile();
          } else if (constraints.maxWidth > 900) {
            return const OrdenPlanDesktop();
          }
          return const OrdenPlanDesktop();
        },
      )),
    );
  }
}
