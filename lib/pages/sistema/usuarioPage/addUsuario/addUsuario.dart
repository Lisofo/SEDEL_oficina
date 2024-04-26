import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';
import 'package:sedel_oficina_maqueta/pages/sistema/usuarioPage/addUsuario/add_usuario_desktop.dart';


class AddUsuarioPage extends StatefulWidget {
  const AddUsuarioPage({super.key});

  @override
  State<AddUsuarioPage> createState() => _AddUsuarioPageState();
}

class _AddUsuarioPageState extends State<AddUsuarioPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const AddUsuarioMobile();
          } else if (constraints.maxWidth > 900) {
            return const AddUsuarioDesktop();
          }
          return const AddUsuarioDesktop();
        },
      )),
    );
  }
}