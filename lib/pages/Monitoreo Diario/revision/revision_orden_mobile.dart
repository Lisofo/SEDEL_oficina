// ignore_for_file: use_build_context_synchronously, unused_element
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/observacion.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_tarea.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/ptosInspeccion/revision_ptos_inspeccion_mobile.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_cuestionario.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_firmas.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_materiales_diagnostico.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_observaciones.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_plagas.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_tareas.dart';
import 'package:sedel_oficina_maqueta/pages/menusRevisiones/revision_validacion.dart';
import 'package:sedel_oficina_maqueta/provider/menu_provider.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/services/plaga_services.dart';
import 'package:sedel_oficina_maqueta/services/ptos_services.dart';
import 'package:sedel_oficina_maqueta/services/revision_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/icons.dart';
import 'package:sedel_oficina_maqueta/models/revision_pto_inspeccion.dart';

import '../../../models/clientesFirmas.dart';


class RevisionOrdenMobile extends StatefulWidget {
  const RevisionOrdenMobile({super.key});

  @override
  State<RevisionOrdenMobile> createState() => _RevisionOrdenMobileState();
}

class _RevisionOrdenMobileState extends State<RevisionOrdenMobile> with SingleTickerProviderStateMixin {
  final TextEditingController comentarioController = TextEditingController();
  late Orden orden = Orden.empty();
  late AnimationController _animationController;
  late List<Plaga> plagas = [];
  late List<Materiales> materiales = [];
  late List<RevisionMaterial> revisionMaterialesList = [];
  late List<RevisionTarea> revisionTareasList = [];
  late List<RevisionPlaga> revisionPlagasList = [];
  late List<Observacion> observaciones = [];
  late Observacion observacion = Observacion.empty();
  late int revisionId = 0;
  late List<RevisionPtoInspeccion> ptosInspeccion = [];
  late String token = '';
  late String menu = '';
  List<RevisionOrden> revisiones = [];
  int selectedIndex = 0;
  RevisionOrden? selectedRevision = RevisionOrden.empty();
  late List<ClienteFirma> firmas = [];
  bool filtro = false;
  int buttonIndex = 0;
  String valorComentario = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    cargarDatos();
  }

  cargarDatos() async {
    orden = context.read<OrdenProvider>().orden;
    revisionId = orden.otRevisionId;
    token = context.read<OrdenProvider>().token;
    plagas = await PlagaServices().getPlagas(context, '', '', token);
    materiales = await MaterialesServices().getMateriales(context, '', '', token);
    revisionMaterialesList = await MaterialesServices().getRevisionMateriales(context, orden, revisionId, token);
    revisionTareasList = await RevisionServices().getRevisionTareas(context, orden, revisionId, token);
    revisionPlagasList = await RevisionServices().getRevisionPlagas(context, orden, revisionId, token);
    observaciones = await RevisionServices().getObservacion(context, orden, observacion, revisionId, token);
    ptosInspeccion = await PtosInspeccionServices().getPtosInspeccion(context, orden, revisionId, token);
    firmas = await RevisionServices().getRevisionFirmas(context, orden, revisionId, token);
    revisiones = await RevisionServices().getRevision(context, orden, token);
    observacion = observaciones.isNotEmpty ? observaciones[0] : Observacion.empty();
    Provider.of<OrdenProvider>(context, listen: false).setRevisionId(revisionId);

    setState(() {});
    
  }

  void toggleMapWidth() {
    if (_animationController.isDismissed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Revisión orden ${orden.ordenTrabajoId}'),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: _listaItems()
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CustomDropdownFormMenu(
                //value: revisiones.isEmpty ? null : revisiones[0],
                items: revisiones.map((e){
                  return DropdownMenuItem(
                    value: e,
                    child: SizedBox( // Wrap with SizedBox to limit width
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        'Revisión ${e.ordinal} (${e.tipoRevision}): ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                      ),
                    ),
                  );
                }).toList(),
                hint: 'Seleccione una revisión',
                onChanged: (value) async {
                  await cambioDeRevision(value, context);
                  valorComentario = value.comentario;
                },
              ),

            ),
            Text(
              valorComentario,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
            ),
            const SizedBox(height: 10,),
            const Divider(),
            const SizedBox(height: 10,),
            const Spacer(),
            BottomNavigationBar(
              currentIndex: buttonIndex,
              onTap: (index) {
                setState(() {
                  buttonIndex = index;
                  switch (buttonIndex){
                    case 0: 
                      _showCreateDeleteDialog(context);
                    break;
                    case 1:
                      _showCreateCopyDialog(context);
                    break;
                  }
                });
              },
              showUnselectedLabels: true,
              selectedItemColor: colors.primary,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.delete),
                  label: 'Borrar Revision',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle),
                  label: 'Crear Copia',
                ),
              ],
            ),
          ],
        ),
        
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 200,
          ),
          if (menu == 'Ptos de Inspeccion') RevisionPtosInspeccionMobile(
            ptosInspeccion: ptosInspeccion,
            revision: selectedRevision
          ),
          if (menu == 'Tareas Realizadas')
            RevisionTareasMenu(
              revisionTareasList: revisionTareasList,
              revision: selectedRevision,
            ),
          if (menu == 'Plagas')
            RevisionPlagasMenu(
              plagas: plagas,
              revisionPlagasList: revisionPlagasList,
              revision: selectedRevision,
            ),
          if (menu == 'Materiales utilizados')
            RevisionMaterialesMenu(
              materiales: materiales,
              revisionMaterialesList: revisionMaterialesList,
              revision: selectedRevision,
            ),
          if (menu == 'Observaciones')
            RevisionObservacionesMenu(
              observacion: observacion,
              observaciones: observaciones,
              revision: selectedRevision,
            ),
          if (menu == 'Firmas') RevisionFirmasMenu(
            revision: selectedRevision,
            firmas: firmas,
          ),
          if (menu == 'Cuestionario') const RevisionCuestionarioMenu(),
          if (menu == 'Validacion') const RevisionValidacionMenu(),
          if (menu == 'Materiales') RevisionMaterialesDiagnositcoMenu(
            materiales: materiales,
            revisionMaterialesList: revisionMaterialesList,
            revision: selectedRevision,
          ),
        ],
      ),
       
      //todo bottomnavigation   
    );
  }

  Future<void> cambioDeRevision(value, BuildContext context) async {
    selectedRevision = value;
    revisionId = (value as RevisionOrden).otRevisionId;
    Provider.of<OrdenProvider>(context, listen: false).setRevisionId(revisionId);
    revisionMaterialesList = await MaterialesServices().getRevisionMateriales(context, orden, revisionId, token);
    revisionTareasList = await RevisionServices().getRevisionTareas(context, orden, revisionId, token);
    revisionPlagasList = await RevisionServices().getRevisionPlagas(context, orden, revisionId, token);
    observaciones = await RevisionServices().getObservacion(context, orden, observacion, revisionId, token);
    observacion = observaciones.isNotEmpty ? observaciones[0] : Observacion.empty();
    ptosInspeccion = await PtosInspeccionServices().getPtosInspeccion(context, orden, revisionId, token);
    firmas = await RevisionServices().getRevisionFirmas(context, orden, revisionId, token);

    setState(() {});
    
  }

