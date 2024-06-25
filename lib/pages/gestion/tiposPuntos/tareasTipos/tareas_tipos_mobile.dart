import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/tarea.dart';
import 'package:sedel_oficina_maqueta/models/tarea_tipo_pto.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tareas_services.dart';
import 'package:sedel_oficina_maqueta/services/tipos_ptos_inspeccion_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';

class TareasTiposPuntosMobile extends StatefulWidget {
  const TareasTiposPuntosMobile({super.key});

  @override
  State<TareasTiposPuntosMobile> createState() => _TareasTiposPuntosMobileState();
}

class _TareasTiposPuntosMobileState extends State<TareasTiposPuntosMobile> {
  late List<Tarea> tareas = [];
  late String token = '';
  bool activoActividad = false;
  bool activoMantenimiento = false;
  late List<int> tareasIdActividad = [];
  late List<int> tareasIdMantenimiento = [];
  late List<TareaTipoPto> tareasTipoPtoActividad = [];
  late List<TareaTipoPto> tareasTipoPtoMantenimiento = [];
  late TipoPtosInspeccion tipoSeleccionado = TipoPtosInspeccion.empty();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    tipoSeleccionado = context.read<OrdenProvider>().tiposPuntosGestion;
    tareas = await TareasServices().getTareas(context, '', '', token);
    tareasTipoPtoActividad = await TiposPtosInspeccionServices().getTareasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, 'A', token);
    tareasTipoPtoMantenimiento = await TiposPtosInspeccionServices().getTareasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, 'M', token);
    for (var tarea in tareas) {
      activoActividad = tareasTipoPtoActividad.any((task) => task.tareaId == tarea.tareaId);
      tarea.activoActividad = activoActividad;
      if(activoActividad) {
        tareasIdActividad.add(tarea.tareaId);
      }
    }
    for (var tarea in tareas) {
      activoMantenimiento = tareasTipoPtoMantenimiento.any((task) => task.tareaId == tarea.tareaId);
      tarea.activoMantenimiento = activoMantenimiento;
      if(activoMantenimiento) {
        tareasIdMantenimiento.add(tarea.tareaId);
      }
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarMobile(titulo: 'Tareas del tipo de punto inspección'),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Expanded(
            child: ListView.separated(
              itemCount: tareas.length,
              itemBuilder: (context, i){
                var tareaActividad = tareas[i];
                return ListTile(
                  title: Text(tareaActividad.descripcion),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            activeColor: colors.primary,
                            value: tareaActividad.activoActividad,
                            onChanged: (value) async {
                              setState(() {
                                tareaActividad.activoActividad = value!;
                              });
                              if (value!) {
                                tareasIdActividad.add(tareaActividad.tareaId);
                                await TiposPtosInspeccionServices().postTareasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, tareaActividad.tareaId, 'A', token);
                              } else {
                                tareasIdActividad.remove(tareaActividad.tareaId);
                                await TiposPtosInspeccionServices().deleteTareasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, tareaActividad.tareaId, 'A', token);
                              }
                            },
                          ),
                          const Text('Actividad')
                        ],
                      ),
                      const SizedBox(width: 15,),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            activeColor: colors.primary,
                            value: tareaActividad.activoMantenimiento,
                            onChanged: (value) async {
                              setState(() {
                                tareaActividad.activoMantenimiento = value!;
                              });
                              if (value!) {
                                tareasIdActividad.add(tareaActividad.tareaId);
                                await TiposPtosInspeccionServices().postTareasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, tareaActividad.tareaId, 'M', token);
                              } else {
                                tareasIdActividad.remove(tareaActividad.tareaId);
                                await TiposPtosInspeccionServices().deleteTareasTiposPtosInspeccion(context, tipoSeleccionado.tipoPuntoInspeccionId, tareaActividad.tareaId, 'M', token);
                              }
                            },
                          ),
                          const Text('Mantenimiento')
                        ],
                      ),
                    ],
                  ),
                );
              }, 
              separatorBuilder: (BuildContext context, int index) {
                return const Divider();
              }
            ),
          ),
        ),
      ),
    );
  }
}