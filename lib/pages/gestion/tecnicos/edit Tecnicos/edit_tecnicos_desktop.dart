// ignore_for_file: unused_field, avoid_print, avoid_init_to_null

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

class EditTecnicosDesktop extends StatefulWidget {
  const EditTecnicosDesktop({super.key});

  @override
  State<EditTecnicosDesktop> createState() => _EditTecnicosDesktopState();
}

class _EditTecnicosDesktopState extends State<EditTecnicosDesktop> {
  late Tecnico selectedTecnico = context.read<OrdenProvider>().tecnico;
  late List<Cargo> cargos = [
    Cargo(cargoId: 1, codCargo: '1', descripcion: 'Aprendiz'),
    Cargo(cargoId: 2, codCargo: '2', descripcion: 'Aplicador'),
    Cargo(cargoId: 3, codCargo: '3', descripcion: 'Supervisor'),
  ];
  late Cargo? cargoSeleccionado = Cargo.empty();
  DateTime selectedDateNacimiento = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime selectedDateIngreso = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime selectedDateCarneSalud = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late String _setDate;
  late String dateTime;
  final TextEditingController _dateNacimientoController = TextEditingController();
  final TextEditingController _dateIngresoController = TextEditingController();
  final TextEditingController _dateCarneSaludController = TextEditingController();
  final _nombreController = TextEditingController();
  final _docController = TextEditingController();
  final _codController = TextEditingController();
  late String token = context.read<OrdenProvider>().token;
  late bool tieneId = false;
  late Uint8List? _avatarTecnico = null;
  late Uint8List? _firmaTecnico = null;

  String _formatDateAndTime(DateTime? date) {
    return '${date?.day.toString().padLeft(2, '0')}/${date?.month.toString().padLeft(2, '0')}/${date?.year.toString().padLeft(4, '0')}';
  }

