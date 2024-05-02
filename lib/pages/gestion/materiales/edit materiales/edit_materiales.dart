import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/edit%20materiales/edit_materiales_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/edit%20materiales/edit_materiales_mobile.dart';

class EditMaterialesPage extends StatefulWidget {
  const EditMaterialesPage({super.key});

  @override
  State<EditMaterialesPage> createState() => _EditMaterialesPageState();
}

class _EditMaterialesPageState extends State<EditMaterialesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditMaterialesPageMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditMaterialesPageDesktop();
          }
          return const EditMaterialesPageDesktop();
        },
      )),
    );
  }
}