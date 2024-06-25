import 'package:flutter/material.dart';

import 'tareas_tipos_desktop.dart';
import 'tareas_tipos_mobile.dart';

class TareasTiposPuntosPage extends StatefulWidget {
  const TareasTiposPuntosPage({super.key});

  @override
  State<TareasTiposPuntosPage> createState() => _TareasTiposPuntosPageState();
}

class _TareasTiposPuntosPageState extends State<TareasTiposPuntosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const TareasTiposPuntosMobile();
          } else if (constraints.maxWidth > 900) {
            return const TareasTiposPuntosDesktop();
          }
            return const TareasTiposPuntosDesktop();
          },
        )
      ),
    );
  }
}