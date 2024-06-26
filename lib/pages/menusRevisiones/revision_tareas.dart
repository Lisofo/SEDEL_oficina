// ignore_for_file: use_build_context_synchronously, void_checks

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_tarea.dart';
import 'package:sedel_oficina_maqueta/models/tarea.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/revision_services.dart';
import 'package:sedel_oficina_maqueta/services/tareas_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';

class RevisionTareasMenu extends StatefulWidget {
   final List<RevisionTarea> revisionTareasList;
   final RevisionOrden? revision;
  const RevisionTareasMenu({super.key, required this.revisionTareasList, required this.revision});

  @override
  State<RevisionTareasMenu> createState() => _RevisionTareasMenuState();
}

class _RevisionTareasMenuState extends State<RevisionTareasMenu> {
  List<Tarea> tareas = [];
  late String token = '';
  final ScrollController _scrollController = ScrollController();
  List<Tarea> tareasSeleccionadas = [];
  Tarea selectedTarea = Tarea.empty();
  late Orden orden = Orden.empty();
  late int revisionId = 0;
  bool cargoDatosCorrectamente = false;
  bool cargando = true;
  bool agregandoTarea = false;
  int? statusCodeTareas;
  bool borrando = false;
  final revisionServices = RevisionServices();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    try {
      tareas = await TareasServices().getTareas(context, '', '', token);
      orden = context.read<OrdenProvider>().orden;
      revisionId = context.read<OrdenProvider>().revisionId;
      if (tareas.isNotEmpty && widget.revisionTareasList.isNotEmpty){
        cargoDatosCorrectamente = true;
      }
      cargando = false;
    } catch (e) {
      cargando = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return cargando ? const Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text('Cargando, por favor espere...')
        ],
      ),
    ) : !cargoDatosCorrectamente ?
    Center(
      child: TextButton.icon(
        onPressed: () async {
          await cargarDatos();
        }, 
        icon: const Icon(Icons.replay_outlined),
        label: const Text('Recargar'),
      ),
    ) :
    Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: Constantes().ancho,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: colors.primary),
              borderRadius: BorderRadius.circular(5)
            ),
            child: DropdownSearch(
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(hintText: 'Seleccione una tarea')
              ),
              items: tareas,
              popupProps: const PopupProps.menu(showSearchBox: true, searchDelay: Duration.zero),
              onChanged: (value) {
                setState(() {
                  selectedTarea = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            width: Constantes().ancho,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  onPressed: !agregandoTarea ? () async {
                    agregandoTarea = true;
                    setState(() {});
                    if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede modificar esta revisión.'),
                      ));
                      agregandoTarea = false;
                      return Future.value(false);
                    }
                    bool agregarTarea = true;
                    if (widget.revisionTareasList.isNotEmpty) {
                      agregarTarea = !widget.revisionTareasList.any((tarea) => tarea.tareaId == selectedTarea.tareaId);
                    }
                    if (agregarTarea) {
                      await posteoRevisionTarea(context);
                      agregandoTarea = false;
                      setState(() {});
                    }else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Seleccione una tarea'),
                        ));
                        agregandoTarea = false;
                        return Future.value(false);
                    }
                    agregandoTarea = false;
                    setState(() {});
                  } : null,
                  text: 'Agregar +',
                  tamano: 20,
                  disabled: agregandoTarea,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Container(
              width: Constantes().ancho,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.revisionTareasList.length,
                itemBuilder: (context, i) {
                  final item = widget.revisionTareasList[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Dismissible(
                      key: Key(item.toString()),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (DismissDirection direction) {
                        if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('No se puede modificar esta revisión.'),
                          ));
                          return Future.value(false);
                        }
                        return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirmar"),
                              content: const Text("¿Estas seguro de querer borrar la plaga?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("CANCELAR"),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await revisionServices.deleteRevisionTarea(context,orden,widget.revisionTareasList[i],revisionId,token);
                                    statusCodeTareas = await revisionServices.getStatusCode();
                                    await revisionServices.resetStatusCode();
                                    if (statusCodeTareas == 1){
                                      Navigator.of(context).pop(true);
                                    }
                                  },
                                  child: const Text("BORRAR")
                                ),
                              ],
                            );
                          }
                        );
                      },
                      onDismissed: (direction) async {
                        if (statusCodeTareas == 1){
                          setState(() {
                            widget.revisionTareasList.removeAt(i);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('La tarea $item ha sido borrada'),
                          ));
                        }
                        statusCodeTareas = null;
                      },
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerEnd,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
                        child: ListTile(
                          title: Text(widget.revisionTareasList[i].descripcion),
                          trailing: IconButton(
                            onPressed: () async {
                              if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('No se puede modificar esta revisión.'),
                                ));
                                return Future.value(false);
                              }
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirmar"),
                                    content: const Text("¿Estas seguro de querer borrar la tarea?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: const Text("CANCELAR"),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        onPressed: !borrando ? () async {
                                          borrando = true;
                                          setState(() {});
                                          await borrarTarea(context, i);
                                        } : null,
                                        child: const Text("BORRAR")
                                      ),
                                    ],
                                  );
                                }
                              );
                            },
                            icon: const Icon(Icons.delete)
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      )
    );
  }

  Future<void> borrarTarea(BuildContext context, int i) async {
    await revisionServices.deleteRevisionTarea(context, orden, widget.revisionTareasList[i], revisionId, token);
    statusCodeTareas = await revisionServices.getStatusCode();
    revisionServices.resetStatusCode();
    if (statusCodeTareas == 1){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('La tarea ${widget.revisionTareasList[i].descripcion} ha sido borrada'),
      ));
      setState(() {
        widget.revisionTareasList.removeAt(i);
      });
      router.pop();
    }
    statusCodeTareas = null;
    borrando = false;
  }

  Future<void> posteoRevisionTarea(BuildContext context) async {
    var nuevaTarea = RevisionTarea(
      otTareaId: 0,
      ordenTrabajoId: orden.ordenTrabajoId,
      otRevisionId: orden.otRevisionId,
      tareaId: selectedTarea.tareaId,
      codTarea: selectedTarea.codTarea,
      descripcion: selectedTarea.descripcion,
      comentario: ''
    );
    await revisionServices.postRevisionTarea(context, orden, selectedTarea.tareaId, nuevaTarea, revisionId, token);
    statusCodeTareas = await revisionServices.getStatusCode();
    await revisionServices.resetStatusCode();
    if (statusCodeTareas == 1){
      widget.revisionTareasList.add(nuevaTarea);
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    statusCodeTareas = null;
  }
}
