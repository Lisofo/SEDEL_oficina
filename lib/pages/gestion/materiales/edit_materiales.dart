import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import '../../../widgets/appbar_desktop.dart';
import '../../../widgets/drawer.dart';

class EditMaterialesPage extends StatefulWidget {
  const EditMaterialesPage({super.key});

  @override
  State<EditMaterialesPage> createState() => _EditMaterialesPageState();
}

class _EditMaterialesPageState extends State<EditMaterialesPage> {
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

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos(){
    materialSeleccionado = context.read<OrdenProvider>().materiales;
    token = context.read<OrdenProvider>().token;
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
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
                            value
                                ? materialSeleccionado.enAppTecnico = 'S'
                                : materialSeleccionado.enAppTecnico = 'N';
                          });
                        }
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Text('En uso'),
                      Switch(
                        activeColor: colors.primary,
                        value: materialSeleccionado.enUso == 'S'
                            ? filtro2 = true
                            : filtro2 = false,
                        onChanged: (value) {
                          setState(() {
                            filtro2 = value;
                            value
                                ? materialSeleccionado.enUso = 'S'
                                : materialSeleccionado.enUso = 'N';
                            establecerValoresDeCampo(materialSeleccionado);
                          });
                        }
                      ),
                    ],
                  ),
                  const Spacer(),
                  BottomAppBar(
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
                  )
                ],
              ),
            ),
          ),
        ),
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
}
