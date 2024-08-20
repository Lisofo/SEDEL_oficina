// ignore_for_file: use_build_context_synchronously, unused_element
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/control_orden.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/observacion.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_tarea.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/ptosInspeccion/revision_ptos_inspeccion_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_cuestionario.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_firmas.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_materiales_diagnostico.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_observaciones.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_plagas.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_tareas.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_validacion.dart';
import 'package:sedel_oficina_maqueta/provider/menu_provider.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/services/orden_control_services.dart';
import 'package:sedel_oficina_maqueta/services/orden_services.dart';
import 'package:sedel_oficina_maqueta/services/plaga_services.dart';
import 'package:sedel_oficina_maqueta/services/ptos_services.dart';
import 'package:sedel_oficina_maqueta/services/revision_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/icons.dart';
import 'package:sedel_oficina_maqueta/models/revision_pto_inspeccion.dart';

import '../../../models/clientesFirmas.dart';


class RevisionOrdenMobile extends StatefulWidget {
  const RevisionOrdenMobile({super.key});

  @override
  State<RevisionOrdenMobile> createState() => _RevisionOrdenMobileState();
}

class _RevisionOrdenMobileState extends State<RevisionOrdenMobile> with SingleTickerProviderStateMixin {
  final TextEditingController comentarioController = TextEditingController();
  late Orden orden = Orden.empty();
  late AnimationController _animationController;
  late List<Plaga> plagas = [];
  late List<Materiales> materiales = [];
  late List<RevisionMaterial> revisionMaterialesList = [];
  late List<RevisionTarea> revisionTareasList = [];
  late List<RevisionPlaga> revisionPlagasList = [];
  late List<Observacion> observaciones = [];
  late Observacion observacion = Observacion.empty();
  late int revisionId = 0;
  late List<RevisionPtoInspeccion> ptosInspeccion = [];
  late String token = '';
  late String menu = '';
  List<RevisionOrden> revisiones = [];
  int selectedIndex = 0;
  RevisionOrden? selectedRevision = RevisionOrden.empty();
  late List<ClienteFirma> firmas = [];
  bool filtro = false;
  int buttonIndex = 0;
  String valorComentario = '';
  List<ControlOrden> controles =[];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    cargarDatos();
  }

  cargarDatos() async {
    orden = context.read<OrdenProvider>().orden;
    revisionId = orden.otRevisionId;
    token = context.read<OrdenProvider>().token;
    observaciones = await RevisionServices().getObservacion(context, orden, observacion, revisionId, token);
    observacion = observaciones.isNotEmpty ? observaciones[0] : Observacion.empty();
    firmas = await RevisionServices().getRevisionFirmas(context, orden, revisionId, token);
    revisiones = await RevisionServices().getRevisiones(context, orden, token);
    selectedRevision = revisiones[0];
    Provider.of<OrdenProvider>(context, listen: false).setRevisionId(revisionId);
    switch (orden.tipoOrden.codTipoOrden){
      case 'N':
      case 'D':
        plagas = await PlagaServices().getPlagas(context, '', '', token);
        materiales = await MaterialesServices().getMateriales(context, '', '', token);
        revisionMaterialesList = await MaterialesServices().getRevisionMateriales(context, orden, revisionId, token);
        revisionTareasList = await RevisionServices().getRevisionTareas(context, orden, revisionId, token);
        revisionPlagasList = await RevisionServices().getRevisionPlagas(context, orden, revisionId, token);
        ptosInspeccion = await PtosInspeccionServices().getPtosInspeccion(context, orden, revisionId, token);
      break;
      case 'C':
        controles = await OrdenControlServices().getControlOrden(context, orden, revisionId, token);
        controles.sort((a, b) => a.pregunta.compareTo(b.pregunta));
      break;
    }
    setState(() {});
    
  }

  void toggleMapWidth() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Revisión orden ${orden.ordenTrabajoId}'),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _listaItems()
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CustomDropdownFormMenu(
                //value: revisiones.isEmpty ? null : revisiones[0],
                items: revisiones.map((e){
                  return DropdownMenuItem(
                    value: e,
                    child: SizedBox( // Wrap with SizedBox to limit width
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        'Revisión ${e.ordinal} (${e.tipoRevision}): ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                      ),
                    ),
                  );
                }).toList(),
                hint: 'Seleccione una revisión',
                onChanged: (value) async {
                  await cambioDeRevision(value, context);
                  valorComentario = value.comentario;
                  setState(() {});
                },
              ),

            ),
            Text(
              valorComentario,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
            ),
            const SizedBox(height: 10,),
            const Divider(),
            const SizedBox(height: 10,),
            const Spacer(),
            BottomNavigationBar(
              currentIndex: buttonIndex,
              onTap: (index) async {
                buttonIndex = index;
                switch (buttonIndex){
                  case 0: 
                    if (orden.estado == 'REVISADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede borrar revisiones.'),
                      ));
                      return Future.value(false);
                    }
                    _showCreateDeleteDialog(context);
                  break;
                  case 1:
                    if (orden.estado == 'REVISADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede crear nuevas revisiones.'),
                      ));
                      return Future.value(false);
                    }
                    _showCreateCopyDialog(context);
                  break;
                  case 2:
                    if (orden.estado == 'REVISADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede cambiar el estado.'),
                      ));
                      return Future.value(false);
                    }
                    cambiarEstado();
                  break;
                  case 3:
                    if (orden.estado != 'FINALIZADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede cambiar las fechas.'),
                      ));
                      return Future.value(false);
                    }
                    await cambiarFechas(orden.iniciadaEn, orden.finalizadaEn);
                  break;
                }
                setState(() {});
              },
              showUnselectedLabels: true,
              selectedItemColor: colors.primary,
              unselectedItemColor: colors.primary,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.delete),
                  label: 'Borrar Revision',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle),
                  label: 'Crear Copia',
                ),
                BottomNavigationBarItem(
                  label: 'Orden revisada',
                  icon: Icon(Icons.save)
                ),
                BottomNavigationBarItem(
                  label: 'Cambiar fechas',
                  icon: Icon(Icons.calendar_today)
                ),
              ],
            ),
          ],
        ),
        
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 200,
          ),
          if (menu == 'Ptos de Inspeccion') RevisionPtosInspeccionMobile(
            ptosInspeccion: ptosInspeccion,
            revision: selectedRevision
          ),
          if (menu == 'Tareas Realizadas')
            RevisionTareasMenu(
              revisionTareasList: revisionTareasList,
              revision: selectedRevision,
            ),
          if (menu == 'Plagas')
            RevisionPlagasMenu(
              plagas: plagas,
              revisionPlagasList: revisionPlagasList,
              revision: selectedRevision,
            ),
          if (menu == 'Materiales utilizados')
            RevisionMaterialesMenu(
              materiales: materiales,
              revisionMaterialesList: revisionMaterialesList,
              revision: selectedRevision,
            ),
          if (menu == 'Observaciones')
            RevisionObservacionesMenu(
              observacion: observacion,
              observaciones: observaciones,
              revision: selectedRevision,
            ),
          if (menu == 'Firmas') RevisionFirmasMenu(
            revision: selectedRevision,
            firmas: firmas,
          ),
          if (menu == 'Cuestionario') RevisionCuestionarioMenu(
            controles: controles,
            revision: selectedRevision,
          ),
          if (menu == 'Validacion') RevisionValidacionMenu(
            controles: controles,
            revision: selectedRevision,
          ),
          if (menu == 'Materiales') RevisionMaterialesDiagnositcoMenu(
            materiales: materiales,
            revisionMaterialesList: revisionMaterialesList,
            revision: selectedRevision,
          ),
        ],
      ),
       
      //todo bottomnavigation   
    );
  }

  Future<void> cambioDeRevision(value, BuildContext context) async {
    selectedRevision = value;
    revisionId = (value as RevisionOrden).otRevisionId;
    print(revisionId);
    Provider.of<OrdenProvider>(context, listen: false).setRevisionId(revisionId);
    observaciones = await RevisionServices().getObservacion(context, orden, observacion, revisionId, token);
    observacion = observaciones.isNotEmpty ? observaciones[0] : Observacion.empty();
    firmas = await RevisionServices().getRevisionFirmas(context, orden, revisionId, token);
    switch (orden.tipoOrden.codTipoOrden){
      case 'N':
      case 'D':
        revisionMaterialesList = await MaterialesServices().getRevisionMateriales(context, orden, revisionId, token);
        revisionTareasList = await RevisionServices().getRevisionTareas(context, orden, revisionId, token);
        revisionPlagasList = await RevisionServices().getRevisionPlagas(context, orden, revisionId, token);
        ptosInspeccion = await PtosInspeccionServices().getPtosInspeccion(context, orden, revisionId, token);
      break;
      case 'C':
        controles = await OrdenControlServices().getControlOrden(context, orden, revisionId, token);
      break;
    }
  }

