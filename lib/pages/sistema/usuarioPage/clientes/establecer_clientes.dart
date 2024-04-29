import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/pages/pages.dart';
import 'package:sedel_oficina_maqueta/pages/sistema/usuarioPage/clientes/establecer_clientes_mobile.dart';


class EstablecerClientes extends StatefulWidget {
  const EstablecerClientes({super.key});

  @override
  State<EstablecerClientes> createState() => _EstablecerClientesState();
}

class _EstablecerClientesState extends State<EstablecerClientes> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return const EstablecerClientesMobile();
          } else if (constraints.maxWidth > 900) {
            return const EstablecerClientesDesktop();
          }
          return const EstablecerClientesDesktop();
        },
      )),
    );
  }
}