// ignore_for_file: avoid_init_to_null, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class LotesPageDesktop extends StatefulWidget {
  const LotesPageDesktop({super.key});

  @override
  State<LotesPageDesktop> createState() => _LotesPageDesktopState();
}

class _LotesPageDesktopState extends State<LotesPageDesktop> {
  late List<Lote> lotes = [];
  late String token = '';
  late Materiales materialSeleccionado = Materiales.empty();
  final TextEditingController loteController = TextEditingController();
  List<String> estados = [
    'Activo', 
    'Inactivo'
  ];
  late String? estadoSeleccionado = null;
  Lote loteACrear = Lote.empty();


  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    materialSeleccionado = context.read<OrdenProvider>().materiales;
    token = context.read<OrdenProvider>().token;
    lotes =  await MaterialesServices().getLotes(context, materialSeleccionado.materialId, token);
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Lotes'),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Card(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 500,
                width: Constantes().ancho,
                child: ListView.separated(
                  itemCount: lotes.length,
                  itemBuilder: (context, i){
                    var lote = lotes[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:  colors.primary,
                        child: Text(lote.materialLoteId.toString(), style: const TextStyle(color: Colors.white),)),
                      title: Text(lote.lote),
                      subtitle: Text(lote.estado == 'A' ? 'Activo' : 'Inactivo'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: colors.primary,),
                            onPressed: (){
                              crearLote(lote);
                            },
                            tooltip: 'Editar lote',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,color: Colors.red,),
                            onPressed: (){
                              eliminarLote(lote);
                            },
                            tooltip: 'Eliminar lote',
                          ),
                          
                        ],
                      ),
                    );
                  }, 
                  separatorBuilder: (context, i) {
                    return Divider(
                      thickness: 3,
                      color: colors.primary,
                    );
                  },
                )
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              text: 'Crear lote',
              tamano: 20,
              onPressed: () async {
                await crearLote(loteACrear);
              },
            ),
          ],
        ),
      ),
    );
  }

  crearLote(Lote lote){
    if(lote.materialLoteId == 0){
      loteController.text = '';
      estadoSeleccionado = null;
    }else{
      loteController.text = lote.lote;
      estadoSeleccionado = lote.estado == 'A' ? 'Activo' : 'Inactivo';
    }

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(lote.materialLoteId == 0 ? 'Nuevo lote' : 'Editar lote'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                label: 'Lote',
                controller: loteController,
                hint: 'Escriba el lote del material',
              ),
              const SizedBox(height: 20,),
              CustomDropdownFormMenu(
                value: estadoSeleccionado,
                items: estados.map((e) 
                  => DropdownMenuItem(
                    value: e,
                    child: Text(e)
                )).toList(),
                hint: 'Seleccione el estado',
                onChanged: (value){
                  estadoSeleccionado = value;
                }
              )
            ],
          ),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: (){
                if(lote.materialLoteId == 0){
                  creacionLote();
                }else{
                  edicionLote(lote);
                }
              }, 
              child: const Text('Confirmar')),
          ],
        );
      },);
  }

  creacionLote() async {
    var lote = Lote(
        materialLoteId: 0, 
        lote: loteController.text, 
        estado: estadoSeleccionado == 'Activo' ? 'A' : 'I');
        
    await MaterialesServices().postLote(context, materialSeleccionado.materialId, lote, token);    
    await MaterialesServices.showDialogs(context, 'Lote creado correctamente', true, false);
    lotes = await MaterialesServices().getLotes(context, materialSeleccionado.materialId, token); 
      
    setState(() {});
  }

  edicionLote(Lote lote) async {
    var loteAEditar = lote;
    loteAEditar.lote = loteController.text;
    loteAEditar.materialLoteId = lote.materialLoteId;
    loteAEditar.estado = estadoSeleccionado == 'Activo' ? 'A' : 'I';
        
    await MaterialesServices().putLote(context, materialSeleccionado.materialId, lote, token);    
    await MaterialesServices.showDialogs(context, 'Lote editado correctamente', true, false);
    lotes = await MaterialesServices().getLotes(context, materialSeleccionado.materialId, token);

    setState(() {});
  }

  eliminarLote(Lote lote) async {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar lote'),
          content: Text('Esta por eliminar el lote ${lote.lote}, está seguro de querer borrarlo?'),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await MaterialesServices().deleteLote(context, materialSeleccionado.materialId, lote, token);
                await MaterialesServices.showDialogs(context, 'Lote borrado correctamente', true, false);

                lotes = await MaterialesServices().getLotes(context, materialSeleccionado.materialId, token);
                setState(() {});
            }, child: const Text('Confirmar')),

          ],
        );
      },);
  }
}