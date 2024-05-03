import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/metodosAplicacion/editMetodoAplicacion/edit_metodos_aplicacion_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/metodosAplicacion/editMetodoAplicacion/edit_metodos_aplicacion_mobile.dart';

class EditMetodosAplicacionPage extends StatefulWidget {
  const EditMetodosAplicacionPage({super.key});

  @override
  State<EditMetodosAplicacionPage> createState() => _EditMetodosAplicacionPageState();
}

class _EditMetodosAplicacionPageState extends State<EditMetodosAplicacionPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditMetodosAplicacionMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditMetodosAplicacionDesktop();
          }
          return const EditMetodosAplicacionDesktop();
        },
      )),
    );
  }
}