// ignore_for_file: use_build_context_synchronously, avoid_print, must_be_immutable, void_checks

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/bottomSheets_opciones.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/plaga_objetivo.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_pto_inspeccion.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/models/zona.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/plagas_objetivo_services.dart';
import 'package:sedel_oficina_maqueta/services/ptos_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class RevisionPtosInspeccionDesktop extends StatefulWidget {
  List<RevisionPtoInspeccion> ptosInspeccion;
  final RevisionOrden? revision;
  RevisionPtosInspeccionDesktop({super.key, required this.ptosInspeccion, required this.revision});
  
  

  @override
  State<RevisionPtosInspeccionDesktop> createState() => _RevisionPtosInspeccionDesktopState();
}

class _RevisionPtosInspeccionDesktopState extends State<RevisionPtosInspeccionDesktop> {
  List<TipoPtosInspeccion> tiposDePuntos = [];
  late TipoPtosInspeccion selectedTipoPto = TipoPtosInspeccion.empty();
  List<RevisionPtoInspeccion> selectedPuntosDeInspeccion = [];
  late List<PlagaObjetivo> plagasObjetivo = [];
  late TextEditingController comentarioController = TextEditingController();
  late TextEditingController sectorController = TextEditingController();
  late TextEditingController codPuntoInspeccionController = TextEditingController();
  late TextEditingController codigoBarraController = TextEditingController();
  late ZonaPI zonaSeleccionada = ZonaPI.empty();
  late PlagaObjetivo plagaObjetivoSeleccionada = PlagaObjetivo.empty();
  bool selectAll = false;
  bool filtro = false;
  bool filtro2 = false;
  late String token = '';
  late Orden orden = Orden.empty();
  bool isReadOnly = true;
  bool pendientes = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  late int revisionId = 0;
  String _searchTerm = '';
  bool subiendoAcciones = false;
  final _ptosInspeccionServices = PtosInspeccionServices();
  int? statusCodeRevision;
  bool cargoDatosCorrectamente = false;
  bool cargando = true;

  List<ZonaPI> zonas = [
    ZonaPI(zona: 'Interior', codZona: 'I'),
    ZonaPI(zona: 'Exterior', codZona: 'E'),
  ];

  List<RevisionPtoInspeccion> get ptosFiltrados {
    return widget.ptosInspeccion.where((pto) => pto.tipoPuntoInspeccionId == selectedTipoPto.tipoPuntoInspeccionId).toList();
  }

  List<RevisionPtoInspeccion> get puntosSeleccionados {
    return ptosFiltrados.where((pto) => pto.seleccionado).toList();
  }

  int get seleccionados {
    return puntosSeleccionados.length;
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    try {
      orden = context.read<OrdenProvider>().orden;
      tiposDePuntos = await getTipos();
      // tiposDePuntos = await _ptosInspeccionServices.getTiposPtosInspeccion(context, token);
      plagasObjetivo = await PlagaObjetivoServices().getPlagasObjetivo(context, '', '', token);
      Provider.of<OrdenProvider>(context, listen: false).setTipoPTI(selectedTipoPto);
      statusCodeRevision = await _ptosInspeccionServices.getStatusCode();
      if (statusCodeRevision == 1){
        cargoDatosCorrectamente = true;
      }
      cargando = false;
    } catch (e) {
      cargando = false;
    }
    
    setState(() {});
  }

  Future<dynamic> getTipos() async {
    late List<TipoPtosInspeccion> tiposDePuntosFiltrados = [];
    if(!filtro2){
      tiposDePuntosFiltrados = await _ptosInspeccionServices.getTiposPtosInspeccion(context, token);
      return tiposDePuntosFiltrados.where((pto)=> cantidadSolo(pto) > 0).toList();
    } else {
      return await _ptosInspeccionServices.getTiposPtosInspeccion(context, token);
    }
  } 

