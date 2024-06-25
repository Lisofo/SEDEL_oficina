import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/tiposPuntos/tipos_puntos_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/tiposPuntos/tipos_puntos_mobile.dart';


class TiposPuntosPage extends StatefulWidget {
  const TiposPuntosPage({super.key});

  @override
  State<TiposPuntosPage> createState() => _TiposPuntosPageState();
}

class _TiposPuntosPageState extends State<TiposPuntosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const TiposPuntosMobile();
          } else if (constraints.maxWidth > 900) {
            return const TiposPuntosDesktop();
          }
          return const TiposPuntosDesktop();
        },
      )),
    );
  }
}