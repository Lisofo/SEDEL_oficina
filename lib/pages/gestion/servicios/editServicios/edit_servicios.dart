import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/servicios/editServicios/edit_servicios_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';

class EditServiciosPage extends StatefulWidget {
  const EditServiciosPage({super.key});

  @override
  State<EditServiciosPage> createState() => _EditServiciosPageState();
}

class _EditServiciosPageState extends State<EditServiciosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditServiciosMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditServiciosDesktop();
          }
          return const EditServiciosDesktop();
        },
      )),
    );
  }
}