import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';
import 'package:sedel_oficina_maqueta/pages/sistema/usuarioPage/usuarios/usuarios_mobile.dart';


class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const UsuariosMobile();
          } else if (constraints.maxWidth > 900) {
            return const UsuariosDesktop();
          }
          return const UsuariosDesktop();
        },
      )),
    );
  }
}