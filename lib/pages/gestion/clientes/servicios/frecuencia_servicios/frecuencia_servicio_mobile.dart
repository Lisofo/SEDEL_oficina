import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';

class FrecuenciaServicioMobile extends StatefulWidget {
  final Cliente cliente;
  final String token;


  const FrecuenciaServicioMobile({super.key, required this.cliente, required this.token});

  @override
  State<FrecuenciaServicioMobile> createState() => _FrecuenciaServicioMobileState();
}

class _FrecuenciaServicioMobileState extends State<FrecuenciaServicioMobile> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}