void _showCreateCopyDialog(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Crear copia'),
        content: StatefulBuilder(
          builder: (context, setStateBd) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Está por generar la copia de una revisión, seleccione el origen de la copia'),
              const SizedBox(height: 10,),
              CustomDropdownFormMenu(
                isDense: true,
                hint: 'Seleccione una revisión',
                // value: selectedRevision,
                onChanged: (newValue) {
                  setState(() {
                    selectedRevision = newValue;
                  });
                },
                items: revisiones.map((RevisionOrden revision) {
                  return DropdownMenuItem(
                    value: revision,
                    child: Text('Revisión ${revision.ordinal}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10,),
              CustomTextFormField(
                controller: comentarioController,
                hint: 'Escriba un comentario a ser necesario',
                label: 'Comentario',
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Seleccione tipo de Revision:'),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Normal'),
                      const SizedBox(width: 5,),
                      Switch(
                        activeColor: colors.primary,
                        value: filtro, 
                        onChanged: (value) {
                          filtro = value;
                          setStateBd(() {});
                        },
                      ),
                      const SizedBox(width: 5,),
                      const Text('Restringida'),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Crear'),
            onPressed: () async {
              if (selectedRevision != null) {
                selectedRevision!.comentario = comentarioController.text;          
                selectedRevision!.tipoRevision = filtro ? 'R' : 'N';
                await RevisionServices().copyRevision(context, orden, selectedRevision!, token);
                revisiones = await RevisionServices().getRevisiones(context, orden, token);
                setState(() {});
              }
            },
          ),
        ],
      );
    },
  );
}

void _showCreateDeleteDialog(BuildContext context) {
  RevisionOrden? selectedRevision; // Variable para almacenar la revisión seleccionada

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Borrar revisión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Está por borrar una revisión, seleccione cual va a borrar'),
            const SizedBox(height: 10,),
            CustomDropdownFormMenu(
              hint: 'Seleccione una revisión',
              value: selectedRevision,
              onChanged: (newValue) {
                setState(() {
                  selectedRevision = newValue;
                });
              },
              items: revisiones.map((RevisionOrden revision) {
                return DropdownMenuItem(
                  value: revision,
                  child: Text('Revisión ${revision.ordinal}'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Borrar'),
            onPressed: () async {
              if (selectedRevision != null) {
                if(selectedRevision!.ordinal == 0){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La revisión con ordinal 0 no puede ser borrada'),
                      backgroundColor: Colors.red,
                    )
                  );
                }else{
                  await RevisionServices().deleteRevision(context, orden, selectedRevision!, token);
                  revisiones = await RevisionServices().getRevisiones(context, orden, token);
                  setState(() {});
                }
              }
            },
          ),
        ],
      );
    },
  );
}

  Widget _listaItems() {
    final String tipoOrden = orden.tipoOrden.codTipoOrden;
    return FutureBuilder(
      future: menuProvider.cargarMenuRevision(tipoOrden),
      initialData: const [],
      builder: (context, snapshot) {
        return ListView(
          children: _listaItemsDrawer(snapshot.data, context),
        );
      },
    );
  }

  List<Widget> _listaItemsDrawer(data, BuildContext context) {
    final List<Widget> opciones = [];
    data.forEach((opt) {
      final widgetTemp = ListTile(
        title: Text(opt['texto']),
        leading: getIcon(opt['icon'], context),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          color: Colors.green,
        ),
        onTap: () {
          menu = opt['texto'];
          router.pop();
          setState(() {});
        },
      );

      opciones
        ..add(widgetTemp)
        ..add(const Divider());
    });
    return opciones;
  }

  void cambiarEstado() {
    late String nuevoEstado = 'REVISADA';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cambio de estado de la orden'),
          content: Text(
            'Esta por cambiar el estado de la orden ${orden.ordenTrabajoId}. Esta seguro de querer cambiar el estado de ${orden.estado} a $nuevoEstado?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar')
            ),
            TextButton(
              onPressed: () async {
                await OrdenServices().patchOrden(context, orden, nuevoEstado, 0, token);
                await OrdenServices.showDialogs(context, 'Estado cambiado correctamente', true, false);
                setState(() {
                  orden.estado = nuevoEstado;
                });
              },
              child: const Text('Confirmar')
            ),
          ],
        );
      }
    );
  }

   cambiarFechas(DateTime? inicio, DateTime? fin) async {
    DateTime? fechaInicio = inicio;
    DateTime? fechaFinalizacion = fin;
    TimeOfDay? horaInicio = TimeOfDay.fromDateTime(fechaInicio ?? DateTime.now());
    TimeOfDay? horaFinalizacion = TimeOfDay.fromDateTime(fechaFinalizacion ?? DateTime.now());

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cambiar Fechas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                      fechaInicio == null
                        ? 'Seleccione fecha de inicio'
                        : 'Fecha de inicio: ${_formatDateTime(fechaInicio, horaInicio)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: fechaInicio ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: horaInicio ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            fechaInicio = pickedDate;
                            horaInicio = pickedTime;
                          });
                        }
                      }
                    },
                  ),
                  ListTile(
                    title: Text(
                      fechaFinalizacion == null
                        ? 'Seleccione fecha de finalización'
                        : 'Fecha de finalización: ${_formatDateTime(fechaFinalizacion, horaFinalizacion)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: fechaFinalizacion ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: horaFinalizacion ?? TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            fechaFinalizacion = pickedDate;
                            horaFinalizacion = pickedTime;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Guardar'),
                  onPressed: () async {
                    if (fechaInicio != null && fechaFinalizacion != null) {
                      await OrdenServices().patchInicioFin(context, orden, _formatDateTimeWithoutMilliseconds(fechaInicio, horaInicio), _formatDateTimeWithoutMilliseconds(fechaFinalizacion, horaFinalizacion), token);
                      print('Fecha de Inicio: ${_formatDateTimeWithoutMilliseconds(fechaInicio, horaInicio)}');
                      print('Fecha de Finalización: ${_formatDateTimeWithoutMilliseconds(fechaFinalizacion, horaFinalizacion)}');
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';
    final DateTime combined = _combineDateAndTime(date, time);
    return '${combined.year}-${combined.month.toString().padLeft(2, '0')}-${combined.day.toString().padLeft(2, '0')} '
         '${combined.hour.toString().padLeft(2, '0')}:${combined.minute.toString().padLeft(2, '0')}';
  }
  
  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDateTimeWithoutMilliseconds(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return '';
    final DateTime combined = _combineDateAndTime(date, time);
    return '${combined.year}-${combined.month.toString().padLeft(2, '0')}-${combined.day.toString().padLeft(2, '0')} '
           '${combined.hour.toString().padLeft(2, '0')}:${combined.minute.toString().padLeft(2, '0')}:'
           '${combined.second.toString().padLeft(2, '0')}';
  }
}
