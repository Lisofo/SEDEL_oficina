// ignore_for_file: void_checks

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/gradoInfestacion.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_plaga.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/revision_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';

class RevisionPlagasMenu extends StatefulWidget {
  final List<Plaga> plagas;
  final List<RevisionPlaga> revisionPlagasList;
  final RevisionOrden? revision;

  const RevisionPlagasMenu({super.key, required this.plagas, required this.revisionPlagasList, required this.revision});

  @override
  State<RevisionPlagasMenu> createState() => _RevisionPlagasMenuState();
}

class _RevisionPlagasMenuState extends State<RevisionPlagasMenu> {
  late Orden orden = context.read<OrdenProvider>().orden;
  late int revisionId = context.read<OrdenProvider>().revisionId;

  List<GradoInfestacion> gradoInfeccion = [
    GradoInfestacion(
      gradoInfestacionId: 1,
      codGradoInfestacion: '1',
      descripcion: 'Sin Avistamiento'),
    GradoInfestacion(
      gradoInfestacionId: 2,
      codGradoInfestacion: '2',
      descripcion: 'Población Controlada - Aceptable'),
    GradoInfestacion(
      gradoInfestacionId: 3,
      codGradoInfestacion: '3',
      descripcion: 'Población Media - Requiere Atención'),
    GradoInfestacion(
      gradoInfestacionId: 4,
      codGradoInfestacion: '4',
      descripcion: 'Población Alta - Grave'),
  ];
  List<Plaga> plagasSeleccionadas = [];
  late Plaga selectedPlaga = Plaga.empty();
  List<GradoInfestacion> gradosSeleccionados = [];
  GradoInfestacion selectedGrado = GradoInfestacion.empty();
  final ScrollController _scrollController = ScrollController();
  late String token = context.read<OrdenProvider>().token;
  bool isReadOnly = true;

  bool cargoDatosCorrectamente = false;
  bool cargando = true;
  bool agregandoPlaga = false;
  int? statusCodeRevision;
  bool borrando = false;
  final revisionServices = RevisionServices();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    try {
      if (widget.plagas.isNotEmpty || widget.revisionPlagasList.isNotEmpty){
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
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
              width: Constantes().ancho,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: colors.primary),
                  borderRadius: BorderRadius.circular(5)),
              child: DropdownSearch(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration:
                        InputDecoration(hintText: 'Seleccione una plaga')),
                items: widget.plagas,
                popupProps: const PopupProps.menu(
                    showSearchBox: true, searchDelay: Duration.zero),
                onChanged: (value) {
                  setState(() {
                    selectedPlaga = value;
                  });
                },
              )),
          const SizedBox(
            height: 30,
          ),
          Container(
            width: Constantes().ancho,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1, color: colors.primary),
                borderRadius: BorderRadius.circular(5)),
            child: DropdownSearch(
              dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                      hintText: 'Seleccione un grado de infestacion')),
              items: gradoInfeccion,
              popupProps: const PopupProps.menu(
                  showSearchBox: true, searchDelay: Duration.zero),
              onChanged: (value) {
                setState(() {
                  selectedGrado = value;
                });
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: Constantes().ancho,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  onPressed: !agregandoPlaga ? () async {
                    agregandoPlaga = true;
                    setState(() {});
                    if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede modificar esta revisión.'),
                      ));
                      agregandoPlaga = false;
                      return Future.value(false);
                    }
                    if (selectedGrado.gradoInfestacionId != 0) {
                      bool agregarPlaga = true;
                      if (widget.revisionPlagasList.isNotEmpty) {
                        agregarPlaga = !widget.revisionPlagasList.any((plaga) => plaga.plagaId == selectedPlaga.plagaId);
                      }
                      if (agregarPlaga) {
                        await posteoRevisionPlaga(context);
                        agregandoPlaga = false;
                        setState(() {});
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Seleccione un grado de infestación'),
                      ));
                      agregandoPlaga = false;
                      return Future.value(false);
                    }
                    agregandoPlaga = false;
                    setState(() {});
                  } : null,
                  disabled: agregandoPlaga,
                  text: 'Agregar +',
                  tamano: 20,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SizedBox(
            height: 388,
            child: Container(
              width: Constantes().ancho,
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.revisionPlagasList.length,
                itemBuilder: (context, i) {
                  final item = widget.revisionPlagasList[i];
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
                              content: const Text(
                                  "¿Estas seguro de querer borrar la plaga?"),
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
                                    await RevisionServices().deleteRevisionPlaga(context,orden,widget.revisionPlagasList[i],revisionId,token);
                                    statusCodeRevision = await revisionServices.getStatusCode();
                                    await revisionServices.resetStatusCode();
                                    if (statusCodeRevision == 1){
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
                        if (statusCodeRevision == 1) {
                          setState(() {
                            widget.revisionPlagasList.removeAt(i);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('La plaga $item ha sido borrada'),
                          ));
                          }
                        statusCodeRevision = null;
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
                        decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide())),
                        child: ListTile(
                          title: Text(widget.revisionPlagasList[i].plaga),
                          subtitle: Text(widget.revisionPlagasList[i].gradoInfestacion),
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
                                        content: const Text(
                                            "¿Estas seguro de querer borrar la plaga?"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("CANCELAR"),
                                          ),
                                          TextButton(
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                              onPressed: !borrando ? () async {
                                                borrando = true;
                                                setState(() {});
                                                await borrarPlaga(context, i);
                                              } : null,
                                              child: const Text("BORRAR")),
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(Icons.delete)),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> posteoRevisionPlaga(BuildContext context) async {
    var nuevaPlaga = RevisionPlaga(
        otPlagaId: 0,
        ordenTrabajoId: orden.ordenTrabajoId,
        otRevisionId: orden.otRevisionId,
        comentario: '',
        plagaId: selectedPlaga.plagaId,
        codPlaga: selectedPlaga.codPlaga,
        plaga: selectedPlaga.descripcion,
        gradoInfestacionId: selectedGrado.gradoInfestacionId,
        codGradoInfestacion: selectedGrado.codGradoInfestacion,
        gradoInfestacion: selectedGrado.descripcion);
    await revisionServices.postRevisionPlaga(context,orden,selectedPlaga.plagaId,selectedGrado.gradoInfestacionId,nuevaPlaga,revisionId,token);
    statusCodeRevision = await revisionServices.getStatusCode();
    await revisionServices.resetStatusCode();
    if (statusCodeRevision == 1){
      widget.revisionPlagasList.add(nuevaPlaga);
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
    statusCodeRevision = null;
  }

  Future<void> borrarPlaga(BuildContext context, int i) async {
    await revisionServices.deleteRevisionPlaga(context, orden, widget.revisionPlagasList[i], revisionId, token);
    statusCodeRevision = await revisionServices.getStatusCode();
    await revisionServices.resetStatusCode();
    if (statusCodeRevision == 1){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('La plaga ${widget.revisionPlagasList[i].plaga} ha sido borrada'),
      ));
      setState(() {
        widget.revisionPlagasList.removeAt(i);
      });
      router.pop();
    }
    statusCodeRevision = null;
    borrando = false;  
  }
}
