import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/revision_pto_inspeccion.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/widgets/visualizar_accion.dart';

class RevisionPtosInspeccionRevision extends StatefulWidget {
  const RevisionPtosInspeccionRevision({super.key});

  @override
  State<RevisionPtosInspeccionRevision> createState() =>
      _RevisionPtosInspeccionRevisionState();
}

class _RevisionPtosInspeccionRevisionState
    extends State<RevisionPtosInspeccionRevision> {
  late RevisionPtoInspeccion puntoSeleccionado = RevisionPtoInspeccion.empty();
  late List<RevisionPtoInspeccion> puntosSeleccionados = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() {
    puntoSeleccionado = context.read<OrdenProvider>().revisionPtoInspeccion;
    puntosSeleccionados = context.read<OrdenProvider>().puntosSeleccionados;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.primary,
          title: const Text(
            'Revisión',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            if (puntosSeleccionados.isNotEmpty) ...[
              for (var i = 0; i < puntosSeleccionados.length; i++) ...[
                Center(
                  child: SizedBox(
                    width: 600,
                    child: VisualizarAccion(
                      revision: puntosSeleccionados[i],
                    ),
                  ),
                )
              ]
            ] else ...[
              Center(
                child: SizedBox(
                    width: 600,
                    child: VisualizarAccion(revision: puntoSeleccionado)),
              )
            ],
          ]),
        ),
      ),
    );
  }
}
