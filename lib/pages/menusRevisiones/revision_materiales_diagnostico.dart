// ignore_for_file: use_build_context_synchronously, avoid_init_to_null, void_checks
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/manuales_materiales.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_diagnostico_services.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class RevisionMaterialesDiagnositcoMenu extends StatefulWidget {
  final List<Materiales> materiales;
  List<RevisionMaterial> revisionMaterialesList;
  final RevisionOrden? revision;
  RevisionMaterialesDiagnositcoMenu({super.key, required this.materiales, required this.revisionMaterialesList, required this.revision });

  @override
  State<RevisionMaterialesDiagnositcoMenu> createState() => _RevisionMaterialesDiagnositcoMenuState();
}

class _RevisionMaterialesDiagnositcoMenuState extends State<RevisionMaterialesDiagnositcoMenu> {
  late List<String> savedData = [];
  List<Materiales> materiales = [];
  late List<Plaga> plagas = [];
  late List<Plaga> plagasSeleccionadas = [];
  late Materiales selectedMaterial = Materiales.empty();
  late String cantidad = '';
  late String comentario = '';
  late String token = '';
  late Materiales? materialInicial = null;
  late Orden orden = Orden.empty();
  final ScrollController _scrollController = ScrollController();
  late int marcaId = 0;
  bool isReadOnly = true;
  final TextEditingController comentarioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  late int revisionId = 0;
  late List<ManualesMateriales> manuales = [];
  bool cargoDatosCorrectamente = false;
  bool cargando = true;
  bool estaBuscando = false;
  bool borrando = false;
  bool agrengandoMaterial = false;
  int? statusCode;
  final materialesDiagnosticoServices = MaterialesDiagnosticoServices();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    try {
      orden = context.read<OrdenProvider>().orden;
      if (widget.materiales.isNotEmpty && widget.revisionMaterialesList.isNotEmpty){
        cargoDatosCorrectamente = true;
      }
      cargando = false;
    } catch (e) {
      cargando = false;
    }
    setState(() {});
  }

  Future<bool> _showMaterialDetails(BuildContext context, Materiales material) async {
    comentarioController.text = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          content: Column(
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
              CustomTextFormField(
                label: 'Cantidad',
                keyboard: TextInputType.number,
                onChanged: (value) {
                  cantidad = value;
                },
              ),
              const SizedBox(height: 16,),
              CustomTextFormField(
                controller: comentarioController,
                maxLines: 1,
                label: 'Comentario',
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
              onPressed: !agrengandoMaterial ? () async {
                agrengandoMaterial = true;
                setState(() {});
                final RevisionMaterial nuevaRevisionMaterial =
                  RevisionMaterial(
                    otMaterialId: 0,
                    ordenTrabajoId: orden.ordenTrabajoId,
                    otRevisionId: orden.otRevisionId,
                    cantidad: esNumerico(cantidad) ? double.parse(cantidad) : double.parse("0.0"),
                    comentario: comentarioController.text,
                    ubicacion: '',
                    areaCobertura: '',
                    plagas: [],
                    material: material,
                    lote: Lote.empty(),
                    metodoAplicacion: MetodoAplicacion.empty()
                  );
                await materialesDiagnosticoServices.postRevisionMaterial(context, orden, nuevaRevisionMaterial, revisionId, token);
                statusCode = await materialesDiagnosticoServices.getStatusCode();
                materialesDiagnosticoServices.resetStatusCode();
                if (statusCode == 1){
                  widget.revisionMaterialesList.add(nuevaRevisionMaterial);
                  statusCode = null;
                  setState(() {});
                }
                agrengandoMaterial = false;
              } : null,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (selectedMaterial.materialId != 0 && materiales.isNotEmpty) {
      materialInicial = materiales.firstWhere((material) => material.materialId == selectedMaterial.materialId);
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
      ) :
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: Constantes().ancho,
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: colors.primary),
                borderRadius: BorderRadius.circular(5)
              ),
              child: DropdownSearch(
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  textAlignVertical: TextAlignVertical.center,
                  dropdownSearchDecoration: InputDecoration(
                    hintText: 'Seleccione un material'
                  )
                ),
                items: materiales,
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
                  bool resultado = await _showMaterialDetails(context, selectedMaterial);
                  setState(() {
                    estaBuscando = resultado;
                  });
                },
              )
            ),
            const SizedBox(height: 20,),
            SizedBox(
              height: 540,
              width: Constantes().ancho,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(5)),
                    height: 30,
                    child: const Center(
                      child: Text(
                        'Materiales a utilizar:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 500,
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
                                  title: const Text("Confirmar"),
                                  content: const Text(
                                      "¿Estas seguro de querer borrar el material?"),
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
                                        await materialesDiagnosticoServices.deleteRevisionMaterial(context, orden, widget.revisionMaterialesList[i], revisionId, token);
                                        statusCode = await materialesDiagnosticoServices.getStatusCode();
                                        materialesDiagnosticoServices.resetStatusCode();
                                        if (statusCode == 1){
                                          Navigator.of(context).pop(true);
                                        }
                                      },
                                      child: const Text("BORRAR")),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            if (statusCode == 1 ){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$item borrado'),
                                )
                              );
                              setState(() {
                                widget.revisionMaterialesList.removeAt(i);
                              });
                            }
                            statusCode = null;
                          },
                          background: Container(
                            color: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20),
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
                                        if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text('No se puede modificar esta revisión.'),
                                          ));
                                          return Future.value(false);
                                        }
                                        setState(() {
                                          estaBuscando = true;
                                        });
                                        bool resultado = await editMaterial(context, item);
                                        setState(() {
                                          estaBuscando = resultado;
                                        });
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
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title:
                                                      const Text("Confirmar"),
                                                  content: const Text(
                                                      "¿Estas seguro de querer borrar el material?"),
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
                                                          await materialesDiagnosticoServices.deleteRevisionMaterial(context,orden,widget.revisionMaterialesList[i],revisionId,token);
                                                          statusCode = await materialesDiagnosticoServices.getStatusCode();
                                                          materialesDiagnosticoServices.resetStatusCode();
                                                          if (statusCode == 1){
                                                            setState(() {
                                                              widget.revisionMaterialesList.removeAt(i);
                                                            });
                                                          }
                                                          borrando = false;
                                                          statusCode = null;
                                                          setState(() {});
                                                        } : null,
                                                        child: const Text("BORRAR")),
                                                  ],
                                                );
                                              });
                                        },
                                        icon: const Icon(Icons.delete)),
                                  ],
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Material: ${widget.revisionMaterialesList[i].material.descripcion}'),
                                    Text('Unidad: ${widget.revisionMaterialesList[i].material.unidad}'),
                                    Text('Cantidad: ${widget.revisionMaterialesList[i].cantidad}'),
                                    Text('Comentario: ${widget.revisionMaterialesList[i].comentario}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder:
                          (BuildContext context, int index) {
                        return const Divider(
                          thickness: 2,
                          color: Colors.green,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }

  bool esNumerico(String str) {
    return double.tryParse(str) != null;
  }

  Future<void> verManual(BuildContext context, RevisionMaterial? item, Materiales? material) async {
    manuales = material == null ? await MaterialesServices().getManualesMateriales(context, item!.material.materialId, token) : await MaterialesServices().getManualesMateriales(context, material.materialId, token);
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

  editMaterial(BuildContext context, RevisionMaterial material) async {
    if(material.otMaterialId != 0){
      comentarioController.text = material.comentario;
      cantidadController.text = material.cantidad.toString();
    } else{
      comentarioController.text = '';
      cantidadController.text = '';
    }
    

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          content: SingleChildScrollView(
            child: Column(
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
                CustomTextFormField(
                  label: 'Cantidad',
                  controller: cantidadController,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 16,),
                CustomTextFormField(
                  controller: comentarioController,
                  minLines: 1,
                  maxLines: 5,
                  label: 'Comentario',
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
              child: const Text('Guardar'),
              onPressed: () async {
                comentario = comentarioController.text;
                cantidad = cantidadController.text;
                final RevisionMaterial nuevaRevisionMaterial =
                  RevisionMaterial(
                    otMaterialId: material.otMaterialId,
                    ordenTrabajoId: orden.ordenTrabajoId,
                    otRevisionId: orden.otRevisionId,
                    cantidad: esNumerico(cantidad) ? double.parse(cantidad) : double.parse("0.0"),
                    comentario: comentario,
                    ubicacion: '',
                    areaCobertura: '',
                    plagas: [],
                    material: material.material,
                    lote: Lote.empty(),
                    metodoAplicacion: MetodoAplicacion.empty()
                  );
                await materialesDiagnosticoServices.putRevisionMaterial(context, orden, nuevaRevisionMaterial, revisionId, token);
                statusCode = await materialesDiagnosticoServices.getStatusCode();
                await materialesDiagnosticoServices.resetStatusCode();
                if (statusCode == 1){
                  comentarioController.text = '';
                  cantidadController.text = '';
                  widget.revisionMaterialesList = await materialesDiagnosticoServices.getRevisionMateriales(context, orden, token);
                }
                statusCode = null;
                setState(() {});
                
              },
            ),
          ],
        );
      },
    );
  }
}
