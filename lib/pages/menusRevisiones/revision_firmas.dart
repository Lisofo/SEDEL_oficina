// ignore_for_file: use_build_context_synchronously, avoid_init_to_null, void_checks, avoid_print

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/clientesFirmas.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/revision_services.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:signature/signature.dart';
import 'package:crypto/crypto.dart';
import 'package:universal_html/html.dart' as html;

import '../../models/revision_orden.dart';

class RevisionFirmasMenu extends StatefulWidget {
  final RevisionOrden? revision;
  final List<ClienteFirma> firmas;
  const RevisionFirmasMenu({super.key, required this.revision, required this.firmas});

  @override
  State<RevisionFirmasMenu> createState() => _RevisionFirmasMenuState();
}

class _RevisionFirmasMenuState extends State<RevisionFirmasMenu> {
  final _formKey1 = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  late int marcaId = 0;
  bool isReadOnly = true;
  late Orden orden = context.read<OrdenProvider>().orden;
  late String token = context.read<OrdenProvider>().token;
  Uint8List? exportedImage;
  late String md5Hash = '';
  late List<int> firmaBytes = [];
  late int revisionId = 0;
  late Uint8List? _firmaCliente = null;
  bool clienteNoDisponible = false;
  bool filtro = false;
  late String? firmaDisponible = '';
  bool guardandoFirma = false;
  final revisionServices = RevisionServices(); 
  int? statusCode;
  bool cargando = true;
  bool cargoDatosCorrectamente = false;
  int contadorDeVeces = 0;


  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    try {
      orden = context.read<OrdenProvider>().orden;
      if(orden.otRevisionId != 0){
        firmaDisponible = await RevisionServices().getRevision(context, orden, revisionId, token);
      }
      print(firmaDisponible);
      if(firmaDisponible == 'N'){
        clienteNoDisponible = true;
        filtro = true;
        controller.disabled = !controller.disabled;
      }
      if (contadorDeVeces > 1 && widget.firmas.isNotEmpty){
        cargoDatosCorrectamente = true;
      }
      else if (contadorDeVeces == 1){
        cargoDatosCorrectamente = true;
      }
      cargando = false;
    } catch (e) {
      cargando = false;
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
      child: SizedBox(
        height: MediaQuery.of(context).size.height* 0.88,
        child: Column(
          children: [
            Container(
              width: Constantes().ancho,
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Form(
                key: _formKey1,
                child: Column(
                  children: [
                    Container(
                      width: Constantes().ancho,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: colors.primary,
                              width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      child: TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(5)),
                            fillColor: !clienteNoDisponible ? Colors.white : Colors.grey,
                            filled: true,
                            hintText: 'Nombre'),
                            enabled: !clienteNoDisponible,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: Constantes().ancho,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: colors.primary,
                              width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      child: TextFormField(
                        controller: areaController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(5)),
                            fillColor: !clienteNoDisponible ? Colors.white : Colors.grey,
                            filled: true,
                            hintText: 'Area'),
                            enabled: !clienteNoDisponible,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: colors.primary,
                        width: 1),
                    borderRadius: BorderRadius.circular(5)),
                child: 
                widget.revision!.ordinal == 0 ?
                Signature(
                  controller: controller,
                  width: Constantes().ancho,
                  height: 200,
                  backgroundColor: !clienteNoDisponible ? Colors.white : Colors.grey,
                ) : 
                  SizedBox(
                    width: Constantes().ancho,
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _firmaCliente == null ? const Center(child: Text('Subir foto'),) : Image.memory(_firmaCliente!, width: 200, height: 150),
                          IconButton(
                            icon: const Icon(Icons.upload), 
                            onPressed: () async {
                              await _uploadFirma();
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  )
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if(!clienteNoDisponible)...[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: CustomButton(
                      onPressed: !guardandoFirma ? () async {
                        guardandoFirma = true;
                        if ((widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') || clienteNoDisponible) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(clienteNoDisponible ? 'Cliente no disponible' : 'No se puede modificar esta revisión.'),
                          ));
                          guardandoFirma = false;
                          return Future.value(false);
                        }
                        if (nameController.text.isNotEmpty && areaController.text.isNotEmpty) {
                          await guardarFirma(context, _firmaCliente);
                          guardandoFirma = false;
                        } else {
                          completeDatosPopUp(context);
                          guardandoFirma = false;
                        }
                      } : null,
                      text: 'Guardar',
                      tamano: 20,
                      disabled: guardandoFirma,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () {
                          controller.clear();
                        },
                        style: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.white),
                            elevation: WidgetStatePropertyAll(10),
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(50),
                                        right: Radius.circular(50))))),
                        child: Icon(
                          Icons.delete,
                          color: colors.primary,
                        )),
                  ),
                ],
                if(widget.firmas.isEmpty)...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        activeColor: colors.primary,
                        value: filtro,
                        onChanged: (value) async {
                          if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('No se puede modificar esta revisión.'),
                            ));
                            return Future.value(false);
                          }
                          if(value){
                            await revisionServices.patchFirma(context, orden, 'N', token);
                          } else{
                            await revisionServices.patchFirma(context, orden, null, token);
                          }
                          statusCode = await revisionServices.getStatusCode();
                          await revisionServices.resetStatusCode();

                          if (statusCode == 1){
                            setState(() {
                              filtro = value;
                              clienteNoDisponible = filtro;
                              controller.disabled = !controller.disabled;
                              controller.clear();
                              nameController.clear();
                              areaController.clear();
                            });
                          }
                          statusCode = null;
                          
                        }
                      ),
                      const Text('Cliente no disponible')
                    ],
                  ),
                ]
              ],
            ),
            // if (exportedImage != null) Image.memory(exportedImage!),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.17,
              width: Constantes().ancho,
              child: ListView.builder(
                itemCount: widget.firmas.length,
                itemBuilder: (context, index) {
                  final item = widget.firmas[index];
                  return Dismissible(
                    key: Key(item.toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (DismissDirection direction) {
                      if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('No se puede modificar esta revisión.'),
                        ));
                        return Future.value(false);
                      }
                      return showDialog(
                        context: context,
                        builder: (BuildContext context) {                        
                          return borrarDesdeDismiss(context, index);
                        }
                      );
                    },
                    onDismissed: (direction) async {
                      if (statusCode == 1){
                        setState(() {
                          widget.firmas.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('La firma de $item ha sido borrada'),
                        ));
                      }
                      statusCode = null;  
                    },
                    background: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: AlignmentDirectional.centerEnd,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    child: Container(
                      width: Constantes().ancho,
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide())),
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Text(widget.firmas[index].nombre),
                        subtitle: Text(widget.firmas[index].area),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              splashColor: Colors.transparent,
                              splashRadius: 25,
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text('No se puede modificar esta revisión.'),
                                  ));
                                  return Future.value(false);
                                }
                                _editarCliente(widget.firmas[index]);
                              },
                            ),
                            IconButton(
                              splashColor: Colors.transparent,
                              splashRadius: 25,
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                if (widget.revision?.ordinal == 0 || orden.estado == 'REVISADA') {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('No se puede modificar esta revisión.'),
                                    ));
                                    return Future.value(false);
                                  }
                                _borrarCliente(widget.firmas[index], index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  AlertDialog borrarDesdeDismiss(BuildContext context, int i) {
    return AlertDialog(
      title: const Text("Confirmar"),
      content: const Text("¿Estas seguro de querer borrar la firma?"),
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
            await RevisionServices().deleteRevisionFirma(context, orden, widget.firmas[i], revisionId, token);
            statusCode = await revisionServices.getStatusCode();
            revisionServices.resetStatusCode();
            if (statusCode == 1) {
              Navigator.of(context).pop(true);
            }
          },
          child: const Text("BORRAR")
        ),
      ],
    );
  }

  Future<void> guardarFirma(BuildContext context, Uint8List? firma) async {
    exportedImage = firma ?? await controller.toPngBytes();
    firmaBytes = exportedImage as List<int>;
    md5Hash = calculateMD5(firmaBytes);
    int? statusCode;

    final ClienteFirma nuevaFirma = ClienteFirma(
      otFirmaId: 0,
      ordenTrabajoId: orden.ordenTrabajoId,
      otRevisionId: orden.otRevisionId,
      nombre: nameController.text,
      area: areaController.text,
      firmaPath: '',
      firmaMd5: md5Hash,
      comentario: '',
      firma: exportedImage
    );

    RevisionServices revisionServices = RevisionServices();

    await revisionServices.postRevisonFirma(context, orden, nuevaFirma, widget.revision!.otRevisionId, token);
    statusCode = await revisionServices.getStatusCode();
    revisionServices.resetStatusCode;

    if(statusCode == 1){
      _agregarCliente(nuevaFirma);
    } else {
      print('error');
    }
    statusCode = null;
  }

  void completeDatosPopUp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Campos vacíos'),
          content: const Text(
            'Por favor, completa todos los campos antes de guardar.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String calculateMD5(List<int> bytes) {
    var md5c = md5.convert(bytes);
    return md5c.toString();
  }

  void _agregarCliente(ClienteFirma cliente) {
    if (_formKey1.currentState!.validate()) {
      setState(() {
        widget.firmas.add(cliente);

        nameController.clear();
        areaController.clear();
        controller.clear();
        exportedImage = null;
      });
    }
  }

  Future<void> _borrarCliente(ClienteFirma cliente, int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: const Text("Confirmar"),
          content: const Text("¿Estas seguro de querer borrar la firma?"),
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
                await RevisionServices().deleteRevisionFirma(context, orden, cliente, revisionId, token);
                setState(() {
                  widget.firmas.removeAt(index);
                });
              },
              child: const Text("BORRAR")
            ),
          ],
        );
      }
    );
  }

  Future<void> _editarCliente(ClienteFirma firma) async {
    String nuevoNombre = firma.nombre;
    String nuevoArea = firma.area;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: const Text('Editar Cliente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: nuevoNombre),
                onChanged: (value) {
                  nuevoNombre = value;
                },
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: TextEditingController(text: nuevoArea),
                onChanged: (value) {
                  nuevoArea = value;
                },
                decoration: const InputDecoration(labelText: 'Área'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await RevisionServices().putRevisionFirma(context, orden, firma, revisionId, token);
                statusCode = await revisionServices.getStatusCode();
                revisionServices.resetStatusCode();
                if(statusCode == 1){
                  firma.area = nuevoArea;
                  firma.nombre = nuevoNombre;
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null && result['nombre'] != null && result['area'] != null) {
        setState(() {
          firma.nombre = result['nombre'];
          firma.area = result['area'];
        });
      }
    });
  }

  Future<void> _uploadFirma() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((e) {
      final files = input.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]); // Leer el archivo como una matriz de bytes
        reader.onLoadEnd.listen((e) {
          setState(() {
            // Asignar los bytes del archivo a _avatarTecnico
            _firmaCliente = reader.result as Uint8List?;
          });
        });
      }
    });
  }
}
