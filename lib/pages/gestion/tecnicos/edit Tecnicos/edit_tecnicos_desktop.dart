import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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
  late String? _avatarTecnico2 = '';
  late String? _firmaTecnico2 = '';
  late List<int> firmaBytes = [];
  late List<int> avatarBytes = [];
  late String md5Avatar = '';
  late String md5Firma = '';
  late String firmaName = '';
  late String avatarName = '';
  late String nombre = '';
  late MaskTextInputFormatter maskFormatter = MaskTextInputFormatter(mask: '#.###.###-#', filter: { "#": RegExp(r'[0-9]') });
  late bool verDiaSiguiente = false;

  String _formatDateAndTime(DateTime? date) {
    return '${date?.day.toString().padLeft(2, '0')}/${date?.month.toString().padLeft(2, '0')}/${date?.year.toString().padLeft(4, '0')}';
  }


  Future<void> uploadFirmaTecnico () async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((e) async {
      final files = input.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _firmaTecnico = reader.result as Uint8List?;
            firmaName = files[0].name;
          });
        });
      }
    });
  }

  Future<void> uploadAvatarTecnico () async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((e) async {
      final files = input.files;
      if (files!.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _avatarTecnico = reader.result as Uint8List?;
            avatarName = files[0].name;
            print(avatarName);
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
    verDiaSiguiente = selectedTecnico.verDiaSiguiente ?? false;
    tieneId = selectedTecnico.tecnicoId > 0;
    if(selectedTecnico.avatarPath != '' || selectedTecnico.firmaPath != ''){
      _avatarTecnico2 = selectedTecnico.avatarPath;
      _firmaTecnico2 = selectedTecnico.firmaPath;
    }
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

    _dateNacimientoController.text = (selectedTecnico.tecnicoId != 0 && selectedDateNacimiento == selectedTecnico.fechaNacimiento) 
      ? _formatDateAndTime(selectedTecnico.fechaNacimiento) : _formatDateAndTime(selectedDateNacimiento);
    _dateCarneSaludController.text = (selectedTecnico.tecnicoId != 0 && selectedDateCarneSalud == selectedTecnico.fechaVtoCarneSalud)
      ? _formatDateAndTime(selectedTecnico.fechaVtoCarneSalud) : _formatDateAndTime(selectedDateCarneSalud);
    _dateIngresoController.text = (selectedTecnico.tecnicoId != 0 && selectedDateIngreso == selectedTecnico.fechaIngreso)
      ? _formatDateAndTime(selectedDateIngreso) : _formatDateAndTime(selectedDateIngreso);

    late Cargo cargoInicialSeleccionado = cargos[0];
    if (cargoSeleccionado!.cargoId != 0) {
      cargoInicialSeleccionado = cargos.firstWhere((cargo) => cargo.cargoId == cargoSeleccionado!.cargoId);
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Editar Técnico',
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
                        _avatarTecnico != null
                            ? Image.memory(
                                _avatarTecnico!,
                                width: 300,
                                height: 250,
                                fit: BoxFit.cover,
                              )
                            : _avatarTecnico2 != ''
                                ? Image.network(
                                    '$_avatarTecnico2?authorization=$token',
                                    width: 300,
                                    height: 250,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: Placeholder(
                                          child: Text('Error al cargar avatar del técnico'),
                                        ),
                                      );
                                    },
                                  )
                                : const SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: Placeholder(
                                      child: Text('Avatar del técnico'),
                                    ),
                                  ),
                        IconButton(
                          tooltip: 'Subir foto',
                          onPressed: () async {
                            await uploadAvatarTecnico();
                          },
                          icon: const Icon(Icons.upload),
                        ),
                        const SizedBox(height: 10),
                        _firmaTecnico != null
                            ? Image.memory(
                                _firmaTecnico!,
                                width: 300,
                                height: 109,
                                fit: BoxFit.cover,
                              )
                            : _firmaTecnico2 != ''
                                ? Image.network(
                                    '$_firmaTecnico2?authorization=$token',
                                    width: 300,
                                    height: 109,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: Placeholder(
                                          child: Text('Error al cargar la firma del técnico'),
                                        ),
                                      ); 
                                    },
                                  )
                                : const SizedBox(
                                    width: 250,
                                    height: 109,
                                    child: Placeholder(
                                      child: Text('Firma del técnico'),
                                    ),
                                  ),
                        IconButton(
                          tooltip: 'Subir firma',
                          onPressed: () async {
                            await uploadFirmaTecnico();
                          },
                          icon: const Icon(Icons.upload),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text('Código'),
                          const SizedBox(width: 10,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: CustomTextFormField(
                              enabled: false,
                              maxLines: 1,
                              label: 'Código',
                              controller: _codController,
                            ),
                          ),
                          const SizedBox(width: 40,),
                        ],
                      ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Fecha de Nacimiento'),
                          const SizedBox(width: 10,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: CustomTextFormField(
                              label: 'Fecha de nacimiento',
                              textAling: TextAlign.center,
                              controller: _dateNacimientoController,
                              onSaved: (value) {
                                _setDate = value!;
                              },
                  
                            ),
                          ),
                          IconButton(
                              onPressed: () => _selectFechaNacimiento(context),
                              icon: Icon(
                                Icons.edit,
                                color: colors.secondary,
                              )),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text('Cargo'),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: CustomDropdownFormMenu(
                              isDense: true,
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
                          const SizedBox(width: 40,),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text('Fecha de ingreso'),
                          const SizedBox(width: 10,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: CustomTextFormField(
                              label: 'Fecha de ingreso',
                              textAling: TextAlign.center,
                              controller: _dateIngresoController,
                              onSaved: (value) {
                                _setDate = value!;
                              },
                            ),
                          ),
                          IconButton(
                              onPressed: () => _selectFechaIngreso(context),
                              icon: Icon(
                                Icons.edit,
                                color: colors.secondary,
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text('Fecha vto carnet de salud'),
                          const SizedBox(width: 10,),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: CustomTextFormField(
                              label: 'Fecha Vto Carne de Salud',
                              textAling: TextAlign.center,
                              controller: _dateCarneSaludController,
                              onSaved: (value) {
                                _setDate = value!;
                              },
                            ),
                          ),
                          IconButton(
                              onPressed: () =>
                                  _selectFechaVtoCarneSalud(context),
                              icon: Icon(
                                Icons.edit,
                                color: colors.secondary,
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Text('Ver día siguiente en la app'),
                          Switch(
                            value: verDiaSiguiente, 
                            onChanged: (value) {
                              verDiaSiguiente = value;
                              setState(() {});
                            },
                          )
                        ],
                      )
                    ],
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
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    elevation: WidgetStatePropertyAll(10),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(50),
                          right: Radius.circular(50)
                        )
                      )
                    )
                  ),
                  onPressed: () async {
                    await postTecnico();
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
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    elevation: WidgetStatePropertyAll(10),
                    shape: WidgetStatePropertyAll(
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
                        fontSize: 20
                      ),
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
  
  Future<String> calculateMD5(List<int> bytes) async {
    var md5c = md5.convert(bytes);
    return md5c.toString();
  }

  Future postTecnico() async {
    print('Entre al metodo');
    if(_avatarTecnico != null){
      avatarBytes = _avatarTecnico as List<int>;
      print('pase el avatarBytes');
      md5Avatar = await calculateMD5(avatarBytes);
      print('md5Avatar');
      print(md5Avatar);
    }
    if(_firmaTecnico != null){
      print('entre al if firma');
      firmaBytes = _firmaTecnico as List<int>;
      md5Firma = await calculateMD5(firmaBytes);
    }
    selectedTecnico.codTecnico = _codController.text;
    selectedTecnico.documento = _docController.text;
    selectedTecnico.nombre = _nombreController.text;
    selectedTecnico.fechaNacimiento = DateTime(selectedDateNacimiento.year, selectedDateNacimiento.month, selectedDateNacimiento.day);
    selectedTecnico.cargo = cargoSeleccionado!.cargoId == 0 ? cargos[0] : cargoSeleccionado;
    selectedTecnico.cargoId = cargoSeleccionado!.cargoId == 0 ? cargos[0].cargoId : cargoSeleccionado!.cargoId;
    selectedTecnico.fechaIngreso = DateTime(selectedDateIngreso.year, selectedDateIngreso.month, selectedDateIngreso.day);
    selectedTecnico.fechaVtoCarneSalud = DateTime(selectedDateCarneSalud.year, selectedDateCarneSalud.month, selectedDateCarneSalud.day);
    selectedTecnico.avatarMd5 = md5Avatar != '' ? md5Avatar : '';
    selectedTecnico.firmaMd5 = md5Firma != '' ? md5Firma : '';
    selectedTecnico.verDiaSiguiente = verDiaSiguiente;

    if (selectedTecnico.tecnicoId == 0) {
      await TecnicoServices().postTecnico(context, selectedTecnico, token);
      if(_firmaTecnico != null && selectedTecnico.tecnicoId != 0){
        await TecnicoServices().putTecnicoFirma(context, selectedTecnico.tecnicoId, token, _firmaTecnico, firmaName, md5Firma);
      }
      if(_avatarTecnico != null && selectedTecnico.tecnicoId != 0){
        await TecnicoServices().putTecnicoAvatar(context, selectedTecnico.tecnicoId, token, _avatarTecnico, avatarName, md5Avatar);
      }

    } else {
      await TecnicoServices().putTecnico(context, selectedTecnico, token);
      if(_firmaTecnico != null){
        await TecnicoServices().putTecnicoFirma(context, selectedTecnico.tecnicoId, token, _firmaTecnico, firmaName, md5Firma);
      }
      if(_avatarTecnico != null){
        await TecnicoServices().putTecnicoAvatar(context, selectedTecnico.tecnicoId, token, _avatarTecnico, avatarName, md5Avatar);
      }
    }
    setState(() {
      tieneId = true;
    });
  }

  Row tipoDato(String tipoDato, TextEditingController controller) {
    return Row(
      children: [
        Text(tipoDato),
        const SizedBox(width: 10,),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          child: CustomTextFormField(
            mascara: tipoDato == 'Documento' ? [maskFormatter] : [],
            maxLines: 1,
            label: tipoDato,
            controller: controller,
          ),
        ),
        const SizedBox(width: 40,),
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
