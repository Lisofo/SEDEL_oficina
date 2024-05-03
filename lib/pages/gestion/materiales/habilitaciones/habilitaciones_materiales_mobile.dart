// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

import '../../../../config/router/app_router.dart';

class HabilitacionesMaterialMobile extends StatefulWidget {
  const HabilitacionesMaterialMobile({super.key});

  @override
  State<HabilitacionesMaterialMobile> createState() => _HabilitacionesMaterialMobileState();
}

class _HabilitacionesMaterialMobileState extends State<HabilitacionesMaterialMobile> {
  late Materiales materialSeleccionado = Materiales.empty();
  late String token = '';
  late List<MaterialHabilitacion> habilitaciones = [];
  final MaterialHabilitacion habilitacionACrear = MaterialHabilitacion.empty();
  final TextEditingController habilitacionController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();


   @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    materialSeleccionado = context.read<OrdenProvider>().materiales;
    token = context.read<OrdenProvider>().token;
    habilitaciones = await MaterialesServices().getHabilitaciones(context, materialSeleccionado.materialId, token);

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarMobile(titulo: 'Habilitaciones del material'),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: Constantes().ancho,
                  child: ListView.separated(
                    itemCount: habilitaciones.length,
                    itemBuilder: (context,i){
                      var habilitacion = habilitaciones[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(habilitacion.materialHabId.toString(), style: const TextStyle(color: Colors.white),),
                        ),
                        title: Text(habilitacion.habilitacion),
                        subtitle: Text(habilitacion.estado),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: (){
                                nuevaHabilitacion(habilitacion);
                              }, 
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',),
                            IconButton(
                              onPressed: (){
                                eliminarHabilitacion(habilitacion);
                              }, 
                              icon: const Icon(Icons.delete, color: Colors.red,),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: colors.primary,
                        thickness: 3,
                      );
                    },),
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary)
        ),
        height: MediaQuery.of(context).size.height *0.1,
        child: InkWell(
          onTap: () async {
            await nuevaHabilitacion(habilitacionACrear);
          },
          child: Center(child: Text('Crear habilitación', style: TextStyle(color: colors.primary),)),
        ),
      )
    );
  }

  nuevaHabilitacion(MaterialHabilitacion habilitacion) {
    if(habilitacion.materialHabId == 0){
      habilitacionController.text = '';
      estadoController.text = '';
    }else{
      habilitacionController.text = habilitacion.habilitacion;
      estadoController.text = habilitacion.estado;
    }

    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: Text(habilitacion.materialHabId == 0 ? 'Nueva habilitación' : 'Editar habilitación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                label: 'Habilitación',
                controller: habilitacionController,
                hint: 'Ingrese habilitación',
              ),
              const SizedBox(height: 20,),
              CustomTextFormField(
                label: 'Estado',
                controller: estadoController,
                hint: 'Ingrese estado',
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: (){
                if(habilitacion.materialHabId == 0){
                  creacionHabilitacion();
                }else{
                  edicionHabilitacion(habilitacion);
                }
              }, 
              child: const Text('Confirmar')),
          ],
        );
      });
  }

  creacionHabilitacion() async {
    var habilitacion = MaterialHabilitacion(
      materialHabId: 0, 
      habilitacion: habilitacionController.text, 
      estado: estadoController.text);
        
    await MaterialesServices().postHabilitacion(context, materialSeleccionado.materialId, habilitacion, token);    
    await MaterialesServices.showDialogs(context, 'Habilitación creada correctamente', true, false);
    habilitaciones = await MaterialesServices().getHabilitaciones(context, materialSeleccionado.materialId, token); 
      
    setState(() {});
  }

  edicionHabilitacion(MaterialHabilitacion habilitacion) async {
    var habilitacionAEditar = habilitacion;
    habilitacionAEditar.materialHabId = habilitacion.materialHabId;
    habilitacionAEditar.habilitacion = habilitacionController.text;
    habilitacionAEditar.estado = estadoController.text;
        
    await MaterialesServices().putHabilitacion(context, materialSeleccionado.materialId, habilitacion, token);    
    await MaterialesServices.showDialogs(context, 'Habilitación editada correctamente', true, false);
    habilitaciones = await MaterialesServices().getHabilitaciones(context, materialSeleccionado.materialId, token);

    setState(() {});
  }

  eliminarHabilitacion(MaterialHabilitacion habilitacion) async {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar habilitación'),
          content: Text('Esta por eliminar la habilitación ${habilitacion.habilitacion}, está seguro de querer borrarla?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await MaterialesServices().deleteHabilitacion(context, materialSeleccionado.materialId, habilitacion, token);
                await MaterialesServices.showDialogs(context, 'Habilitación borrada correctamente', true, false);

                habilitaciones = await MaterialesServices().getHabilitaciones(context, materialSeleccionado.materialId, token);
                setState(() {});
            }, child: const Text('Confirmar')),

          ],
        );
      },);
  }
}