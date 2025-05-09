// ignore_for_file: use_build_context_synchronously, avoid_init_to_null, void_checks

import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/manuales_materiales.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/services/plaga_services.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class RevisionMaterialesMenu extends StatefulWidget {
  final List<Materiales> materiales;
  List<RevisionMaterial> revisionMaterialesList;
  final RevisionOrden? revision;

  RevisionMaterialesMenu(
    {super.key, required this.materiales, required this.revisionMaterialesList, required this.revision});

  @override
  State<RevisionMaterialesMenu> createState() => _RevisionMaterialesMenuState();
}

class _RevisionMaterialesMenuState extends State<RevisionMaterialesMenu> {
  late List<String> savedData = [];
  List<MetodoAplicacion> metodosAplicacion = [];
  late List<Lote> lotes = [];
  late List<Plaga> plagas = [];
  late List<Plaga> plagasSeleccionadas = [];
  late Materiales selectedMaterial = Materiales.empty();
  late Lote? selectedLote = Lote.empty();
  late String cantidad = '';
  late String ubicacion = '';
  late String areaCobertura = '';
  late MetodoAplicacion? selectedMetodo;
  late String token = context.read<OrdenProvider>().token;
  late Materiales? materialInicial = null;
  late Orden orden = context.read<OrdenProvider>().orden;
  final ScrollController _scrollController = ScrollController();
  late int revisionId = 0;
  late List<ManualesMateriales> manuales = [];
  bool cargoDatosCorrectamente = false;
  bool cargando = true;
  int? statusCode;
  final _materialesServices = MaterialesServices();
  bool estaBuscando = false;
  bool borrando = false;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    try {
      if (widget.materiales.isNotEmpty){
        cargoDatosCorrectamente = true;
      }
      cargando = false;
    } catch (e) {
      cargando = false;
    }
    
