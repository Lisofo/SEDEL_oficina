import 'package:flutter/material.dart';

import 'materiales_tipos_desktop.dart';
import 'materiales_tipos_mobile.dart';


class MaterialesTiposPuntosPage extends StatefulWidget {
  const MaterialesTiposPuntosPage({super.key});

  @override
  State<MaterialesTiposPuntosPage> createState() => _MaterialesTiposPuntosPageState();
}

class _MaterialesTiposPuntosPageState extends State<MaterialesTiposPuntosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const MaterialesTiposPuntosMobile();
          } else if (constraints.maxWidth > 900) {
            return const MaterialesTiposPuntosDesktop();
          }
            return const MaterialesTiposPuntosDesktop();
          },
        )
      ),
    );
  }
}