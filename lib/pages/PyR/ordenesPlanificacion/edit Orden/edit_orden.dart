import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/PyR/ordenesPlanificacion/edit%20Orden/edit_orden_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


class EditOrden extends StatefulWidget {
  const EditOrden({super.key});

  @override
  State<EditOrden> createState() => _EditOrdenState();
}

class _EditOrdenState extends State<EditOrden> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditOrdenMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditOrdenDesktop();
          }
          return const EditOrdenDesktop();
        },
      )),
    );
  }
}
