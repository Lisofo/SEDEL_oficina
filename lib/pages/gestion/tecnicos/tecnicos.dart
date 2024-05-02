import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/tecnicos/tecnicos_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


class TecnicosPage extends StatefulWidget {
  const TecnicosPage({super.key});

  @override
  State<TecnicosPage> createState() => _TecnicosPageState();
}

class _TecnicosPageState extends State<TecnicosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const TecnicosPageMobile();
          } else if (constraints.maxWidth > 900) {
            return const TecnicosPageDesktop();
          }
          return const TecnicosPageDesktop();
        },
      )),
    );
  }
}