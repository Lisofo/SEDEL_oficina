import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/plagasObjetivo/plagas_objetivo_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';

class PlagasObjetivoPage extends StatefulWidget {
  const PlagasObjetivoPage({super.key});

  @override
  State<PlagasObjetivoPage> createState() => _PlagasObjetivoPageState();
}

class _PlagasObjetivoPageState extends State<PlagasObjetivoPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const PlagasObjetivoMobile();
          } else if (constraints.maxWidth > 900) {
            return const PlagasObjetivoDesktop();
          }
          return const PlagasObjetivoDesktop();
        },
      )),
    );
  }
}