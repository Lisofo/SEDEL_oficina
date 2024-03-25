import 'package:flutter/material.dart';

import 'indis_desktop.dart';
import 'indis_mobile.dart';

class IndisponibilidadesPage extends StatefulWidget {
  const IndisponibilidadesPage({super.key});

  @override
  State<IndisponibilidadesPage> createState() => _IndisponibilidadesPageState();
}

class _IndisponibilidadesPageState extends State<IndisponibilidadesPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const IndisponibilidadesMobile();
          } else if (constraints.maxWidth > 900) {
            return const IndisponibilidadesDesktop();
          }
          return const IndisponibilidadesDesktop();
        },
      )),
    );
  }
}
