// ignore_for_file: use_build_context_synchronously, avoid_init_to_null, void_checks
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_diagnostico_services.dart';
import 'package:sedel_oficina_maqueta/services/plaga_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class RevisionMaterialesDiagnositcoMenu extends StatefulWidget {
  final List<Materiales> materiales;
  final List<RevisionMaterial> revisionMaterialesList;
  final RevisionOrden? revision;
  const RevisionMaterialesDiagnositcoMenu({super.key, required this.materiales, required this.revisionMaterialesList, required this.revision });

  @override
  State<RevisionMaterialesDiagnositcoMenu> createState() => _RevisionMaterialesDiagnositcoMenuState();
}

class _RevisionMaterialesDiagnositcoMenuState extends State<RevisionMaterialesDiagnositcoMenu> {
  late List<String> savedData = [];
  List<Materiales> materiales = [];
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
  late String token = '';
  late Materiales? materialInicial = null;
  late Orden orden = Orden.empty();
  final ScrollController _scrollController = ScrollController();
  late int marcaId = 0;
  bool isReadOnly = true;
  final TextEditingController comentarioController = TextEditingController();
  late int revisionId = 0;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    orden = context.read<OrdenProvider>().orden;
    materiales = await MaterialesDiagnosticoServices().getMateriales(token);
    if (orden.estado == "EN PROCESO" && marcaId != 0) {
      isReadOnly = false;
    }
    setState(() {});
  }

  void _showMaterialDetails(BuildContext context, Materiales material) async {
    plagas = await PlagaServices().getPlagas(context, '', '', token);
    lotes = await MaterialesDiagnosticoServices().getLotes(selectedMaterial.materialId, token);
    metodosAplicacion = await MaterialesDiagnosticoServices().getMetodosAplicacion(token);
    selectedMetodo = MetodoAplicacion.empty();
    selectedLote = Lote.empty();
    comentarioController.text = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              child: const Text('Guardar'),
              onPressed: () async {
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
                await MaterialesDiagnosticoServices().postRevisionMaterial(
                    context, orden, nuevaRevisionMaterial, revisionId, token);
                widget.revisionMaterialesList.add(nuevaRevisionMaterial);
        
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (selectedMaterial.materialId != 0 && materiales.isNotEmpty) {
      materialInicial = materiales.firstWhere(
          (material) => material.materialId == selectedMaterial.materialId);
    }
    revisionId = context.read<OrdenProvider>().revisionId;


    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: Constantes().ancho,
              decoration: BoxDecoration(
                  border: Border.all(
                      width: 2,
                      color: colors.primary),
                  borderRadius: BorderRadius.circular(5)),
              child: DropdownButton<Materiales>(
                hint: const Text("Selecciona un material"),
                value: materialInicial,
                onChanged: (newValue) async {
                  if (widget.revision?.ordinal == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No se puede modificar esta revisión.'),
                    ));
                    return Future.value(false);
                  }
                  setState(() {
                    selectedMaterial = newValue!;
                    _showMaterialDetails(context, selectedMaterial);
                  });
                },
                items: materiales.map((material) {
                  return DropdownMenuItem(
                    value: material,
                    child: Text(material.descripcion),
                  );
                }).toList(),
                iconSize: 24,
                elevation: 16,
                isExpanded: true,
              ),
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
                        'Materiales Utilizados:',
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
                            if (widget.revision?.ordinal == 0) {
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
                                        Navigator.of(context).pop(true);
                                        await MaterialesDiagnosticoServices().deleteRevisionMaterial(context, orden, widget.revisionMaterialesList[i], revisionId, token);
                                      },
                                      child: const Text("BORRAR")),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            setState(() {
                              widget.revisionMaterialesList.removeAt(i);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$item borrado'),
                              )
                            );
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
                                trailing: IconButton(
                                    onPressed: () async {
                                      if (widget.revision?.ordinal == 0) {
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
                                                    style: TextButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                    ),
                                                    onPressed: () async {
                                                      await MaterialesDiagnosticoServices()
                                                          .deleteRevisionMaterial(
                                                              context,
                                                              orden,
                                                              widget.revisionMaterialesList[i],
                                                              revisionId,
                                                              token);
                                                      setState(() {
                                                        widget.revisionMaterialesList.removeAt(i);
                                                      });
                                                    },
                                                    child: const Text(
                                                        "BORRAR")),
                                              ],
                                            );
                                          });
                                    },
                                    icon: const Icon(Icons.delete)),
                                title: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Material: ${widget.revisionMaterialesList[i].material.descripcion}'),
                                    Text(
                                        'Unidad: ${widget.revisionMaterialesList[i].material.unidad}'),
                                    Text(
                                        'Cantidad: ${widget.revisionMaterialesList[i].cantidad}'),
                                    Text(
                                        'Comentario: ${widget.revisionMaterialesList[i].comentario}'),
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
}
