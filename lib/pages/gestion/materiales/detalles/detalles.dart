import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/detalles/detalles_materiales_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/detalles/detalles_mobile.dart';

class DetallesMateriales extends StatefulWidget {
  const DetallesMateriales({super.key});

  @override
  State<DetallesMateriales> createState() => _DetallesMaterialesState();
}

class _DetallesMaterialesState extends State<DetallesMateriales> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const DetallesMaterialesMobile();
          } else if (constraints.maxWidth > 900) {
            return const DetallesMaterialesDesktop();
          }
          return const DetallesMaterialesDesktop();
        },
      )),
    );
  }
}