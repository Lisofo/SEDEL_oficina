import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/tareas/edit%20Tareas/edit_tareas_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


class EditTareas extends StatefulWidget {
  const EditTareas({super.key});

  @override
  State<EditTareas> createState() => _EditTareasState();
}

class _EditTareasState extends State<EditTareas> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditTareasMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditTareasDesktop();
          }
          return const EditTareasDesktop();
        },
      )),
    );
  }
}