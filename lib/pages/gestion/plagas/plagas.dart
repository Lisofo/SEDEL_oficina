import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/plagas/plagas_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/plagas/plagas_mobile.dart';

class PlagasPage extends StatefulWidget {
  const PlagasPage({super.key});

  @override
  State<PlagasPage> createState() => _PlagasPageState();
}

class _PlagasPageState extends State<PlagasPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const PlagasMobile();
          } else if (constraints.maxWidth > 900) {
            return const PlagasDessktop();
          }
          return const PlagasDessktop();
        },
      )),
    );
  }
}