import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/controles/controles_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


class ControlesPage extends StatefulWidget {
  const ControlesPage({super.key});

  @override
  State<ControlesPage> createState() => _ControlesPageState();
}

class _ControlesPageState extends State<ControlesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const ControlesMobile();
          } else if (constraints.maxWidth > 900) {
            return const ControlesDesktop();
          }
          return const ControlesDesktop();
        },
      )),
    );
  }
}