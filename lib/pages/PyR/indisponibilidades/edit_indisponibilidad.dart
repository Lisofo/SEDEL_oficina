// ignore_for_file: unused_field, avoid_init_to_null

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/indisponibilidades.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/indis_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/button_delegate.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:intl/intl.dart';

class EditIndisponibilidad extends StatefulWidget {
  const EditIndisponibilidad({super.key});

  @override
  State<EditIndisponibilidad> createState() => _EditIndisponibilidadState();
}

class _EditIndisponibilidadState extends State<EditIndisponibilidad> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _clienteController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();
  List<TipoIndisponibilidad> tipoIndisponibilidad = [];
  late Indisponibilidad indisponibilidad = Indisponibilidad.empty();
  List<Tecnico> tecnicos = [];
  late String _setDate;
  late String dateTime;
  late TipoIndisponibilidad selectedTipo = TipoIndisponibilidad.empty();
  late Tecnico? selectedTecnico = Tecnico.empty();
  DateTime selectedDateDesde = DateTime.now();
  DateTime selectedDateHasta = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _dateHastaController = TextEditingController();
  late String token = '';
  late Cliente? clienteIndis = Cliente.empty();
  late bool tieneId = false;
  bool ejecutando = false;
  late TipoIndisponibilidad? indisponibilidadInicialSeleccionada = null;
  late Tecnico? tecnicoIncialSeleccionado = null;

  Future<Null> _selectDateDesde(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Seleccionar fecha y hora desde'),
            content: StatefulBuilder(
              builder: (context, setStateBd) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Fecha'),
                    subtitle: Text(DateFormat('EEEE d , MMM, yyyy', 'es').format(selectedDateDesde)),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDateDesde,
                          initialDatePickerMode: DatePickerMode.day,
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2099));
                      if (picked != null) {
                        setStateBd(() {
                          selectedDateDesde = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Hora'),
                    subtitle: Text(_formatTime(selectedDateDesde)),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateDesde),
                      );
                      if (pickedTime != null) {
                        selectedDateDesde = DateTime(
                          selectedDateDesde.year,
                          selectedDateDesde.month,
                          selectedDateDesde.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      }
                      setStateBd(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    router.pop();
                  },
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () {
                    router.pop();
                    setState(() {});
                  },
                  child: const Text('Confirmar')),
            ],
          );
        });
  }

  Future<Null> _selectDateHasta(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Seleccionar fecha y hora desde'),
            content: StatefulBuilder(
              builder: (context, setStateBd) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Fecha'),
                    subtitle: Text(DateFormat('EEEE d , MMM, yyyy', 'es').format(selectedDateHasta)),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDateHasta,
                          initialDatePickerMode: DatePickerMode.day,
                          firstDate: DateTime(2015),
                          lastDate: DateTime(2099));
                      if (picked != null) {
                        setStateBd(() {
                          selectedDateHasta = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Hora'),
                    subtitle: Text(_formatTime(selectedDateHasta)),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDateHasta),
                      );
                      if (pickedTime != null) {
                        selectedDateHasta = DateTime(
                          selectedDateHasta.year,
                          selectedDateHasta.month,
                          selectedDateHasta.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      }
                      setStateBd(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    router.pop();
                  },
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () {
                    router.pop();
                    setState(() {});
                  },
                  child: const Text('Confirmar')),
            ],
          );
        });
  }

  String _formatDateAndTime(DateTime? date) {
    return '${date?.day.toString().padLeft(2, '0')}/${date?.month.toString().padLeft(2, '0')}/${date?.year.toString().padLeft(4, '0')} ${date?.hour.toString().padLeft(2, '0')}:${date?.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime? date) {
    return '${date?.hour.toString().padLeft(2, '0')}:${date?.minute.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    indisponibilidad = context.read<OrdenProvider>().indisponibilidad;
    tipoIndisponibilidad = await IndisponibilidadServices().getTiposIndisponibilidades(context, token);
    selectedDateDesde = indisponibilidad.desde;
    selectedDateHasta = indisponibilidad.hasta;
    if (indisponibilidad.indisponibilidadId != 0) {
      _clienteController.text = indisponibilidad.cliente!.nombre;
      _obsController.text = indisponibilidad.comentario;

      if (indisponibilidad.tecnico?.tecnicoId != 0 &&
          tecnicos.isNotEmpty &&
          indisponibilidad.tipoIndisponibilidad.tipoIndisponibilidadId == 3) {
        tecnicoIncialSeleccionado = tecnicos.firstWhere(
            (tec) => tec.tecnicoId == indisponibilidad.tecnico?.tecnicoId);
      }
    }
    tieneId = indisponibilidad.indisponibilidadId > 0;

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (tecnicos.isEmpty) {
      loadTecnicos();
    }
  }

  Future<void> loadTecnicos() async {
    final loadedTecnicos = await TecnicoServices().getAllTecnicos(context, token);
    setState(() {
      tecnicos = loadedTecnicos;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (indisponibilidad.indisponibilidadId != 0) {
      indisponibilidadInicialSeleccionada = indisponibilidad.tipoIndisponibilidad;
      _clienteController.text = indisponibilidad.cliente!.nombre;
    }
    _dateController.text = indisponibilidad.indisponibilidadId != 0 &&
            selectedDateDesde == indisponibilidad.desde
        ? _formatDateAndTime(indisponibilidad.desde)
        : _formatDateAndTime(selectedDateDesde);
    _dateHastaController.text = (indisponibilidad.indisponibilidadId != 0 &&
            selectedDateHasta == indisponibilidad.hasta)
        ? _formatDateAndTime(indisponibilidad.hasta)
        : _formatDateAndTime(selectedDateHasta);
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBarDesktop(
        titulo: 'Edicion de indisponibilidad',
      ),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: _globalKey,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (indisponibilidad.indisponibilidadId == 0) ...[
                                          SizedBox(
                                            width: 300,
                                            child: CustomDropdownFormMenu(
                                              hint: 'Seleccione una indisponibilidad',
                                              value: indisponibilidadInicialSeleccionada,
                                              items: tipoIndisponibilidad.map((e) => DropdownMenuItem(
                                                        value: e,
                                                        child: Text(
                                                          e.descripcion,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Seleccione un tipo de indisponibilidad';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedTipo = value!;
                                                });
                                              },
                                              onSaved: (value) {
                                                selectedTipo = value!;
                                              },
                                            ),
                                          )
                                        ] else ...[
                                          SizedBox(
                                            width: 300,
                                            child: CustomTextFormField(
                                              label: 'Tipo de indisponibilidad',
                                              enabled: false,
                                              initialValue: indisponibilidadInicialSeleccionada?.descripcion,
                                            ),
                                          )
                                        ],
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          children: [
                                            IconButton.filledTonal(
                                                onPressed: () =>
                                                    _selectDateDesde(context),
                                                icon: const Icon(
                                                    Icons.calendar_month)),
                                            SizedBox(
                                              width: 300,
                                              child: CustomTextFormField(
                                                label: 'Fecha desde',
                                                textAling: TextAlign.center,
                                                controller: _dateController,
                                                onChanged: (value) {
                                                  // selectedDateDesde =
                                                  //     DateTime.parse(value).;
                                                  // print(selectedDateDesde);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20,),
                                        Row(
                                          children: [
                                            IconButton.filledTonal(
                                                onPressed: () =>
                                                    _selectDateHasta(context),
                                                icon: const Icon(
                                                    Icons.calendar_month)),
                                            SizedBox(
                                              width: 300,
                                              child: CustomTextFormField(
                                                label: 'Fecha hasta',
                                                textAling: TextAlign.center,
                                                controller:
                                                    _dateHastaController,
                                                onChanged: (value) {
                                                  // selectedDateHasta =
                                                  //     DateTime.parse(value);
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Seleccione una fecha hasta';
                                                  } else {
                                                    final fechaDesde =
                                                        DateFormat.yMd().parse(
                                                            _dateController
                                                                .text);
                                                    final fechaHasta =
                                                        DateFormat.yMd()
                                                            .parse(value);
                                                    if (fechaHasta
                                                        .isBefore(fechaDesde)) {
                                                      return 'La fecha seleccionada es incorrecta seleccione \nuna fecha mayor o igual a la inicial';
                                                    }
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        if (indisponibilidad.tipoIndisponibilidad.tipoIndisponibilidadId == 2 || selectedTipo.tipoIndisponibilidadId == 2) ...[
                                          Row(
                                            children: [
                                              if (indisponibilidad.indisponibilidadId != 0) ...[
                                                const Icon(Icons.groups),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  width: 300,
                                                  child: CustomTextFormField(
                                                    enabled: false,
                                                    controller:
                                                        _clienteController,
                                                    label: 'Cliente',
                                                  ),
                                                ),
                                              ] else ...[
                                                const ButtonDelegate(
                                                  colorSeleccionado: Colors.black,
                                                  nombreProvider:'editIndisponibilidad'
                                                )
                                              ]
                                            ],
                                          )
                                        ],
                                        if (indisponibilidad.tipoIndisponibilidad.tipoIndisponibilidadId == 3 || selectedTipo.tipoIndisponibilidadId == 3) ...[
                                          Container(
                                            width: 300,
                                            decoration: BoxDecoration(
                                                border: Border.all(),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: DropdownSearch(
                                              dropdownDecoratorProps:
                                                  const DropDownDecoratorProps(
                                                      dropdownSearchDecoration:
                                                          InputDecoration(
                                                              hintText:
                                                                  'Seleccione un tecnico')),
                                              items: tecnicos,
                                              enabled: indisponibilidad
                                                      .indisponibilidadId ==
                                                  0,
                                              selectedItem:
                                                  tecnicoIncialSeleccionado,
                                              popupProps: const PopupProps.menu(
                                                  showSearchBox: true,
                                                  searchDelay: Duration.zero),
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedTecnico = value;
                                                });
                                              },
                                              validator: (value) {
                                                if (selectedTipo.descripcion ==
                                                    '') {
                                                  return null;
                                                }
                                                if (selectedTipo.descripcion ==
                                                    'GENERAL') {
                                                  if (value != null &&
                                                      value.tecnicoId != 0) {
                                                    return 'Campo invalido';
                                                  } else {
                                                    return null;
                                                  }
                                                } else if (selectedTipo
                                                        .descripcion ==
                                                    'CLIENTE') {
                                                  if (value != null &&
                                                      value.tecnicoId != 0) {
                                                    return 'Campo invalido';
                                                  } else {
                                                    return null;
                                                  }
                                                } else if (selectedTipo
                                                        .descripcion ==
                                                    'TECNICO') {
                                                  if (value == null ||
                                                      value.tecnicoId == 0) {
                                                    return "Seleccione un tecnico";
                                                  } else {
                                                    return null;
                                                  }
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                        const SizedBox(
                                          height: 50,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 150,
                                    ),
                                    Column(
                                      children: [
                                        const Text(
                                          'Observaciones',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        SizedBox(
                                            width: 500,
                                            height: 400,
                                            child: CustomTextFormField(
                                              label: 'Observaciones',
                                              controller: _obsController,
                                              maxLines: 20,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Campo requerido';
                                                }
                                                if (value.trim().isEmpty) {
                                                  return 'Campo requerido';
                                                }
                                                return null;
                                              },
                                            )),
                                      ],
                                    ),
                                    const SizedBox(width: 150,),
                                  ],
                                ),
                                const Spacer(),
                                BottomAppBar(
                                  elevation: 0,
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CustomButton(
                                          onPressed: () async {
                                            await postIndis(context);
                                          },
                                          tamano: 20,
                                          text: 'Guardar',
                                        ),
                                        const SizedBox(
                                          width: 30,
                                        ),
                                        if (tieneId)
                                          CustomButton(
                                            onPressed: () async {
                                              await borrarIndis(
                                                  context, token);
                                            },
                                            text: 'Eliminar',
                                            tamano: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> postIndis(BuildContext context) async {
    if (!ejecutando) {
      ejecutando = true;
      clienteIndis = context.read<OrdenProvider>().clienteEditIndisponibilidad;
      indisponibilidad.desde = selectedDateDesde;
      indisponibilidad.hasta = selectedDateHasta;
      indisponibilidad.comentario = _obsController.text;
      indisponibilidad.tipoIndisponibilidad = selectedTipo;
      indisponibilidad.tipoIndisponibilidadId = selectedTipo.tipoIndisponibilidadId;
      indisponibilidad.cliente = clienteIndis;
      if (selectedTipo.tipoIndisponibilidadId == 2) {
        indisponibilidad.clienteId = clienteIndis!.clienteId;
      }
      if (selectedTipo.tipoIndisponibilidadId == 3) {
        indisponibilidad.tecnicoId = selectedTecnico!.tecnicoId;
      }
      if (_globalKey.currentState?.validate() == true) {
        if (indisponibilidad.indisponibilidadId == 0) {
          await IndisponibilidadServices()
              .postIndisponibilidad(context, indisponibilidad, token);
        } else {
          await IndisponibilidadServices()
              .putIndisponibilidad(context, indisponibilidad, token);
        }

        setState(() {
          tieneId = true;
        });
      }
      ejecutando = false;
    }
  }

  Future<dynamic> borrarIndis(BuildContext context, String token) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar accion'),
          content: const Text('Desea borrar la indisponibilidad?'),
          actions: [
            TextButton(
              onPressed: () async {
                IndisponibilidadServices().deleteindisponibilidad(context, indisponibilidad, token);
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
