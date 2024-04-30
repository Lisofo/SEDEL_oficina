import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/marcas/editmarcas/edit_marcas_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


class EditMarcasPage extends StatefulWidget {
  const EditMarcasPage({super.key});

  @override
  State<EditMarcasPage> createState() => _EditMarcasPageState();
}

class _EditMarcasPageState extends State<EditMarcasPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditMarcasMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditMarcasDesktop();
          }
          return const EditMarcasDesktop();
        },
      )),
    );
  }
}