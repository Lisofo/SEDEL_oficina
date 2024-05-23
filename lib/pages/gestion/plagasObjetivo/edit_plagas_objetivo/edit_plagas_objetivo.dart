import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/plagasObjetivo/edit_plagas_objetivo/edit_plagas_objetivo_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/plagasObjetivo/edit_plagas_objetivo/edit_plagas_objetivo_mobile.dart';

class EditPlagasObjetivoPage extends StatefulWidget {
  const EditPlagasObjetivoPage({super.key});

  @override
  State<EditPlagasObjetivoPage> createState() => _EditPlagasObjetivoPageState();
}

class _EditPlagasObjetivoPageState extends State<EditPlagasObjetivoPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditPlagasObjetivoMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditPlagasObjetivoDesktop();
          }
          return const EditPlagasObjetivoDesktop();
        },
      )),
    );
  }
}