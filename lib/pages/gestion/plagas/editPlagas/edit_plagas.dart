import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/plagas/editPlagas/edit_plagas_mobile.dart';

import 'package:sedel_oficina_maqueta/pages/pages.dart';

class EditPlagasPage extends StatefulWidget {
  const EditPlagasPage({super.key});

  @override
  State<EditPlagasPage> createState() => _EditPlagasPageState();
}

class _EditPlagasPageState extends State<EditPlagasPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditPlagasMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditPlagasDesktop();
          }
          return const EditPlagasDesktop();
        },
      )),
    );
  }
}