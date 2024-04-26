import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';
import 'package:sedel_oficina_maqueta/pages/sistema/usuarioPage/perfiles/establecer_perfiles_mobile.dart';



class EstablecerPerfiles extends StatefulWidget {
  const EstablecerPerfiles({super.key});

  @override
  State<EstablecerPerfiles> createState() => _EstablecerPerfilesState();
}

class _EstablecerPerfilesState extends State<EstablecerPerfiles> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EstablecerPerfilesMobile();
          } else if (constraints.maxWidth > 900) {
            return const EstablecerPerfilesDesktop();
          }
          return const EstablecerPerfilesDesktop();
        },
      )),
    );
  }
}