  Future<void> refreshData() async {
    widget.ptosInspeccion = await _ptosInspeccionServices.getPtosInspeccion(context, orden, revisionId, token);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    revisionId = context.read<OrdenProvider>().revisionId;
    print(revisionId);
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
      ) : Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: Constantes().ancho,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1, color: colors.primary
              ),
              borderRadius: BorderRadius.circular(5)
            ),
            child: DropdownButtonFormField(
              decoration: const InputDecoration(border: InputBorder.none),
              hint: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text('Ptos de Inspeccion'),
              ),
              items: tiposDePuntos.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      nombreYCantidad(e),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              isDense: true,
              isExpanded: true,
              onChanged: (value) async {
                widget.ptosInspeccion = await _ptosInspeccionServices.getPtosInspeccion(context, orden, revisionId, token,);
                statusCodeRevision = await _ptosInspeccionServices.getStatusCode();
                await _ptosInspeccionServices.resetStatusCode();
                if(statusCodeRevision == 1){
                  setState(() {
                    Provider.of<OrdenProvider>(context, listen: false).setTipoPTI(value!);
                    selectedTipoPto = value;
                    selectAll = false;
                    for (var i = 0; i < ptosFiltrados.length; i++) {
                      ptosFiltrados[i].seleccionado = false;
                    }
                    for (var ptos in context.read<OrdenProvider>().puntosSeleccionados) {
                      ptos.seleccionado = false;
                    }
                  });
                }
                
              },
            ),
          ),
          SizedBox(
            height: 380,
            width: Constantes().ancho,
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: refreshData,
              child: listaDePuntos()
            )
          ),
          SizedBox(
            width: Constantes().ancho,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (selectedTipoPto.tipoPuntoInspeccionId != 0) {
                      if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('No se puede modificar esta revisión.'),
                        ));
                      } else {
                        _mostrarBottomSheet();
                      }
                    }
                  },
                  icon: Icon(
                    Icons.control_point,
                    size: 35,
                    color: selectedTipoPto.tipoPuntoInspeccionId != 0 ? colors.primary : Colors.grey,
                  ),
                ),
                Switch(
                  activeColor: colors.primary,
                  value: filtro,
                  onChanged: (value) {
                    setState(() {
                      filtro = value;
                      pendientes = filtro;
                      Provider.of<OrdenProvider>(context, listen: false).setPendiente(pendientes);
                      selectAll = false;
                      for (var i = 0; i < ptosFiltrados.length; i++) {
                        ptosFiltrados[i].seleccionado = false;
                      }
                      listaDePuntos();
                    });
                  }
                ),
                const Spacer(),
                // Switch(
                  // activeColor: colors.primary,
                  // value: filtro2,
                  // onChanged: (value) async {
                    // filtro2 = value;
                    // tiposDePuntos = await getTipos();
                    // setState(() {});
                  // }
                // ),
                IconButton(
                  onPressed: () async {
                    widget.ptosInspeccion = await PtosInspeccionServices().getPtosInspeccion(context, orden, revisionId, token, );
                    statusCodeRevision = await _ptosInspeccionServices.getStatusCode();
                    await _ptosInspeccionServices.resetStatusCode();
                    if(statusCodeRevision == 1){
                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Buscar Puntos de Inspección"),
                          content: CustomTextFormField(
                            onChanged: (value) {
                              setState(() {
                                _searchTerm = value;
                              });
                            },
                            hint: "Ingrese el término de búsqueda",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                Provider.of<OrdenProvider>(context, listen: false).filtrarPuntosInspeccion1(_searchTerm);
                                Navigator.pop(context);
                              },
                              child: const Text("Buscar"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.search)
                ),
                Checkbox(
                  activeColor: colors.primary,
                  value: selectAll,
                  onChanged: (newValue) {
                    setState(() {
                      selectAll = newValue!;
                      for (var ptos in context.read<OrdenProvider>().listaPuntos) {
                        ptos.seleccionado = selectAll;
                      }
                    });
                  },
                ),
                IconButton(
                  onPressed: () async {
                    if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede modificar esta revisión.'),
                      ));
                      return Future.value(false);
                    }
                    borrarAccion();
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )
                )
              ],
            ),
          ),
        ]
      ),
    );
  }

  String nombreYCantidad(TipoPtosInspeccion e) { 
    String retorno = '';
    String cantidad = widget.ptosInspeccion.where((pto) => pto.tipoPuntoInspeccionId == e.tipoPuntoInspeccionId).toList().length.toString();
    retorno = '${e.descripcion} ($cantidad)';
    return retorno;
  }

  int cantidadSolo(TipoPtosInspeccion e) {
    int cantidad = widget.ptosInspeccion.where((pto) => pto.tipoPuntoInspeccionId == e.tipoPuntoInspeccionId).toList().length;
    return cantidad;
  }

  listaDePuntos() {
    final colors = Theme.of(context).colorScheme;
    return Consumer<OrdenProvider>(builder: (context, provider, child) {
      return ListView.builder(
        itemCount: provider.listaPuntos.length,
        itemBuilder: (context, index) {
          final puntoDeInspeccion = provider.listaPuntos[index];
          // print(puntoDeInspeccion.codAccion);
          return ListTile(
            title: Row(
              children: [
                Text('Punto ${puntoDeInspeccion.codPuntoInspeccion}'),
                const Spacer(),
                Text(
                  puntoDeInspeccion.codAccion.toString(),
                  style: TextStyle(color: colors.primary),
                )
              ],
            ),
            subtitle: Row(
              children: [
                Text('Zona: ${puntoDeInspeccion.zona}'),
                const SizedBox(
                  width: 20,
                ),
                Text('Sector: ${puntoDeInspeccion.sector}'),
              ],
            ),
            trailing: Checkbox(
              activeColor: colors.primary,
              value: puntoDeInspeccion.seleccionado,
              splashRadius: 40,
              onChanged: (bool? newValue) {
                setState(() {
                  puntoDeInspeccion.seleccionado = newValue ?? false;
                });
              },
            ),
            onTap: () {
              if (puntoDeInspeccion.seleccionado) {
                // Provider.of<OrdenProvider>(context, listen: false)
                //     .setPI(puntosSeleccionados);
              } else {
                Provider.of<OrdenProvider>(context, listen: false).setRevisionPI(puntoDeInspeccion);
              }
              router.push('/ptosInspeccionRevision');
            },
          );
        },
      );
    });
  }

  void _mostrarBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        List<BottomSheetOpcion> listaOpciones = [
          BottomSheetOpcion(
            text: 'Sin Actividad',
            icon: Icons.cancel,
            ruta: 'Sin Actividad',
            condicion: 'M'
          ),
          BottomSheetOpcion(
            text: 'Actividad',
            icon: Icons.check,
            ruta: '/ptosInspeccionActividad',
            condicion: 'M'
          ),
          BottomSheetOpcion(
            text: 'Mantenimiento',
            icon: Icons.build,
            ruta: '/ptosInspeccionActividad',
            condicion: 'M'
          ),
          BottomSheetOpcion(
            text: 'Desinstalado',
            icon: Icons.delete,
            ruta: 'Desinstalado',
            condicion: 'M'
          ),
          BottomSheetOpcion(
            text: 'Nuevo', 
            icon: Icons.add, 
            ruta: 'Nuevo', 
            condicion: 'S'
          ),
          BottomSheetOpcion(
            text: 'Trasladado',
            icon: Icons.swap_horiz,
            ruta: 'Trasladado',
            condicion: 'M'
          ),
          BottomSheetOpcion(
            text: 'Sin Acceso',
            icon: Icons.not_interested,
            ruta: 'Sin Acceso',
            condicion: 'M'
          ),
        ];
        {
          final List<BottomSheetOpcion> listaOpcionesAplicar = [];
          List<RevisionPtoInspeccion> elementosEncontrados = puntosSeleccionados.where((elemento) => elemento.piAccionId == 5).toList();
          for (var pto in listaOpciones) {
            if (seleccionados == 0 || (seleccionados == 1 && puntosSeleccionados[0].piAccionId == 5)) {
              if (pto.condicion == 'S') {
                listaOpcionesAplicar.add(pto);
              }
            } else if (pto.condicion == 'M' && seleccionados > 0 && elementosEncontrados.isEmpty) {
              listaOpcionesAplicar.add(pto);
            }
          }
          return listaOpcionesAplicar.isEmpty
            ? const Center(
                child: Text(
                'No hay opciones disponibles',
                style: TextStyle(fontSize: 16),
                )
              )
            : ListView.separated(
                itemCount: listaOpcionesAplicar.length,
                itemBuilder: (context, i) {
                  Color iconColor = listaOpcionesAplicar[i].text == 'Sin Acceso' ? Colors.red : Colors.green;
                  return ListTile(
                    onTap: () {
                      opciones(listaOpcionesAplicar, i, context);
                    },
                    leading: Icon(
                      listaOpcionesAplicar[i].icon,
                      color: iconColor,
                    ),
                    title: Text(listaOpcionesAplicar[i].text),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 1,
                    color: Colors.green,
                  );
                },
              );
        }
      },
    );
  }

  void opciones(List<BottomSheetOpcion> buttonTexts, int i, BuildContext context) {
    BottomSheetOpcion botones = buttonTexts[i];
    switch (botones.text) {
      case 'Mantenimiento':
      case 'Actividad':
        Provider.of<OrdenProvider>(context, listen: false).setPage(botones.text);
        Provider.of<OrdenProvider>(context, listen: false).setTipoPTI(selectedTipoPto);

        if (botones.text == 'Mantenimiento') {
          Provider.of<OrdenProvider>(context, listen: false).setModo('M');
        } else {
          Provider.of<OrdenProvider>(context, listen: false).setModo('A');
        }

        router.push(botones.ruta);
        break;
      case 'Sin Actividad':
        marcarPISinActividad(1, '');
      break;
      case 'Desinstalado':
      case 'Sin Acceso':
        showDialog(
          context: context,
          builder: (context) {
            if (puntosSeleccionados.length == 1 && (puntosSeleccionados[0].piAccionId == 1 && botones.text == 'Sin Actividad') ||
                (puntosSeleccionados[0].piAccionId == 4 && botones.text == 'Desinstalado') ||
                  puntosSeleccionados[0].piAccionId == 7 && botones.text == 'Sin Acceso') {
              comentarioController.text = puntosSeleccionados[0].comentario;
            } else {
              comentarioController.text = '';
            }
            return AlertDialog(
              title: Text(botones.text),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: comentarioController,
                    minLines: 1,
                    maxLines: 10,
                    decoration: const InputDecoration(hintText: 'Comentario'),
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    router.pop(context);
                  },
                ),
                TextButton(
                  child: const Text('Confirmar'),
                  onPressed: () {
                  if(!subiendoAcciones){
                    subiendoAcciones = true;
                    if (botones.text == 'Desinstalado') {
                      marcarPISinActividad(4, comentarioController.text);
                    } else {
                      marcarPISinActividad(7, comentarioController.text);
                    }
                    router.pop();
                  }
                },
                ),
              ],
            );
          }
        );
      break;
      case 'Nuevo':
        showDialog(
            context: context,
            builder: (context) {
              if (puntosSeleccionados.length == 1 && puntosSeleccionados[0].piAccionId == 5) {
                codigoBarraController.text = puntosSeleccionados[0].codigoBarra;
                sectorController.text = puntosSeleccionados[0].sector;
                comentarioController.text = puntosSeleccionados[0].comentario;
                codPuntoInspeccionController.text = puntosSeleccionados[0].codPuntoInspeccion;
                zonaSeleccionada = zonas.firstWhere((element) => element.codZona == puntosSeleccionados[0].trasladoNuevo[0].zona);
                plagaObjetivoSeleccionada = plagasObjetivo.firstWhere((element) => element.plagaObjetivoId ==puntosSeleccionados[0].trasladoNuevo[0].plagaObjetivoId);
              } else {
                codigoBarraController.text = '';
                sectorController.text = '';
                comentarioController.text = '';
                codPuntoInspeccionController.text = '';
                plagaObjetivoSeleccionada = PlagaObjetivo.empty();
                zonaSeleccionada = ZonaPI.empty();
              }
              return SingleChildScrollView(
                child: AlertDialog(
                  title: const Text('Nuevo Punto'),
                  content: SizedBox(
                    width: Constantes().ancho,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextFormField(
                          controller: codPuntoInspeccionController,
                          maxLines: 1,
                          hint: 'Codigo punto de inspeccion',
                          label: 'Codigo punto de inspeccion',
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomDropdownFormMenu(
                            hint: 'Zona',
                            value: zonaSeleccionada.codZona != ''
                                ? zonaSeleccionada
                                : null,
                            items: zonas.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.zona,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              zonaSeleccionada = value;
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          controller: sectorController,
                          maxLines: 1,
                          hint: 'Sector',
                          label: "Sector",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomDropdownFormMenu(
                            hint: 'Plaga objetivo',
                            value: plagaObjetivoSeleccionada.plagaObjetivoId != 0 ? plagaObjetivoSeleccionada: null,
                            items: plagasObjetivo.map((e) {
                              return DropdownMenuItem<PlagaObjetivo>(
                                value: e,
                                child: SizedBox(
                                  width: 180,
                                  child: Text(
                                    e.descripcion,
                                    softWrap: true,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              plagaObjetivoSeleccionada = value;
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                            controller: comentarioController,
                            maxLines: 1,
                            hint: 'Comentario',
                            label: 'Comentario'),
                        const SizedBox(
                          height: 10,
                        ),
                        CustomTextFormField(
                          controller: codigoBarraController,
                          maxLines: 1,
                          hint: 'Codigo de barras',
                          label: 'Codigo de barras',
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () {
                        router.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text('Confirmar'),
                      onPressed: () async {
                        router.pop(context);
                        await marcarPINuevo(5, zonaSeleccionada, sectorController.text, comentarioController.text);
                      },
                    ),
                  ],
                ),
              );
            }
          );
        break;
      case 'Trasladado':
        showDialog(
            context: context,
            builder: (context) {
              if (puntosSeleccionados[0].otPuntoInspeccionId != 0 && puntosSeleccionados[0].piAccionId == 6) {
                sectorController.text = puntosSeleccionados[0].trasladoNuevo[0].sector;
                comentarioController.text = puntosSeleccionados[0].comentario;
                zonaSeleccionada = zonas.firstWhere((element) => element.codZona == puntosSeleccionados[0].trasladoNuevo[0].zona);
              } else {
                sectorController.text = '';
                comentarioController.text = '';
                zonaSeleccionada = ZonaPI.empty();
              }
              return AlertDialog(
                title: Text(botones.text),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdownFormMenu(
                        hint: 'Zona',
                        value: zonaSeleccionada.codZona != ''
                            ? zonaSeleccionada
                            : null,
                        items: zonas.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.zona,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          zonaSeleccionada = value;
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: sectorController,
                      maxLines: 1,
                      hint: 'Sector',
                      label: 'Sector',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: comentarioController,
                      maxLines: 1,
                      hint: 'Comentario',
                      label: 'Comentario',
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () {
                      router.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('Confirmar'),
                    onPressed: () async {
                     if(!subiendoAcciones){
                        subiendoAcciones = true;
                        await marcarPITraslado(6, zonaSeleccionada, sectorController.text, comentarioController.text);
                      }
                    },
                  ),
                ],
              );
            }
          );
        break;
    }
  }

  Future marcarPISinActividad(int idPIAccion, String comentario) async {
    for (var i = 0; i < puntosSeleccionados.length; i++) {
      puntosSeleccionados[i].ordenTrabajoId = orden.ordenTrabajoId;
      puntosSeleccionados[i].otRevisionId = orden.otRevisionId;
      puntosSeleccionados[i].descTipoPuntoInspeccion = '';
      puntosSeleccionados[i].idPIAccion = idPIAccion;
      puntosSeleccionados[i].piAccionId = idPIAccion;
      puntosSeleccionados[i].codAccion = '';
      puntosSeleccionados[i].descPiAccion = '';
      puntosSeleccionados[i].comentario = comentario;
      puntosSeleccionados[i].materiales = [];
      puntosSeleccionados[i].plagas = [];
      puntosSeleccionados[i].tareas = [];
      puntosSeleccionados[i].trasladoNuevo = [];
    }
    await postAcciones(puntosSeleccionados);
    limpiarDatos();
    subiendoAcciones = false;
  }

  Future marcarPITraslado(int idPIAccion, ZonaPI zonaSeleccionada, String sector, String comentario) async {
    for (var i = 0; i < puntosSeleccionados.length; i++) {
      puntosSeleccionados[i].ordenTrabajoId = orden.ordenTrabajoId;
      puntosSeleccionados[i].otRevisionId = orden.otRevisionId;
      puntosSeleccionados[i].tipoPuntoInspeccionId = selectedTipoPto.tipoPuntoInspeccionId;
      puntosSeleccionados[i].descTipoPuntoInspeccion = '';
      puntosSeleccionados[i].codPuntoInspeccion = puntosSeleccionados[i].codPuntoInspeccion != '' ? puntosSeleccionados[i].codPuntoInspeccion : codPuntoInspeccionController.text;
      puntosSeleccionados[i].codigoBarra = puntosSeleccionados[i].codigoBarra != '' ? puntosSeleccionados[i].codigoBarra : codigoBarraController.text;
      puntosSeleccionados[i].zona = zonaSeleccionada.codZona;
      puntosSeleccionados[i].sector = sector;
      puntosSeleccionados[i].idPIAccion = idPIAccion;
      puntosSeleccionados[i].piAccionId = idPIAccion;
      puntosSeleccionados[i].codAccion = '';
      puntosSeleccionados[i].descPiAccion = '';
      puntosSeleccionados[i].comentario = comentario;
      puntosSeleccionados[i].materiales = [];
      puntosSeleccionados[i].plagas = [];
      puntosSeleccionados[i].tareas = [];
      puntosSeleccionados[i].trasladoNuevo = [];
    }
    await postTraslado(puntosSeleccionados);
    limpiarDatos();
    subiendoAcciones = false;
  }

  Future marcarPINuevo(int idPIAccion, ZonaPI zonaSeleccionada, String sector, String comentario) async {
    RevisionPtoInspeccion nuevaRevisionPtoInspeccion = RevisionPtoInspeccion(
      otPuntoInspeccionId: puntosSeleccionados.isNotEmpty ? puntosSeleccionados[0].otPuntoInspeccionId : 0,
      ordenTrabajoId: orden.ordenTrabajoId,
      otRevisionId: orden.otRevisionId,
      puntoInspeccionId: 0,
      planoId: 0,
      tipoPuntoInspeccionId: selectedTipoPto.tipoPuntoInspeccionId,
      codTipoPuntoInspeccion: '',
      descTipoPuntoInspeccion: '',
      plagaObjetivoId: plagaObjetivoSeleccionada.plagaObjetivoId,
      codPuntoInspeccion: codPuntoInspeccionController.text,
      codigoBarra: codigoBarraController.text,
      zona: zonaSeleccionada.codZona,
      sector: sector,
      idPIAccion: idPIAccion,
      piAccionId: idPIAccion,
      codAccion: '',
      descPiAccion: '',
      comentario: comentario,
      materiales: [],
      plagas: [],
      tareas: [],
      trasladoNuevo: [],
      seleccionado: false
    );

    if (nuevaRevisionPtoInspeccion.otPuntoInspeccionId != 0) {
      await _ptosInspeccionServices.putPtoInspeccionAccion(context, orden, nuevaRevisionPtoInspeccion, revisionId, token);
      statusCodeRevision = await _ptosInspeccionServices.getStatusCode();
      await _ptosInspeccionServices.resetStatusCode();
    } else {
      await _ptosInspeccionServices.postPtoInspeccionAccion(context, orden, nuevaRevisionPtoInspeccion, revisionId, token);
      statusCodeRevision = await _ptosInspeccionServices.getStatusCode();
      await _ptosInspeccionServices.resetStatusCode();
    }
    if(statusCodeRevision == 1) {
      await actualizarDatos();
      limpiarDatos();
      PtosInspeccionServices.showDialogs(context, 'Punto guardado', true, true);
    }
    statusCodeRevision = null;
    subiendoAcciones = false;
  }

  void limpiarDatos() {
    codPuntoInspeccionController.clear();
    codigoBarraController.clear();
    comentarioController.clear();
    sectorController.clear();
    seleccionados == 0;
  }

  Future<void> actualizarDatos() async {
    try {
      widget.ptosInspeccion = await _ptosInspeccionServices.getPtosInspeccion(context, orden, revisionId, token);
      plagasObjetivo = await PlagaObjetivoServices().getPlagasObjetivo(context,'', '', token);  
    } catch (e) {
      widget.ptosInspeccion = [];
      plagasObjetivo = [];
    }
    setState(() {});
  }

  Future borrarAcciones() async {
    await _ptosInspeccionServices.deleteAcciones(context, orden, puntosSeleccionados, revisionId, token);
    statusCodeRevision = await _ptosInspeccionServices.getStatusCode();
    await _ptosInspeccionServices.resetStatusCode();
    if(statusCodeRevision == 1) {
      await PtosInspeccionServices.showDialogs(context, puntosSeleccionados.length == 1 ? 'Acción borrada' : 'Acciones borradas', true, false);
      await actualizarDatos();
    }
    statusCodeRevision = null;
  }

  Future postAcciones(List<RevisionPtoInspeccion> acciones) async {
    await _ptosInspeccionServices.postAcciones(context, orden, acciones, revisionId, token);
    statusCodeRevision = await _ptosInspeccionServices.getStatusCode();
    await _ptosInspeccionServices.resetStatusCode();
    if(statusCodeRevision == 1) {
      await actualizarDatos();
      await PtosInspeccionServices.showDialogs(context, acciones.length == 1 ? 'Acción creada' : 'Acciones creadas', true, false);
      
    }
    statusCodeRevision = null;
  }

  Future postTraslado(List<RevisionPtoInspeccion> acciones) async {
    await _ptosInspeccionServices.postAcciones(context, orden, acciones, revisionId, token);
    statusCodeRevision = await _ptosInspeccionServices.getStatusCode();
    await _ptosInspeccionServices.resetStatusCode();
    if(statusCodeRevision == 1) {
      await actualizarDatos();
      await PtosInspeccionServices.showDialogs(context, acciones.length == 1 ? 'Acción creada' : 'Acciones creadas', true, true);
      
    }
    statusCodeRevision = null;
  }

  Future borrarAccion() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: const Text('Confirmación'),
          content: const Text(
            'Se eliminará toda la información ingresada para los puntos seleccionados. Desea confirmar la acción?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if(!subiendoAcciones){
                  subiendoAcciones = true;
                  await borrarAcciones();
                  subiendoAcciones = false;
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      }
    );
  }
}