    setState(() {});
  }

  Future<bool> _showMaterialDetails(BuildContext context, Materiales material) async {
    selectedMetodo = MetodoAplicacion.empty();
    selectedLote = Lote.empty();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            content: SizedBox(
              width: Constantes().ancho,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nombre: ${material.descripcion}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Text(
                    'Unidad: ${material.unidad}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: (){
                      verManual(context, null, material);
                    }, 
                    child: const Text('Ver Manuales', style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),)
                  ),
                  const SizedBox(height: 16),
                  const Text('* Cantidad:'),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      cantidad = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(lotes.isEmpty ? 'Lote:' : '* Lote:'),
                  DropdownSearch(
                    items: lotes,
                    onChanged: (newValue) {
                      setState(() {
                        selectedLote = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('* Método de Aplicación:'),
                  DropdownSearch(
                    items: metodosAplicacion,
                    onChanged: (newValue) {
                      setState(() {
                        selectedMetodo = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16,),
                  const Text('* Plagas:'),
                  DropdownSearch<Plaga>.multiSelection(
                    items: plagas,
                    popupProps: const PopupPropsMultiSelection.menu(
                      // showSelectedItems: true,
                      // disabledItemFn: (String s) => s.startsWith('I'),
                    ),
                    onChanged: (value) {
                      plagasSeleccionadas = (value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('* Ubicación:'),
                  TextField(
                    onChanged: (value) {
                      ubicacion = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Área de Cobertura:'),
                  TextField(
                    onChanged: (value) {
                      areaCobertura = value;
                    },
                  ),
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
                child: const Text('Guardar'),
                onPressed: () async {
                  bool noTieneLotes = false;
                  bool tieneLoteId = false;
                  if(lotes.isEmpty){
                    noTieneLotes = true;
                  } else{
                    if(selectedLote!.materialLoteId != 0){
                      tieneLoteId = true;
                    }
                  }
                  if(cantidad != '' && ubicacion != '' && plagasSeleccionadas.isNotEmpty && (noTieneLotes || tieneLoteId) && (metodosAplicacion.isNotEmpty && selectedMetodo!.metodoAplicacionId != 0)){
                    late List<int> plagasIds = [];
                    final RevisionMaterial nuevaRevisionMaterial =
                      RevisionMaterial(
                        otMaterialId: 0,
                        ordenTrabajoId: orden.ordenTrabajoId,
                        otRevisionId: orden.otRevisionId,
                        cantidad: esNumerico(cantidad) ? double.parse(cantidad) : double.parse("0.0"),//
                        comentario: '',
                        ubicacion: ubicacion,//
                        areaCobertura: areaCobertura,
                        plagas: plagasSeleccionadas,//
                        material: material,
                        lote: selectedLote!,//
                        metodoAplicacion: selectedMetodo!//
                      );
                    for (var i = 0; i < plagasSeleccionadas.length; i++) {
                      plagasIds.add(plagasSeleccionadas[i].plagaId);
                    }
                    await MaterialesServices().postRevisionMaterial(context, orden, plagasIds, nuevaRevisionMaterial, revisionId, token);
                    widget.revisionMaterialesList.add(nuevaRevisionMaterial);
                    setState(() {});
                  } else {
                    showDialog(
                      context: context, 
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Faltan campos por completar'),
                          actions: [
                            TextButton(onPressed: ()=> router.pop(), child: const Text('Cerrar'))
                          ],
                        );
                      }
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (selectedMaterial.materialId != 0 && widget.materiales.isNotEmpty) {
      materialInicial = widget.materiales.firstWhere((material) => material.materialId == selectedMaterial.materialId);
    }
    revisionId = context.read<OrdenProvider>().revisionId;

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
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            width: Constantes().ancho,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1, color: colors.primary),
                borderRadius: BorderRadius.circular(5)),
            child: DropdownSearch(
              enabled: !estaBuscando,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    textAlignVertical: TextAlignVertical.center,
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Seleccione un material'
                    )
                  ),
                  items: widget.materiales,
                  popupProps: const PopupProps.menu(
                    showSearchBox: true, searchDelay: Duration.zero
                  ),
                  onChanged: (newValue) async {
                    if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede modificar esta revisión.'),
                      ));
                      return Future.value(false);
                    }
                    setState(() {
                      selectedMaterial = newValue!;
                      estaBuscando = true;
                    });
                    try {
                      plagas = await PlagaServices().getPlagas(context, '', '', token);
                      lotes = await MaterialesServices().getLotes(context, selectedMaterial.materialId, true, token);
                      metodosAplicacion = await MaterialesServices().getMetodosAplicacion(context, '', '', token);  
                    } catch (e) {
                      plagas = [];
                      lotes = [];
                      metodosAplicacion = [];
                      estaBuscando = false;
                      setState(() {});
                    }
                    if(plagas.isNotEmpty && metodosAplicacion.isNotEmpty){
                      bool resultado = await _showMaterialDetails(context, selectedMaterial);
                      setState(() {
                        estaBuscando = resultado;
                      });
                    }
                  },
                )
          ),
          const SizedBox(height: 20,),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: Constantes().ancho,
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: widget.revisionMaterialesList.length,
              itemBuilder: (context, i) {
                final item = widget.revisionMaterialesList[i];
                return Dismissible(
                  key: Key(item.toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (DismissDirection direction) async {
                    if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede modificar esta revisión.'),
                      ));
                      return Future.value(false);
                    }
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          surfaceTintColor: Colors.white,
                          title: const Text("Confirmar"),
                          content: const Text("¿Estas seguro de querer borrar el material?"),
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
                                await _materialesServices.deleteRevisionMaterial(context, orden, widget.revisionMaterialesList[i], revisionId, token);
                                statusCode = await _materialesServices.getStatusCode();
                                await _materialesServices.resetStatusCode();
                                if(statusCode == 1) {
                                  Navigator.of(context).pop(true);
                                }
                              },
                              child: const Text("BORRAR")
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    if(statusCode == 1){
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('El material ${item.material.descripcion} ha sido borrado'),
                      ));
                      setState(() {
                        widget.revisionMaterialesList.removeAt(i);
                      });
                    }
                    statusCode = null;
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
                  child: SizedBox(
                    width: Constantes().ancho,
                    child: Card(
                      child: ListTile(
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: !estaBuscando ? () async {
                                estaBuscando = true;
                                setState(() {});
                                if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('No se puede modificar esta revisión.'),
                                  ));
                                  estaBuscando = false;
                                  return Future.value(false);
                                }
                                try {
                                  plagas = await PlagaServices().getPlagas(context, '', '', token);
                                  lotes = await MaterialesServices().getLotes(context, item.material.materialId, true, token);
                                  metodosAplicacion = await MaterialesServices().getMetodosAplicacion(context, '', '', token);
                                  estaBuscando = false;
                                  setState(() {});  
                                } catch (e) {
                                  plagas = [];
                                  lotes = [];
                                  metodosAplicacion = [];
                                  estaBuscando = false;
                                  setState(() {});
                                }
                                if(plagas.isNotEmpty && metodosAplicacion.isNotEmpty){
                                  bool resultado = await editMaterial(context, item);
                                  setState(() {
                                    estaBuscando = resultado;
                                  });
                                  
                                }
                                setState(() {});
                              } : null, 
                              icon: const Icon(Icons.edit)
                            ),
                            IconButton(
                              onPressed: () async {
                                if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('No se puede modificar esta revisión.'),
                                  ));
                                  return Future.value(false);
                                }
                                deleteMaterial(context, i);
                              },
                              icon: const Icon(Icons.delete)
                            ),
                          ],
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Material: ${widget.revisionMaterialesList[i].material.descripcion}'),
                            Text('Unidad: ${widget.revisionMaterialesList[i].material.unidad}'),
                            Text('Cantidad: ${widget.revisionMaterialesList[i].cantidad}'),
                            Text('Lote: ${widget.revisionMaterialesList[i].lote}'),
                            Text('Metodo de aplicacion: ${widget.revisionMaterialesList[i].metodoAplicacion}'),
                            Text('Ubicación: ${widget.revisionMaterialesList[i].ubicacion}'),
                            Text('Área de Cobertura: ${widget.revisionMaterialesList[i].areaCobertura}'),
                            Text('Plagas: ${widget.revisionMaterialesList[i].plagas}'),
                          ],
                        ),
                        onLongPress: () async {
                          await verManual(context, item, null);
                        },
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  thickness: 2,
                  color: Colors.green,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void deleteMaterial(BuildContext context, int i) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("¿Estas seguro de querer borrar el material?"),
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
                if(!borrando){
                  borrando = true;
                  await _materialesServices.deleteRevisionMaterial(context,orden,widget.revisionMaterialesList[i],revisionId,token);
                  statusCode = await _materialesServices.getStatusCode();
                  await _materialesServices.resetStatusCode();
                  if(statusCode == 1) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('El material ${widget.revisionMaterialesList[i].material.descripcion} ha sido borrado'),
                    ));
                    setState(() {
                      widget.revisionMaterialesList.removeAt(i);
                    });
                    router.pop();
                  }
                  statusCode = null;
                  borrando = false;
                }
              },
              child: const Text("BORRAR")
            ),
          ],
        );
      }
    );
  }

  Future<void> verManual(BuildContext context, RevisionMaterial? item, Materiales? material) async {
    try {
      manuales = material == null ? await _materialesServices.getManualesMateriales(context, item!.material.materialId, token) : await _materialesServices.getManualesMateriales(context, material.materialId, token);
    } catch (e) {
      print(e);
    }
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manuales'),
          content: SizedBox(
            height: 400,
            width: MediaQuery.of(context).size.width * 0.6,
            child: ListView.builder(
              itemCount: manuales.length,
              itemBuilder: (context, i) {
                var manual = manuales[i];
                return ListTile(
                  title: Text(manual.filename),
                  onTap: () {
                    launchURL(manual.filepath, token);
                  },
                );
              }
            ) 
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CERRAR"),
            ),
          ],
        );
      }
    );
  }

  bool esNumerico(String str) {
    return double.tryParse(str) != null;
  }

  launchURL(String url, String token) async {
    Dio dio = Dio();
    String link = url += '?authorization=$token';
    print(link);
    try {
      // Realizar la solicitud HTTP con el encabezado de autorización
      Response response = await dio.get(
        link,
        options: Options(
          headers: {
            'Authorization': 'headers $token',
          },
        ),
      );
      // Verificar si la solicitud fue exitosa (código de estado 200)
      if (response.statusCode == 200) {
        // Si la respuesta fue exitosa, abrir la URL en el navegador
        Uri uri = Uri.parse(url);
        await launchUrl(uri);
      } else {
        // Si la solicitud no fue exitosa, mostrar un mensaje de error
        print('Error al cargar la URL: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar errores de solicitud
      print('Error al realizar la solicitud: $e');
    }
  }

  Future <bool> editMaterial(BuildContext context, RevisionMaterial material) async {
    final TextEditingController ubicacionController = TextEditingController();
    final TextEditingController areaController = TextEditingController();
    final TextEditingController cantidadController = TextEditingController();
    if(material.otMaterialId != 0){
      selectedLote = material.lote;
      selectedMetodo = material.metodoAplicacion;
      ubicacionController.text = material.ubicacion;
      areaController.text = material.areaCobertura;
      cantidadController.text = material.cantidad.toString();
      plagasSeleccionadas = material.plagas;
    } else {
      selectedLote = Lote.empty();
      selectedMetodo = MetodoAplicacion.empty();
    }   

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            surfaceTintColor: Colors.white,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nombre: ${material.material.descripcion}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Unidad: ${material.material.unidad}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: (){
                    verManual(context, null, material.material);
                  }, 
                  child: const Text('Ver Manuales', style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),)
                ),
                const SizedBox(height: 16),
                const Text('* Cantidad:'),
                TextFormField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text(lotes.isEmpty ? 'Lote:' : '* Lote:'),
                DropdownSearch(
                  items: lotes,
                  selectedItem: selectedLote,
                  onChanged: (newValue) {
                    setState(() {
                      selectedLote = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('* Método de Aplicación:'),
                DropdownSearch(
                  items: metodosAplicacion,
                  selectedItem: selectedMetodo,
                  onChanged: (newValue) {
                    setState(() {
                      selectedMetodo = newValue;
                    });
                  },
                ),
                const SizedBox(height: 16,),
                const Text('* Plagas:'),
                DropdownSearch<Plaga>.multiSelection(
                  items: plagas,
                  selectedItems: material.plagas,
                  itemAsString: (Plaga p) => p.descripcion,
                  compareFn: (Plaga p1, Plaga p2) => p1.plagaId == p2.plagaId,
                  popupProps: const PopupPropsMultiSelection.menu(
                    showSelectedItems: true,
                  ),
                  onChanged: (value) {
                    plagasSeleccionadas = (value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('* Ubicación:'),
                TextFormField(
                  controller: ubicacionController,
                ),
                const SizedBox(height: 16),
                const Text('Área de Cobertura (m²-m³):'),
                TextFormField(
                  controller: areaController,
                )
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
                child: const Text('Guardar'),
                onPressed: () async {
                  ubicacion = ubicacionController.text;
                  areaCobertura = areaController.text;
                  cantidad = cantidadController.text;
                  bool noTieneLotes = false;
                  bool tieneLoteId = false;
                  if(lotes.isEmpty){
                    noTieneLotes = true;
                  } else{
                    if(selectedLote!.materialLoteId != 0){
                      tieneLoteId = true;
                    }
                  }
                  if(cantidad != '' && ubicacion != '' && plagasSeleccionadas.isNotEmpty && (noTieneLotes || tieneLoteId) && (metodosAplicacion.isNotEmpty && selectedMetodo!.metodoAplicacionId != 0)){
                    late List<int> plagasIds = [];
                    final RevisionMaterial nuevaRevisionMaterial =
                      RevisionMaterial(
                        otMaterialId: material.otMaterialId,
                        ordenTrabajoId: orden.ordenTrabajoId,
                        otRevisionId: orden.otRevisionId,
                        cantidad: esNumerico(cantidad) ? double.parse(cantidad) : double.parse("0.0"),//
                        comentario: '',
                        ubicacion: ubicacion,//
                        areaCobertura: areaCobertura,
                        plagas: plagasSeleccionadas,//
                        material: material.material,
                        lote: selectedLote!,//
                        metodoAplicacion: selectedMetodo!//
                      );
                    for (var i = 0; i < plagasSeleccionadas.length; i++) {
                      plagasIds.add(plagasSeleccionadas[i].plagaId);
                    }
                    await _materialesServices.putRevisionMaterial(context, orden, plagasIds, nuevaRevisionMaterial, revisionId, token);
                    statusCode = await _materialesServices.getStatusCode();
                    await _materialesServices.resetStatusCode();
                    if(statusCode == 1){
                      selectedLote = Lote.empty();
                      selectedMetodo = MetodoAplicacion.empty();
                      ubicacionController.text = '';
                      areaController.text = '';
                      cantidadController.text = '';
                      widget.revisionMaterialesList = await _materialesServices.getRevisionMateriales(context, orden, revisionId, token);
                      plagas = [];
                      lotes = [];
                      metodosAplicacion = [];
                    }                   
                    setState(() {});
                  } else {
                    showDialog(
                      context: context, 
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Faltan campos por completar'),
                          actions: [
                            TextButton(onPressed: ()=> router.pop(), child: const Text('Cerrar'))
                          ],
                        );
                      }
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
    return false;
  }
}
