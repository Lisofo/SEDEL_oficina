import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/tareas/tareas_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


class TareasPage extends StatefulWidget {
  const TareasPage({super.key});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const TareasMobile();
          } else if (constraints.maxWidth > 900) {
            return const TareasDesktop();
          }
          return const TareasDesktop();
        },
      )),
    );
  }
}