// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/control_orden.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/orden_control_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class RevisionCuestionarioMenu extends StatefulWidget {
  const RevisionCuestionarioMenu({super.key});

  @override
  State<RevisionCuestionarioMenu> createState() => _RevisionCuestionarioMenuState();
}

class _RevisionCuestionarioMenuState extends State<RevisionCuestionarioMenu> {
  String selectedPregunta = '';
  final TextEditingController comentarioController = TextEditingController();
  late Orden orden = Orden.empty();

  List<ControlOrden> controles =[];
  String token = '';
  List<String> grupos = [];
  List<ControlOrden> preguntasFiltradas = [];
  List<String> models = [];
  late int revisionId = 0;


  

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    orden = context.read<OrdenProvider>().orden;
    revisionId = context.read<OrdenProvider>().revisionId;
    controles = await OrdenControlServices().getControlOrden(context, orden, token);
    
    for(var i = 0; i < controles.length; i++){
      models.add(controles[i].grupo);
    }
    Set<String> conjunto = Set.from(models);
    grupos = conjunto.toList();

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container( 
              width: Constantes().ancho,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 2, color: colors.primary),
                  borderRadius: BorderRadius.circular(5)),
              child: DropdownButtonFormField(
                decoration: const InputDecoration(border: InputBorder.none),
                items: grupos.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: FittedBox(
                      child: Text(
                        e,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }).toList(),
                isDense: true,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedPregunta = value!;
                    preguntasFiltradas = controles.where((objeto) => objeto.grupo == selectedPregunta).toList();
                    for (var element in preguntasFiltradas) {element.pregunta;}
                  });
                },
              ),
            ),
            SizedBox(
              height: 500,
              width: Constantes().ancho,
              child: ListView.separated(
              itemCount: preguntasFiltradas.length,
              itemBuilder: (context, i) {
                final ControlOrden pregunta = preguntasFiltradas[i];
                List<bool> selections = List.generate(3, (_) => false);
    
                if(pregunta.respuesta.isNotEmpty){
                  if(pregunta.respuesta == 'APRUEBA'){
                    selections[0] = true;
                  }else if(pregunta.respuesta == 'DESAPRUEBA'){
                    selections[1] = true;
                  }else if(pregunta.respuesta == 'NO APLICA'){
                    selections[2] = true;
                  }
                }
                return SizedBox(
                  width: Constantes().ancho,
                  child: ListTile(
                    title: Row(
                      children: [
                        Flexible(
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Text(pregunta.pregunta)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            popUpComentario(context, pregunta);
                          }
                        ),
                      ],
                    ),
                    subtitle: Center(
                      child: ToggleButtons(
                        isSelected: selections,
                        borderColor: colors.primary,
                        selectedBorderColor: colors.primary,
                        borderWidth: 2,
                        borderRadius: BorderRadius.circular(5),
                        fillColor: colors.primary,
                        onPressed: (i){
                          setState(() {
                            
                            selections[0] = false;
                            selections[1] = false;
                            selections[2] = false;
                      
                            selections[i] = true;
                            pregunta.respuesta = selections[0] ? 'APRUEBA' : selections[1] ? 'DESAPRUEBA' : 'NO APLICA';
                          });
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text('APRUEBA', style: TextStyle(fontSize: 14, color: selections[0] ? Colors.white : Colors.black),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text('DESAPRUEBA', style: TextStyle(fontSize: 14, color: selections[1] ? Colors.white : Colors.black),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text('NO APLICA', style: TextStyle(fontSize: 14, color: selections[2] ? Colors.white : Colors.black),),
                          ),
                        ],  
                      ),
                    )
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(
                  thickness: 3,
                  color: Colors.green,
                );
              },
            )
          ),
            BottomAppBar(
              elevation: 0,
              color: Colors.transparent,
              child: CustomButton(
                onPressed: () async {
                  await postPut(context);
                },
                text: 'Guardar',
                tamano: 20,
              ),
            ),
          ],
        ),
      );
    //   bottomNavigationBar: BottomAppBar(
    //     notchMargin: 10,
    //     elevation: 0,
    //     shape: const CircularNotchedRectangle(),
    //     color: Colors.grey.shade200,
    //     child: CustomButton(
    //       onPressed: () async {
    //         await postPut(context);
    //       },
    //       text: 'Guardar',
    //       tamano: 20,
    //     ),
    //   ),
    //   backgroundColor: Colors.grey.shade200,
    // );
  }

  Future<void> postPut(BuildContext context) async {
    for(var i = 0; i < controles.length; i++){
      if(controles[i].controlRegId == 0 && controles[i].respuesta.isNotEmpty){
        await OrdenControlServices().postControl(context, orden, controles[i], token);
      }else{
        await OrdenControlServices().putControl(context, orden, controles[i], token);
      }
    }
    await OrdenControlServices.showDialogs(context, 'Controles actualizados correctamente', false, false);
    setState(() {});
  }

  void popUpComentario(BuildContext context, ControlOrden pregunta) {
    if(pregunta.controlRegId != 0){
      comentarioController.text = pregunta.comentario;
    }else{comentarioController.text = '';}


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Observaciones'),
          content: CustomTextFormField(
            controller: comentarioController,
            label: 'Comentario',
            minLines: 1,
            maxLines: 20,
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
              onPressed: () {
                pregunta.comentario = comentarioController.text;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  Widget buildSegment(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}