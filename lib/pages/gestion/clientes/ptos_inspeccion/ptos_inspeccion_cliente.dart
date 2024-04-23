import 'package:flutter/material.dart';

import 'ptos_inspeccion_cliente_desktop.dart';
import 'ptos_inspeccion_cliente_mobile.dart';

class PtosInspeccionClientes extends StatefulWidget {
  const PtosInspeccionClientes({super.key});

  @override
  State<PtosInspeccionClientes> createState() => _PtosInspeccionClientesState();
}

class _PtosInspeccionClientesState extends State<PtosInspeccionClientes> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const PtosInspeccionClientesMobile();
          } else if (constraints.maxWidth > 900) {
            return const PtosInspeccionClientesDesktop();
          }
          return const PtosInspeccionClientesDesktop();
        },
      )),
    );
  }
}
