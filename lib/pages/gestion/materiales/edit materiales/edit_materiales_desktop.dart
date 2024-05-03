// ignore_for_file: avoid_print, use_build_context_synchronously, avoid_web_libraries_in_flutter, avoid_init_to_null

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/manuales_materiales.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../widgets/appbar_desktop.dart';
import '../../../../widgets/drawer.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:crypto/crypto.dart';



class EditMaterialesPageDesktop extends StatefulWidget {
  const EditMaterialesPageDesktop({super.key});

  @override
  State<EditMaterialesPageDesktop> createState() => _EditMaterialesPageDesktopState();
}

class _EditMaterialesPageDesktopState extends State<EditMaterialesPageDesktop> {
  final _materialesServices = MaterialesServices();
  final _codMaterialController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _dosisController = TextEditingController();
  final _unidadController = TextEditingController();
  final _favProbController = TextEditingController();
  final _enAppTecnicoController = TextEditingController();
  final _enUsoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool filtro = false;
  bool filtro2 = false;
  late Materiales materialSeleccionado = Materiales.empty();
  late String token = '';
  late List<ManualesMateriales> manuales = [];
  String _md5Hash = '';
  late Uint8List? manualSeleccionado = null;
  late String? fileName = '';

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    materialSeleccionado = context.read<OrdenProvider>().materiales;
    token = context.read<OrdenProvider>().token;
    if(materialSeleccionado.materialId != 0){
      manuales = await MaterialesServices().getManualesMateriales(context, materialSeleccionado.materialId, token);
    } else {
      manuales = [];
    }
    setState(() {});
  }

  @override
  void dispose() {
    _codMaterialController.dispose();
    _descripcionController.dispose();
    _dosisController.dispose();
    _unidadController.dispose();
    _favProbController.dispose();
    _enAppTecnicoController.dispose();
    _enUsoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    cargarValoresDeCampo(materialSeleccionado);

    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Materiales',),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Codigo  "),
                          const SizedBox(
                            width: 27,
                          ),
                          SizedBox(
                            width: 300,
                            child: CustomTextFormField(
                              maxLines: 1,
                              label: 'Codigo',
                              controller: _codMaterialController,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text("Descripcion  "),
                          SizedBox(
                            width: 500,
                            child: CustomTextFormField(
                              label: 'Descripcion',
                              maxLines: 1,
                              controller: _descripcionController,
                              maxLength: 100,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text("Dosis  "),
                          const SizedBox(
                            width: 40,
                          ),
                          SizedBox(
                            width: 800,
                            child: CustomTextFormField(
                              label: 'Dosis',
                              maxLines: 1,
                              controller: _dosisController,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text("Unidad  "),
                          const SizedBox(
                            width: 35,
                          ),
                          SizedBox(
                            width: 300,
                            child: CustomTextFormField(
                              label: 'Unidad',
                              maxLines: 1,
                              controller: _unidadController,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text("Fabricante/Proveedor  "),
                          const SizedBox(
                            width: 35,
                          ),
                          SizedBox(
                            width: 300,
                            child: CustomTextFormField(
                              label: 'Fabricante/Proveedor',
                              maxLines: 1,
                              controller: _favProbController,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text('En App Tecnico'),
                          Switch(
                            activeColor: colors.primary,
                            value: materialSeleccionado.enAppTecnico == 'S',
                            onChanged: (value) {
                              setState(() {
                                filtro = value;
                                establecerValoresDeCampo(materialSeleccionado);
                                value ? materialSeleccionado.enAppTecnico = 'S' : materialSeleccionado.enAppTecnico = 'N';
                              });
                            }
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text('En uso'),
                          Switch(
                            activeColor: colors.primary,
                            value: materialSeleccionado.enUso == 'S' ? filtro2 = true : filtro2 = false,
                            onChanged: (value) {
                              setState(() {
                                filtro2 = value;
                                value ? materialSeleccionado.enUso = 'S' : materialSeleccionado.enUso = 'N';
                                establecerValoresDeCampo(materialSeleccionado);
                              });
                            }
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(text: 'Subir PDF', onPressed: () async {await _uploadPdf();})
                        ],
                      ),
                    ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    height: 400,
                    width: 300,
                    child: ListView.builder(
                      itemCount: manuales.length,
                      itemBuilder: (context, i){
                        var manual = manuales[i];
                        return ListTile(
                          // leading: Text('$i'),
                          title: Text(manual.filename),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await launchURL(manual.filepath, token);
                                }, 
                                icon: const Icon(Icons.open_in_browser)
                              ),
                              IconButton(
                                onPressed: () async {
                                  await borrarManual(manual.filename);
                                }, 
                                icon: const Icon(Icons.delete, color: Colors.red,)
                              ),
                            ],
                          ),
                        );
                      }
                    )
                  )
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if(materialSeleccionado.materialId != 0)...[
                CustomButton(
                text: 'Habilitaciones', 
                onPressed: (){
                  router.push('/habilitacionesMaterial');
                }, 
                tamano: 20,
              ),
              const SizedBox(width: 30,),
              CustomButton(
                text: 'Detalles', 
                onPressed: (){
                  router.push('/detallesMaterial');
                }, 
                tamano: 20,
              ),
              const SizedBox(width: 30,),
              CustomButton(
                text: 'Lotes', 
                onPressed: (){
                  router.push('/lotes');
                }, 
                tamano: 20,
              ),
              const SizedBox(width: 30,),
              ],                          
              CustomButton(
                onPressed: () async {
                  await postPut(context);
                },
                text: 'Guardar',
                tamano: 20,
              ),
              if(materialSeleccionado.materialId != 0)...[
                const SizedBox(width: 30,),
                CustomButton(
                  onPressed: () async {
                    await borrarMaterial(materialSeleccionado);
                  },
                  text:'Eliminar',
                  tamano: 20,
                ),
              ]
            ]
          )
        )
      ),
    );
  }

  void cargarValoresDeCampo(Materiales materialSeleccionado) {
    _codMaterialController.text = materialSeleccionado.codMaterial;
    _descripcionController.text = materialSeleccionado.descripcion;
    _dosisController.text = materialSeleccionado.dosis;
    _unidadController.text = materialSeleccionado.unidad;
    _favProbController.text = materialSeleccionado.fabProv;
    _enAppTecnicoController.text = materialSeleccionado.enAppTecnico;
    _enUsoController.text = materialSeleccionado.enUso;
  }

  void establecerValoresDeCampo(Materiales materialSeleccionado) {
    materialSeleccionado.codMaterial = _codMaterialController.text;
    materialSeleccionado.descripcion = _descripcionController.text;
    materialSeleccionado.dosis = _dosisController.text;
    materialSeleccionado.unidad = _unidadController.text;
    materialSeleccionado.fabProv = _favProbController.text;
  }

  borrarMaterial(Materiales material) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar material'),
          content: Text('Esta por borrar el material ${material.descripcion}, esta seguro de querer borrarlo?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await _materialesServices.deleteMaterial(context, materialSeleccionado, token);
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    establecerValoresDeCampo(materialSeleccionado);
    if (materialSeleccionado.materialId != 0) {
      _materialesServices.putMaterial(context, materialSeleccionado, token);
    } else {
      _materialesServices.postMaterial(context, materialSeleccionado, token);
    }
    setState(() {});
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

  Future<void> _uploadPdf() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'application/pdf';
    input.click();

    input.onChange.listen((e) async {
      final files = input.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(
            files[0]); // Leer el archivo como una matriz de bytes
        reader.onLoadEnd.listen((e) {
          setState(() {
            // Asignar los bytes del archivo a pdfBytes
            manualSeleccionado = reader.result as Uint8List?;
            fileName = files[0].name;
            // Calcular el MD5 del archivo
            _md5Hash = calculateMD5(manualSeleccionado!);
            print('MD5 del archivo: $_md5Hash');

            // Llamar a la función para subir el PDF al servidor
            uploadPDFtoApi();
          });
        });
      }
    });
  }

  Future<void> uploadPDFtoApi() async {
    if (manualSeleccionado != null) {
      await MaterialesServices().postManualesMateriales(context, materialSeleccionado.materialId, token, manualSeleccionado, fileName, _md5Hash);
      manuales = await MaterialesServices().getManualesMateriales(context, materialSeleccionado.materialId, token);
    }
    setState(() {});
  }
  
  String calculateMD5(List<int> bytes) {
    var md5c = md5.convert(bytes);
    return md5c.toString();
  }

  borrarManual(String manual) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar manual'),
          content: Text('Esta por borrar el manual $manual, esta seguro de querer borrarlo?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await MaterialesServices().deleteManualesMateriales(context, materialSeleccionado.materialId, token, manual);
                manuales = await MaterialesServices().getManualesMateriales(context, materialSeleccionado.materialId, token);
                setState(() {});
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }
  
}
