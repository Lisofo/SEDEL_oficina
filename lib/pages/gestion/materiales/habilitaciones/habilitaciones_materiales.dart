import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/habilitaciones/habilitaciones_materiales_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/habilitaciones/habilitaciones_materiales_mobile.dart';

class HabilitacionesMaterial extends StatefulWidget {
  const HabilitacionesMaterial({super.key});

  @override
  State<HabilitacionesMaterial> createState() => _HabilitacionesMaterialState();
}

class _HabilitacionesMaterialState extends State<HabilitacionesMaterial> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const HabilitacionesMaterialMobile();
          } else if (constraints.maxWidth > 900) {
            return const HabilitacionesMaterialDesktop();
          }
          return const HabilitacionesMaterialDesktop();
        },
      )),
    );
  }
}