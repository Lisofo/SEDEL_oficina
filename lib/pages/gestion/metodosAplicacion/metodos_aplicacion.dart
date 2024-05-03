import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/metodosAplicacion/metodos_aplicacion_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/metodosAplicacion/metodos_aplicacion_mobile.dart';

class MetodosAplicacionPage extends StatefulWidget {
  const MetodosAplicacionPage({super.key});

  @override
  State<MetodosAplicacionPage> createState() => _MetodosAplicacionPageState();
}

class _MetodosAplicacionPageState extends State<MetodosAplicacionPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const MetodosAplicacionMobile();
          } else if (constraints.maxWidth > 900) {
            return const MetodosAplicacionDesktop();
          }
          return const MetodosAplicacionDesktop();
        },
      )),
    );
  }
}