  Future<void> _uploadPhoto1() async {
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
            _avatarTecnico = reader.result as Uint8List?;
          });
        });
      }
    });
  }

  Future<void> _uploadPhoto2() async {
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
            _firmaTecnico = reader.result as Uint8List?;
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    selectedDateNacimiento = selectedTecnico.fechaNacimiento!;
    selectedDateIngreso = selectedTecnico.fechaIngreso!;
    selectedDateCarneSalud = selectedTecnico.fechaVtoCarneSalud!;
    tieneId = selectedTecnico.tecnicoId > 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (selectedTecnico.tecnicoId != 0) {
      _nombreController.text = selectedTecnico.nombre;
      _docController.text = selectedTecnico.documento;
      _codController.text = selectedTecnico.codTecnico;
      cargoSeleccionado = selectedTecnico.cargo;
    }

    _dateNacimientoController.text = (selectedTecnico.tecnicoId != 0 &&
            selectedDateNacimiento == selectedTecnico.fechaNacimiento)
        ? _formatDateAndTime(selectedTecnico.fechaNacimiento)
        : _formatDateAndTime(selectedDateNacimiento);
    _dateCarneSaludController.text = (selectedTecnico.tecnicoId != 0 &&
            selectedDateCarneSalud == selectedTecnico.fechaVtoCarneSalud)
        ? _formatDateAndTime(selectedTecnico.fechaVtoCarneSalud)
        : _formatDateAndTime(selectedDateCarneSalud);
    _dateIngresoController.text = (selectedTecnico.tecnicoId != 0 &&
            selectedDateIngreso == selectedTecnico.fechaIngreso)
        ? _formatDateAndTime(selectedTecnico.fechaIngreso)
        : _formatDateAndTime(selectedDateIngreso);

    late Cargo cargoInicialSeleccionado = cargos[0];
    if (cargoSeleccionado!.cargoId != 0) {
      cargoInicialSeleccionado = cargos.firstWhere((cargo) => cargo.cargoId == cargoSeleccionado!.cargoId);
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Editar Tecnico',
        ),
        drawer: const Drawer(
          child: BotonesDrawer(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _avatarTecnico != null ? 
                        Image.memory(_avatarTecnico!, width: 200, height: 200) : 
                        const SizedBox(
                          width: 200,
                          height: 200,
                          child: Placeholder(
                            child: Text('Avatar del tecnico'),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Subir foto',
                          onPressed: () async {
                            await _uploadPhoto1();
                          }, 
                          icon: const Icon(Icons.upload)),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 300,
                          child: Image.asset('images/Firmas_Tecnicos/ANDRES ABREU.JPG'),
                        ),
                        IconButton(
                          tooltip: 'Subir firma',
                          onPressed: () async {
                            await _uploadPhoto2();
                          }, 
                          icon: const Icon(Icons.upload)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        tipoDato('Codigo', _codController),
                        const SizedBox(
                          height: 20,
                        ),
                        tipoDato('Documento', _docController),
                        const SizedBox(
                          height: 20,
                        ),
                        tipoDato('Nombre', _nombreController),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => _selectFechaNacimiento(context),
                              icon: const Icon(Icons.calendar_month)
                            ),
                            SizedBox(
                              width: 300,
                              child: CustomTextFormField(
                                label: 'Fecha de nacimiento',
                                textAling: TextAlign.center,
                                controller: _dateNacimientoController,
                                onSaved: (value) {
                                  _setDate = value!;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            const Text('Cargo'),
                            const SizedBox(
                              width: 15,
                            ),
                            SizedBox(
                              width: 300,
                              child: CustomDropdownFormMenu(
                                value: cargoInicialSeleccionado,
                                hint: 'Seleccione cargo',
                                items: cargos.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e.descripcion),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  cargoSeleccionado = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => _selectFechaIngreso(context),
                              icon: const Icon(Icons.calendar_month)
                            ),
                            SizedBox(
                              width: 300,
                              child: CustomTextFormField(
                                label: 'Fecha de ingreso',
                                textAling: TextAlign.center,
                                controller: _dateIngresoController,
                                onSaved: (value) {
                                  _setDate = value!;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => _selectFechaVtoCarneSalud(context),
                              icon: const Icon(Icons.calendar_month)
                            ),
                            SizedBox(
                              width: 300,
                              child: CustomTextFormField(
                                label: 'Fecha Vto Carne de Salud',
                                textAling: TextAlign.center,
                                controller: _dateCarneSaludController,
                                onSaved: (value) {
                                  _setDate = value!;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20,),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                    elevation: MaterialStatePropertyAll(10),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(50),
                          right: Radius.circular(50)
                        )
                      )
                    )
                  ),
                  onPressed: () async {
                    await postTecnico(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.5),
                    child: Text(
                      'Guardar',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
                  )
                ),
                const SizedBox(width: 30,),
                if (tieneId)
                  ElevatedButton(
                    style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                    elevation: MaterialStatePropertyAll(10),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(50),
                          right: Radius.circular(50)
                        )
                      )
                    )
                  ),
                  onPressed: () async {
                    borrarTecnico(context, selectedTecnico, token);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.5),
                    child: Text(
                      'Eliminar',
                      style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )
                ),
              ]
            )
          )
        ),
      ),
    );
  }

  Future<void> postTecnico(BuildContext context) async {
    selectedTecnico.codTecnico = _codController.text;
    selectedTecnico.documento = _docController.text;
    selectedTecnico.nombre = _nombreController.text;
    selectedTecnico.fechaNacimiento = DateTime(selectedDateNacimiento.year, selectedDateNacimiento.month, selectedDateNacimiento.day);
    selectedTecnico.cargo = cargoSeleccionado;
    selectedTecnico.cargoId = cargoSeleccionado!.cargoId;
    selectedTecnico.fechaIngreso = DateTime(selectedDateIngreso.year, selectedDateIngreso.month, selectedDateIngreso.day);
    selectedTecnico.fechaVtoCarneSalud = DateTime(selectedDateCarneSalud.year, selectedDateCarneSalud.month, selectedDateCarneSalud.day);

    if (selectedTecnico.tecnicoId == 0) {
      await TecnicoServices().postTecnico(context, selectedTecnico, token);
    } else {
      await TecnicoServices().putTecnico(context, selectedTecnico, token);
    }

    setState(() {
      tieneId = true;
    });
  }

  Row tipoDato(String tipoDato, TextEditingController controller) {
    return Row(
      children: [
        Text(tipoDato),
        const SizedBox(
          width: 15,
        ),
        SizedBox(
          width: 300,
          child: CustomTextFormField(
            maxLines: 1,
            label: tipoDato,
            controller: controller,
          ),
        )
      ],
    );
  }

  Future<Null> _selectFechaNacimiento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateNacimiento,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1900),
      lastDate: DateTime(2099)
    );
    if (picked != null) {
      setState(() {
        selectedDateNacimiento = picked;
        _dateNacimientoController.text =
            DateFormat.yMd().format(selectedDateNacimiento);
        setState(() {});
      });
    }
  }

  Future<Null> _selectFechaIngreso(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateIngreso,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1900),
      lastDate: DateTime(2099)
    );
    if (picked != null) {
      setState(() {
        selectedDateIngreso = picked;
        _dateIngresoController.text = DateFormat.yMd().format(selectedDateNacimiento);
        setState(() {});
      });
    }
  }

  Future<Null> _selectFechaVtoCarneSalud(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateCarneSalud,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1900),
      lastDate: DateTime(2099)
    );
    if (picked != null) {
      setState(() {
        selectedDateCarneSalud = picked;
        _dateCarneSaludController.text = DateFormat.yMd().format(selectedDateNacimiento);
        setState(() {});
      });
    }
  }

  Future<dynamic> borrarTecnico(BuildContext context, Tecnico tecnico, String token) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar accion'),
          content: const Text('Desea borrar el tecnico?'),
          actions: [
            TextButton(
              onPressed: () async {
                TecnicoServices().deleteTecnico(context, tecnico, token);
              },
              child: const Text('Borrar')
            ),
            TextButton(
              onPressed: () {
                router.pop();
              },
              child: const Text('Cancelar')
            )
          ],
        );
      },
    );
  }
}
