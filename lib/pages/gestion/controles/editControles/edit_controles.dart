import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/controles/editControles/edit_controles_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/controles/editControles/edit_controles_mobile.dart';


class EditControlesPage extends StatefulWidget {
  const EditControlesPage({super.key});

  @override
  State<EditControlesPage> createState() => _EditControlesPageState();
}

class _EditControlesPageState extends State<EditControlesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditControlesMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditControlesDesktop();
          }
          return const EditControlesDesktop();
        },
      )),
    );
  }
}