import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/marcas/marcas_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


class MarcasPage extends StatefulWidget {
  const MarcasPage({super.key});

  @override
  State<MarcasPage> createState() => _MarcasPageState();
}

class _MarcasPageState extends State<MarcasPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const MarcasPageMobile();
          } else if (constraints.maxWidth > 900) {
            return const MarcasPageDesktop();
          }
          return const MarcasPageDesktop();
        },
      )),
    );
  }
}