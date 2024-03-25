// ignore_for_file: void_checks

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/observacion.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/revision_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';

class RevisionObservacionesMenu extends StatefulWidget {
  final Observacion observacion;
  final List<Observacion> observaciones;
  final RevisionOrden? revision;

  const RevisionObservacionesMenu(
      {super.key, required this.observacion, required this.observaciones, required this.revision});

  @override
  State<RevisionObservacionesMenu> createState() =>
      _RevisionObservacionesMenuState();
}

class _RevisionObservacionesMenuState extends State<RevisionObservacionesMenu> {
  final observacionController = TextEditingController();
  final comentarioInternoController = TextEditingController();
  late Orden orden = context.read<OrdenProvider>().orden;
  late String token = context.read<OrdenProvider>().token;
  late int revisionId = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    observacionController.text = widget.observacion.observacion;
    comentarioInternoController.text = widget.observacion.comentarioInterno;
    revisionId = context.read<OrdenProvider>().revisionId;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Observaciones:',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              width: Constantes().ancho,
              decoration: BoxDecoration(
                border: Border.all(
                    color: colors.primary, width: 1),
                borderRadius: BorderRadius.circular(5),
                // color: Colors.white
              ),
              child: TextFormField(
                controller: observacionController,
                maxLines: 6,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.white,
                    filled: true),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Comentario interno:',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              width: Constantes().ancho,
              decoration: BoxDecoration(
                border: Border.all(
                    color: colors.primary, width: 1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextFormField(
                controller: comentarioInternoController,
                maxLines: 6,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    fillColor: Colors.white,
                    filled: true),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: CustomButton(
                onPressed: () async {
                  if (widget.revision?.ordinal == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No se puede modificar esta revisión.'),
                    ));
                    return Future.value(false);
                  }
                  guardarObservaciones();
                },
                text: 'Guardar',
                tamano: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  guardarObservaciones() async {
    widget.observacion.comentarioInterno = comentarioInternoController.text;
    widget.observacion.observacion = observacionController.text;
    widget.observacion.obsRestringida = observacionController.text;

    if (widget.observacion.otObservacionId == 0) {
      await RevisionServices().postObservacion(context, orden, widget.observacion, revisionId, token);
    } else {
      await RevisionServices().putObservacion(context, orden, widget.observacion, revisionId, token);
    }
  }
}
