// ignore_for_file: avoid_init_to_null

import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/servicio.dart';
import 'package:sedel_oficina_maqueta/models/servicios_clientes.dart';
import 'package:sedel_oficina_maqueta/services/client_services.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:intl/intl.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class AddClientServicesDialog extends StatefulWidget {
  final ServicioCliente? servicioClienteSeleccionado;
  final Cliente cliente;
  final String token;

  const AddClientServicesDialog(
      {super.key,
      required this.servicioClienteSeleccionado,
      required this.cliente,
      required this.token});

  @override
  State<AddClientServicesDialog> createState() =>
      _AddClientServicesDialogState();
}

class _AddClientServicesDialogState extends State<AddClientServicesDialog> {
  final TextEditingController comentarioController = TextEditingController();
  late Servicio? servicioSeleccionado = Servicio.empty();
  final DateTime hoy = DateTime.now();
  late DateTime fechaDesde = DateTime(hoy.year, hoy.month, hoy.day, 0, 0, 0);
  late DateTime? fechaHasta = null;

  List<Servicio> servicios = [];
  @override
  void initState() {
    super.initState();
    cargarLista();
  }

  cargarLista() async {
    servicios = await ServiciosServices().getServicios(context, '', '', '', widget.token);
    setState(() {
      servicioSeleccionado = servicios.isNotEmpty ? null : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    comentarioController.text =
        (widget.servicioClienteSeleccionado?.comentario == null
            ? comentarioController.text
            : widget.servicioClienteSeleccionado!.comentario);
    fechaDesde = (widget.servicioClienteSeleccionado?.desde ?? fechaDesde);
    fechaHasta = (widget.servicioClienteSeleccionado?.hasta ?? fechaHasta);

    late Servicio? servicioInicial = servicios.isNotEmpty ? null : null;
    if (servicioSeleccionado?.servicioId != 0) {
      if (widget.servicioClienteSeleccionado == null) {
        servicioInicial = null;
      } else {
        servicioInicial = servicios.firstWhere((servicio) =>
          servicio.servicioId == widget.servicioClienteSeleccionado?.servicioId);
      }
    }

    return AlertDialog(
      title: const Text('Servicio'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DropdownButtonFormField(
            items: servicios.map((e) {
              return DropdownMenuItem(
                value: e,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.17,
                  child: Text(
                    e.descripcion,
                    overflow: TextOverflow.fade,
                  ),
                ),
              );
            }).toList(),
            onChanged: (Servicio? value) {
              servicioSeleccionado = value;
            },
            value: servicioInicial,
            hint: const Text('Servicios'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final fechaDesdeSeleccionada = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099));
                  setState(() {
                    if (fechaDesdeSeleccionada == null) {
                      fechaDesde = fechaDesde;
                    } else {
                      fechaDesde = fechaDesdeSeleccionada;
                      if (widget.servicioClienteSeleccionado != null) {
                        setState(() {
                          widget.servicioClienteSeleccionado!.desde = fechaDesdeSeleccionada;
                          widget.servicioClienteSeleccionado?.comentario = comentarioController.text;
                        });
                      }
                    }
                  });
                },
                child: const Text('Seleccione fecha desde')
              ),
              const SizedBox(width: 8,),
              Text((DateFormat('E, d , MMM, yyyy', 'es').format(fechaDesde)),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final fechaHastaSeleccionada = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2099)
                  );
                  setState(() {
                    if (fechaHastaSeleccionada == null) {
                      fechaHasta = fechaHasta;
                    } else {
                      fechaHasta = fechaHastaSeleccionada;
                      if (widget.servicioClienteSeleccionado != null) {
                        setState(() {
                          widget.servicioClienteSeleccionado!.hasta = fechaHastaSeleccionada;
                          widget.servicioClienteSeleccionado?.comentario = comentarioController.text;
                        });
                      }
                    }
                  });
                },
                child: const Text('Seleccione fecha hasta')
              ),
              const SizedBox(width: 8,),
              Text(
                fechaHasta == null ? '' : (DateFormat('E, d , MMM, yyyy', 'es').format(fechaHasta!)),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    fechaHasta = null;
                    widget.servicioClienteSeleccionado?.hasta = null;
                  });
                },
                icon: const Icon(Icons.clear)
              )
            ],
          ),
          SizedBox(
            width: 300,
            child: CustomTextFormField(
              controller: comentarioController,
              label: 'Comentario',
              maxLines: 1,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            final ServicioCliente nuevoServicioCliente = ServicioCliente(
              clienteServicioId: 0,
              servicioId: widget.servicioClienteSeleccionado?.servicioId == null
                  ? servicioSeleccionado!.servicioId
                  : widget.servicioClienteSeleccionado!.servicioId,
              desde: fechaDesde,
              hasta: fechaHasta,
              comentario: comentarioController.text,
              codServicio: '',
              servicio: '',
            );

            if (widget.servicioClienteSeleccionado != null) {
              widget.servicioClienteSeleccionado!.servicioId =
                  servicioSeleccionado != null
                      ? servicioSeleccionado!.servicioId
                      : widget.servicioClienteSeleccionado!.servicioId;
              widget.servicioClienteSeleccionado?.comentario =
                  comentarioController.text;

              ClientServices().putClienteServices(
                context,
                widget.cliente.clienteId.toString(),
                widget.servicioClienteSeleccionado,
                widget.servicioClienteSeleccionado!.clienteServicioId.toString(),
                widget.token,
              );
            } else {
              ClientServices().postClienteServices(
                context,
                widget.cliente.clienteId.toString(),
                nuevoServicioCliente,
                widget.token,
              );
            }
          },
          child: const Text('Guardar'),
        ),
        ElevatedButton(
          onPressed: () {
            router.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
