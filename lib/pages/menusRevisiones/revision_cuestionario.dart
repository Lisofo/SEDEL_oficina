// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/control_orden.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/orden_control_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class RevisionCuestionarioMenu extends StatefulWidget {
  final RevisionOrden? revision;
  final List<ControlOrden> controles;
  const RevisionCuestionarioMenu({super.key, required this.revision, required this.controles});

  @override
  State<RevisionCuestionarioMenu> createState() => _RevisionCuestionarioMenuState();
}

class _RevisionCuestionarioMenuState extends State<RevisionCuestionarioMenu> {
  String selectedPregunta = '';
  final TextEditingController comentarioController = TextEditingController();
  late Orden orden = Orden.empty();
  String token = '';
  List<String> grupos = [];
  List<ControlOrden> preguntasFiltradas = [];
  List<String> models = [];
  late int revisionId = 0;
  final _ordenControlServices = OrdenControlServices();
  int? statusCodeControles;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    orden = context.read<OrdenProvider>().orden;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    for(var i = 0; i < widget.controles.length; i++){
      models.add(widget.controles[i].grupo);
    }
    Set<String> conjunto = Set.from(models);
    grupos = conjunto.toList();
    grupos.sort((a, b) => a.compareTo(b));
    preguntasFiltradas = widget.controles.where((objeto) => objeto.grupo == selectedPregunta).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container( 
            width: Constantes().ancho,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2, color: colors.primary
              ),
              borderRadius: BorderRadius.circular(5)
            ),
            child: DropdownButtonFormField(
              decoration: const InputDecoration(border: InputBorder.none),
              hint: const Text('Seleccione un grupo de controles', textAlign: TextAlign.center,),
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
                  preguntasFiltradas = widget.controles.where((objeto) => objeto.grupo == selectedPregunta).toList();
                  for (var element in preguntasFiltradas) {element.pregunta;}
                });
              },
            ),
          ),
          SizedBox(
            height: 340,
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
                          child: Text(pregunta.pregunta)
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.comment,
                          color: pregunta.comentario == '' ? Colors.black : colors.secondary,
                        ),
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
                      onPressed: (i) async {
                        if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('No se puede modificar esta revisión.'),
                          ));
                          return Future.value(false);
                        }
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
                if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No se puede modificar esta revisión.'),
                  ));
                  return Future.value(false);
                }
                await postControles(context);
              },
              text: 'Guardar',
              tamano: 20,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> postControles(BuildContext context) async {  
    List<ControlOrden> controlesSeleccionados = [];
    for(var control in widget.controles) {
      if(control.respuesta.isNotEmpty){
        controlesSeleccionados.add(control);
      }
    }    
    await _ordenControlServices.postControles(context, orden, controlesSeleccionados, revisionId, token);
    statusCodeControles = await _ordenControlServices.getStatusCode();
    await _ordenControlServices.resetStatusCode();
    if(statusCodeControles == 1){
      await OrdenControlServices.showDialogs(context, 'Controles actualizados correctamente', false, false);
    }    
    setState(() {});
    statusCodeControles = null;
  }

  void popUpComentario(BuildContext context, ControlOrden pregunta) {
    if(pregunta.controlRegId != 0 || pregunta.comentario != ''){
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
                setState(() {});
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