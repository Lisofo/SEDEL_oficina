import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/materiales/materiales_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/materiales/materiales/materiales_mobile.dart';


class MaterialesPage extends StatefulWidget {
  const MaterialesPage({super.key});

  @override
  State<MaterialesPage> createState() => _MaterialesPageState();
}

class _MaterialesPageState extends State<MaterialesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const MaterialesPageMobile();
          } else if (constraints.maxWidth > 900) {
            return const MaterialesPageDesktop();
          }
          return const MaterialesPageDesktop();
        },
      )),
    );
  }
}