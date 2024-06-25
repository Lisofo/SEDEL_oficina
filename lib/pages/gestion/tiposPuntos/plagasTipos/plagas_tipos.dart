import 'package:flutter/material.dart';

import 'plagas_tipos_desktop.dart';
import 'plagas_tipos_mobile.dart';


class PlagasTiposPuntosPage extends StatefulWidget {
  const PlagasTiposPuntosPage({super.key});

  @override
  State<PlagasTiposPuntosPage> createState() => _PlagasTiposPuntosPageState();
}

class _PlagasTiposPuntosPageState extends State<PlagasTiposPuntosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const PlagasTiposPuntosMobile();
          } else if (constraints.maxWidth > 900) {
            return const PlagasTiposPuntosDesktop();
          }
            return const PlagasTiposPuntosDesktop();
          },
        )
      ),
    );
  }
}