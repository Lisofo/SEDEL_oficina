import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/tecnicos/edit%20Tecnicos/edit_tecnicos_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


class EditTecnicos extends StatefulWidget {
  const EditTecnicos({super.key});

  @override
  State<EditTecnicos> createState() => _EditTecnicosState();
}

class _EditTecnicosState extends State<EditTecnicos> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditTecnicosMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditTecnicosDesktop();
          }
          return const EditTecnicosDesktop();
        },
      )),
    );
  }
}