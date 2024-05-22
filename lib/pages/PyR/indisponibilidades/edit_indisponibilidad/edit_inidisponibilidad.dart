import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/PyR/indisponibilidades/edit_indisponibilidad/edit_indisponibilidad_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/PyR/indisponibilidades/edit_indisponibilidad/edit_indisponibilidad_mobile.dart';



class EditIndisponibilidades extends StatefulWidget {
  const EditIndisponibilidades({super.key});

  @override
  State<EditIndisponibilidades> createState() => _EditIndisponibilidadesState();
}

class _EditIndisponibilidadesState extends State<EditIndisponibilidades> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditIndisponibilidadMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditIndisponibilidadDesktop();
          }
          return const EditIndisponibilidadDesktop();
        },
      )),
    );
  }
}
