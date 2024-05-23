import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/servicios/servicios_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/servicios/servicios_mobile.dart';


class ServiciosPage extends StatefulWidget {
  const ServiciosPage({super.key});

  @override
  State<ServiciosPage> createState() => _ServiciosPageState();
}

class _ServiciosPageState extends State<ServiciosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const ServiciosMobile();
          } else if (constraints.maxWidth > 900) {
            return const ServiciosDesktop();
          }
          return const ServiciosDesktop();
        },
      )),
    );
  }
}