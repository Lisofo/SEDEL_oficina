import 'package:flutter/material.dart';

import 'clientes_desktop.dart';
import 'clientes_mobile.dart';


class Clientes extends StatefulWidget {
  const Clientes({super.key});

  @override
  State<Clientes> createState() => _ClientesState();
}

class _ClientesState extends State<Clientes> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const ClientesMobile();
          } else if (constraints.maxWidth > 900) {
            return const ClientesDesktop();
          }
          return const ClientesDesktop();
        },
      )),
    );
  }
}
