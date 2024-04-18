import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/Monitoreo%20Diario/mapa/mapa_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/Monitoreo%20Diario/mapa/mapa_mobile.dart';


class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const MapaPageMobile();
          } else if (constraints.maxWidth > 900) {
            return const MapaPageDesktop();
          }
          return const MapaPageDesktop();
        },
      )),
    );
  }
}