import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';


import 'package:sedel_oficina_maqueta/pages/sistema/usuarioPage/password/password_mobile.dart';


class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EditPasswordMobile();
          } else if (constraints.maxWidth > 900) {
            return const EditPasswordDesktop();
          }
          return const EditPasswordDesktop();
        },
      )),
    );
  }
}