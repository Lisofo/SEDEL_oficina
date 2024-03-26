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
  const RevisionFirmasMenu({super.key, required this.revision});

  @override
  State<RevisionFirmasMenu> createState() => _RevisionFirmasMenuState();
}

class _RevisionFirmasMenuState extends State<RevisionFirmasMenu> {
  final _formKey1 = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  List<ClienteFirma> client = [];
  late int marcaId = 0;
  bool isReadOnly = true;
  late Orden orden = context.read<OrdenProvider>().orden;
  late String token = context.read<OrdenProvider>().token;
  Uint8List? exportedImage;
  late String md5Hash = '';
  late List<int> firmaBytes = [];
  late int revisionId = 0;
  late Uint8List? _firmaCliente = null;


  SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.deepOrange,
  );

  void _agregarCliente() {
    if (_formKey1.currentState!.validate()) {
      setState(() {
        client.add(ClienteFirma(
          nombre: nameController.text,
          area: areaController.text,
          firma: exportedImage,
          otFirmaId: 0,
          firmaPath: '',
          ordenTrabajoId: 0,
          otRevisionId: 0,
          firmaMd5: '',
          comentario: '',
        ));

        nameController.clear();
        areaController.clear();
        controller.clear();
        exportedImage = null;
      });
    }
  }

  Future<void> _borrarCliente(int index) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
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
                    Navigator.of(context).pop();
                    await RevisionServices().deleteRevisionFirma(
                        context, orden, client[index], revisionId, token);

                    setState(() {
                      client.removeAt(index);
                    });
                  },
                  child: const Text("BORRAR")),
            ],
          );
        });
  }

  void _editarCliente(ClienteFirma firma) async {
    String nuevoNombre = firma.nombre;
    String nuevoArea = firma.area;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                firma.area = nuevoArea;
                firma.nombre = nuevoNombre;

                await RevisionServices().putRevisionFirma(context, orden, firma, revisionId, token);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    ).then((result) {
      if (result != null &&
          result['nombre'] != null &&
          result['area'] != null) {
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
  
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 700,
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
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Nombre'),
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
                            fillColor: Colors.white,
                            filled: true,
                            hintText: 'Area'),
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
                  backgroundColor: Colors.white) : 
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
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CustomButton(
                    onPressed: () async {
                      if (widget.revision?.ordinal == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No se puede modificar esta revisión.'),
                      ));
                      return Future.value(false);
                    }
                      if (nameController.text.isNotEmpty &&
                          areaController.text.isNotEmpty) {
                        await guardarFirma(context, _firmaCliente);
                      } else {
                        completeDatosPopUp(context);
                      }
                    },
                    text: 'Guardar',
                    tamano: 20,
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
                              MaterialStatePropertyAll(Colors.white),
                          elevation: MaterialStatePropertyAll(10),
                          shape: MaterialStatePropertyAll(
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
            ),
            if (exportedImage != null) Image.memory(exportedImage!),
            SizedBox(
              height: 184,
              width: Constantes().ancho,
              child: ListView.builder(
                itemCount: client.length,
                itemBuilder: (context, index) {
                  final item = client[index];
                  return Dismissible(
                    key: Key(item.toString()),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (DismissDirection direction) {
                      return showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return borrarDesdeDismiss(context, index);
                          });
                    },
                    onDismissed: (direction) async {
                      setState(() {
                        client.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('La firma de $item ha sido borrada'),
                      ));
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
                      decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide())),
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Text(client[index].nombre),
                        subtitle: Text(client[index].area),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              splashColor: Colors.transparent,
                              splashRadius: 25,
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editarCliente(client[index]);
                              },
                            ),
                            IconButton(
                              splashColor: Colors.transparent,
                              splashRadius: 25,
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _borrarCliente(index);
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
              Navigator.of(context).pop(true);
              await RevisionServices().deleteRevisionFirma(context, orden, client[i], revisionId, token);
            },
            child: const Text("BORRAR")),
      ],
    );
  }

  Future<void> guardarFirma(BuildContext context, Uint8List? firma) async {
    exportedImage = firma != null ? firma : await controller.toPngBytes();
    firmaBytes = exportedImage as List<int>;
    md5Hash = calculateMD5(firmaBytes);
<<<<<<< Updated upstream
=======
    int? statusCode;
>>>>>>> Stashed changes

    final ClienteFirma nuevaFirma = ClienteFirma(
        otFirmaId: 0,
        ordenTrabajoId: orden.ordenTrabajoId,
        otRevisionId: orden.otRevisionId,
        nombre: nameController.text,
        area: areaController.text,
        firmaPath: '',
        firmaMd5: md5Hash,
        comentario: '',
        firma: exportedImage);

<<<<<<< Updated upstream
    await RevisionServices().postRevisonFirma(context, orden, nuevaFirma, token);
    var statusCode = context.read<OrdenProvider>().statusCode;
    // statusCode = await RevisionServices().getStatusCode();
=======
  
    RevisionServices revisionServices = RevisionServices();

    await revisionServices.postRevisonFirma(context, orden, nuevaFirma, token);
    statusCode = await revisionServices.getStatusCode();

>>>>>>> Stashed changes
    print('call $statusCode');

    if(statusCode == 201){
      _agregarCliente();
    }else{
      print('error');
    }
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
}
