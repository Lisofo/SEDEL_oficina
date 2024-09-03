import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/clientes/servicios/servicio_cliente_desktop.dart';
import 'package:sedel_oficina_maqueta/pages/gestion/clientes/servicios/servicio_cliente_mobile.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';

class ServicioClientePage extends StatefulWidget {
  const ServicioClientePage({super.key});

  @override
  State<ServicioClientePage> createState() => _ServicioClientePageState();
}

class _ServicioClientePageState extends State<ServicioClientePage> {
  @override
  Widget build(BuildContext context) {
    late Cliente cliente = context.read<OrdenProvider>().cliente;
    late String token = context.read<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return ServicioClienteMobile(cliente: cliente, token: token);
          } else if (constraints.maxWidth > 900) {
            return ServicioClienteDesktop(cliente: cliente, token: token);
          }
          return ServicioClienteDesktop(cliente: cliente, token: token);
        },
      )),
    );
  }
}
