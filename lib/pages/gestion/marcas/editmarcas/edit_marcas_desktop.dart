// ignore_for_file: avoid_init_to_null

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/marca.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/marcas_services.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class EditMarcasDesktop extends StatefulWidget {
  const EditMarcasDesktop({super.key});

  @override
  State<EditMarcasDesktop> createState() => _EditMarcasDesktopState();
}

class _EditMarcasDesktopState extends State<EditMarcasDesktop> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDateDesde = DateTime.now();
  DateTime selectedDateHasta = DateTime.now();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _dateHastaController = TextEditingController();
  late String token = '';
  late Marca marca = Marca.empty();
  List<Tecnico> tecnicos = [];
  late Tecnico? selectedTecnico = Tecnico.empty();
  late Tecnico? tecnicoIncialSeleccionado = null;
  late bool editar = true;

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
                      lastDate: DateTime(2099)
                    );
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
              child: const Text('Cancelar')
            ),
            TextButton(
              onPressed: () {
                router.pop();
                setState(() {});
              },
              child: const Text('Confirmar')
            ),
          ],
        );
      }
    );
  }

  Future<Null> _selectDateHasta(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar fecha y hora hasta'),
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
                      lastDate: DateTime(2099)
                    );
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
              child: const Text('Cancelar')
            ),
            TextButton(
              onPressed: () {
                router.pop();
                setState(() {});
              },
              child: const Text('Confirmar')
            ),
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
    marca = context.read<OrdenProvider>().marca;
    print('print desde el edit: ${marca.desde}');
    selectedDateDesde = marca.desde;
    selectedDateHasta = marca.hasta!;
    if (tecnicos.isEmpty) {
      loadTecnicos();
    }
    setState(() {});
  }

  Future<void> loadTecnicos() async {
    final loadedTecnicos = await TecnicoServices().getAllTecnicos(context, token);
    setState(() {
      tecnicos = loadedTecnicos;
    });
  }


  @override
  Widget build(BuildContext context) {
     _dateController.text = marca.marcaId != 0 && selectedDateDesde == marca.desde
      ? _formatDateAndTime(marca.desde) : _formatDateAndTime(selectedDateDesde);
    _dateHastaController.text = (marca.marcaId != 0 && selectedDateHasta == marca.hasta)
      ? _formatDateAndTime(marca.hasta) : _formatDateAndTime(selectedDateHasta);
    if (marca.tecnicoId != 0  && tecnicos.isNotEmpty) {
      tecnicoIncialSeleccionado = tecnicos.firstWhere((tec) => tec.tecnicoId == marca.tecnicoId);
      selectedTecnico = tecnicoIncialSeleccionado;
      if(selectedTecnico!.tecnicoId != 0) {
        editar = false;
      }
    }


    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Marcas'),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => _selectDateDesde(context),
                        icon: const Icon(Icons.calendar_month)
                      ),
                      const SizedBox(width: 10,),
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
                        onPressed: () => _selectDateHasta(context),
                        icon: const Icon(Icons.calendar_month)
                      ),
                      const SizedBox(width: 10,),
                      SizedBox(
                        width: 300,
                        child: CustomTextFormField(
                          label: 'Fecha hasta',
                          textAling: TextAlign.center,
                          controller: _dateHastaController,
                          onChanged: (value) {
                            // selectedDateHasta =
                            //     DateTime.parse(value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seleccione una fecha hasta';
                            } else {
                              final fechaDesde = DateFormat.yMd().parse(_dateController.text);
                              print('Estoy validando fechaDesde: $fechaDesde');
                              final fechaHasta = DateFormat.yMd().parse(value);
                              if (fechaHasta.isBefore(fechaDesde)) {
                                return 'La fecha seleccionada es incorrecta seleccione \nuna fecha mayor o igual a la inicial';
                              }
                            }
                            return null;
                          }, 
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 15,),
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(5)),
                        child: DropdownSearch(
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Seleccione un técnico'),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                          enabled: editar,
                          items: tecnicos,
                          selectedItem: selectedTecnico,
                          popupProps: const PopupProps.menu(showSearchBox: true, searchDelay: Duration.zero),
                          onChanged: (value) {
                            setState(() {
                              selectedTecnico = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  BottomAppBar(
                    elevation: 0,
                    color: Colors.transparent,
                    child: Padding(padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [                          
                          CustomButton(
                            onPressed: () async {
                              await postPut(context);
                            },
                            text: 'Guardar',
                            tamano: 20,
                          ),
                          if(marca.marcaId != 0)...[
                            const SizedBox(width: 30,),
                            CustomButton(
                              onPressed: () async {
                                await borrarMarca(marca);
                              },
                              text:'Eliminar',
                              tamano: 20,
                            ),
                          ]
                        ]
                      )
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  borrarMarca(Marca marca) async {
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: const Text('Borrar marca'),
          content: SizedBox(
            width: 300,
            child: Text('Esta por borrar la marca del tecnico ${marca.nombreTecnico} \n\nEsta seguro de querer borrarla?')),
          actions: [
            TextButton(onPressed: (){router.pop();}, child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                await MarcaServices().deleteMarca(context, marca, token);
              },
              child: const Text('Confirmar')),
          ],
        );
      }
    );
  }

  Future<void> postPut(BuildContext context) async {
    marca.desde = selectedDateDesde;
    marca.hasta = selectedDateHasta;
    if(marca.marcaId == 0) {
      marca.tecnicoId = selectedTecnico!.tecnicoId;
    }
    
    if(marca.marcaId == 0){
      await MarcaServices().postMarca(context, marca, token);
    }else{
      await MarcaServices().putMarca(context, marca, token);
    }
    setState(() {});
  }
}