void _showCreateCopyDialog(BuildContext context) {
  final colors = Theme.of(context).colorScheme;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Crear copia'),
        content: StatefulBuilder(
          builder: (context, setStateBd) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Está por generar la copia de una revisión, seleccione el origen de la copia'),
              const SizedBox(height: 10,),
              CustomDropdownFormMenu(
                hint: 'Seleccione una revisión',
                // value: selectedRevision,
                onChanged: (newValue) {
                  setState(() {
                    selectedRevision = newValue;
                  });
                },
                items: revisiones.map((RevisionOrden revision) {
                  return DropdownMenuItem(
                    value: revision,
                    child: Text('Revisión ${revision.ordinal}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10,),
              CustomTextFormField(
                controller: comentarioController,
                hint: 'Escriba un comentario a ser necesario',
                label: 'Comentario',
                maxLines: 1,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Revision normal'),
                  Switch(
                    activeColor: colors.primary,
                    value: filtro, 
                    onChanged: (value) {
                      filtro = value;
                      setStateBd(() {});
                    },
                  ),
                  const Text('Revision restringida')
                ],
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
            child: const Text('Crear'),
            onPressed: () async {
              if (selectedRevision != null) {
                selectedRevision!.comentario = comentarioController.text;          
                selectedRevision!.tipoRevision = filtro ? 'R' : 'N';
                await RevisionServices().copyRevision(context, orden, selectedRevision!, token);
                revisiones = await RevisionServices().getRevision(context, orden, token);
                setState(() {});
              }
            },
          ),
        ],
      );
    },
  );
}

void _showCreateDeleteDialog(BuildContext context) {
  RevisionOrden? selectedRevision; // Variable para almacenar la revisión seleccionada

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Borrar revisión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Está por borrar una revisión, seleccione cual va a borrar'),
            const SizedBox(height: 10,),
            CustomDropdownFormMenu(
              hint: 'Seleccione una revisión',
              value: selectedRevision,
              onChanged: (newValue) {
                setState(() {
                  selectedRevision = newValue;
                });
              },
              items: revisiones.map((RevisionOrden revision) {
                return DropdownMenuItem(
                  value: revision,
                  child: Text('Revisión ${revision.ordinal}'),
                );
              }).toList(),
            ),
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
            child: const Text('Borrar'),
            onPressed: () async {
              if (selectedRevision != null) {
                if(selectedRevision!.ordinal == 0){
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('La revisión con ordinal 0 no puede ser borrada'),
                      backgroundColor: Colors.red,
                    )
                  );
                }else{
                  await RevisionServices().deleteRevision(context, orden, selectedRevision!, token);
                  revisiones = await RevisionServices().getRevision(context, orden, token);
                  setState(() {});
                }
              }
            },
          ),
        ],
      );
    },
  );
}

  Widget _listaItems() {
    final String tipoOrden = orden.tipoOrden.codTipoOrden;
    return FutureBuilder(
      future: menuProvider.cargarMenuRevision(tipoOrden),
      initialData: const [],
      builder: (context, snapshot) {
        return ListView(
          children: _listaItemsDrawer(snapshot.data, context),
        );
      },
    );
  }

  List<Widget> _listaItemsDrawer(data, BuildContext context) {
    final List<Widget> opciones = [];
    data.forEach((opt) {
      final widgetTemp = ListTile(
        title: Text(opt['texto']),
        leading: getIcon(opt['icon'], context),
        trailing: const Icon(
          Icons.keyboard_arrow_right,
          color: Colors.green,
        ),
        onTap: () {
          menu = opt['texto'];
          router.pop();
          setState(() {});
        },
      );

      opciones
        ..add(widgetTemp)
        ..add(const Divider());
    });
    return opciones;
  }
}
