import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/servicios_clientes.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';

import 'frecuencia_servicio_desktop.dart';
import 'frecuencia_servicio_mobile.dart';

class FrecuenciaServicioClientePage extends StatefulWidget {
  const FrecuenciaServicioClientePage({super.key});

  @override
  State<FrecuenciaServicioClientePage> createState() => _FrecuenciaServicioClientePageState();
}

class _FrecuenciaServicioClientePageState extends State<FrecuenciaServicioClientePage> {
  @override
  Widget build(BuildContext context) {
    late Cliente cliente = context.read<OrdenProvider>().cliente;
    late String token = context.read<OrdenProvider>().token;
    late ServicioCliente servicioCliente = context.read<OrdenProvider>().servicioCliente;
    return SafeArea(
      child: Scaffold(body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 800) {
            return FrecuenciaServicioMobile(cliente: cliente, token: token, servicioCliente: servicioCliente,);
          } else if (constraints.maxWidth > 900) {
            return FrecuenciaServicioDesktop(cliente: cliente, token: token, servicioCliente: servicioCliente,);
          }
          return FrecuenciaServicioDesktop(cliente: cliente, token: token, servicioCliente: servicioCliente,);
        },
      )),
    );
  }
}
