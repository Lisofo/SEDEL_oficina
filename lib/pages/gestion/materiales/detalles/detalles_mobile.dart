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


class DetallesMaterialesMobile extends StatefulWidget {
  const DetallesMaterialesMobile({super.key});

  @override
  State<DetallesMaterialesMobile> createState() => _DetallesMaterialesMobileState();
}

class _DetallesMaterialesMobileState extends State<DetallesMaterialesMobile> {
  late Materiales materialSeleccionado = Materiales.empty();
  late String token = '';
  late List<MaterialDetalles> detalles = [];
  final MaterialDetalles detalleACrear = MaterialDetalles.empty();
  final TextEditingController principioController = TextEditingController();
  final TextEditingController concentracionController = TextEditingController();


  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    materialSeleccionado = context.read<OrdenProvider>().materiales;
    token = context.read<OrdenProvider>().token;
    detalles = await MaterialesServices().getDetalles(context, materialSeleccionado.materialId, token);

    setState(() {});

  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarMobile(titulo: 'Detalles del material'),
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
                    itemCount: detalles.length,
                    itemBuilder: (context,i){
                      var detalle = detalles[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(detalle.materialDetId.toString(), style: const TextStyle(color: Colors.white),),
                        ),
                        title: Text(detalle.principioActivo),
                        subtitle: Text(detalle.concentracion.toString()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: (){
                                nuevoDetalle(detalle);
                              }, 
                              icon: const Icon(Icons.edit),
                              tooltip: 'Editar',),
                            IconButton(
                              onPressed: (){
                                eliminarDetalle(detalle);
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
            await nuevoDetalle(detalleACrear);
          },
          child: Center(child: Text('Crear detalle', style: TextStyle(color: colors.primary),)),
        ),
      )
    );
  }

  nuevoDetalle(MaterialDetalles detalle) {
    if(detalle.materialDetId == 0){
      concentracionController.text = '';
      principioController.text = '';
    }else{
      concentracionController.text = detalle.concentracion.toString();
      principioController.text = detalle.principioActivo;
    }

    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: Text(detalle.materialDetId == 0 ? 'Nuevo detalle' : 'Editar detalle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                label: 'Principio activo',
                controller: principioController,
                hint: 'Ingrese el principio activo',
              ),
              const SizedBox(height: 20,),
              CustomTextFormField(
                label: 'Concentración',
                controller: concentracionController,
                hint: 'Ingrese la concentración',
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: (){
                if(detalle.materialDetId == 0){
                  creacionDetalle();
                }else{
                  edicionDetalle(detalle);
                }
              }, 
              child: const Text('Confirmar')),
          ],
        );
      });
  }

  creacionDetalle() async {
    var detalle = MaterialDetalles(
      materialDetId: 0, 
      principioActivo: principioController.text, 
      concentracion: double.parse(concentracionController.text));
        
    await MaterialesServices().postDetalle(context, materialSeleccionado.materialId, detalle, token);    
    await MaterialesServices.showDialogs(context, 'Detalle creado correctamente', true, false);
    detalles = await MaterialesServices().getDetalles(context, materialSeleccionado.materialId, token); 
      
    setState(() {});
  }

  edicionDetalle(MaterialDetalles detalle) async {
    var detalleAEditar = detalle;
    detalleAEditar.materialDetId = detalle.materialDetId;
    detalleAEditar.concentracion = double.parse(concentracionController.text);
    detalleAEditar.principioActivo = principioController.text;
        
    await MaterialesServices().putDetalle(context, materialSeleccionado.materialId, detalle, token);    
    await MaterialesServices.showDialogs(context, 'Detalle editado correctamente', true, false);
    detalles = await MaterialesServices().getDetalles(context, materialSeleccionado.materialId, token);

    setState(() {});
  }

  eliminarDetalle(MaterialDetalles detalle) async {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar detalle'),
          content: Text('Esta por eliminar el detalle ${detalle.principioActivo}, está seguro de querer borrarlo?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await MaterialesServices().deleteDetalle(context, materialSeleccionado.materialId, detalle, token);
                await MaterialesServices.showDialogs(context, 'Detalle borrado correctamente', true, false);

                detalles = await MaterialesServices().getDetalles(context, materialSeleccionado.materialId, token);
                setState(() {});
            }, child: const Text('Confirmar')),

          ],
        );
      },);
  }
}