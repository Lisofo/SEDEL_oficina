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
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class MarcasPageDesktop extends StatefulWidget {
  const MarcasPageDesktop({super.key});

  @override
  State<MarcasPageDesktop> createState() => _MarcasPageDesktopState();
}

class _MarcasPageDesktopState extends State<MarcasPageDesktop> {
  late String token = '';
  List<Tecnico> tecnicos = [];
  Tecnico? selectedTecnico;
  int tecnicoFiltro = 0;
  late DateTimeRange selectedDate = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  List<Marca> marcas = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (tecnicos.isEmpty) {
      loadTecnicos();
    }
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
  }

  Future<void> loadTecnicos() async {
    final token = context.watch<OrdenProvider>().token;
    final loadedTecnicos = await TecnicoServices().getAllTecnicos(context, token);
    setState(() {
      tecnicos = loadedTecnicos;
      tecnicos.insert(
          0,
          Tecnico(
              cargoId: 0,
              tecnicoId: 0,
              codTecnico: '0',
              nombre: 'Todos',
              fechaNacimiento: null,
              documento: '',
              fechaIngreso: null,
              fechaVtoCarneSalud: null,
              deshabilitado: false,
              cargo: null));
    });
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBarDesktop(
        titulo: 'Marcas',
      ),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: Row(
        children: [
          Flexible(
            flex: 2,
            child: Card(
              elevation: 40,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Seleccione periodo: '),
                        TextButton(
                            onPressed: () async {
                              final pickedDate = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2023),
                                  lastDate: DateTime(2025));

                              if (pickedDate != null &&
                                  pickedDate != selectedDate) {
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: const Text(
                              'Período',
                              style: TextStyle(color: Colors.black),
                            )),
                        RichText(
                            text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: <TextSpan>[
                              TextSpan(text: DateFormat('dd/MM/yyyy', 'es').format(selectedDate.start)),
                              const TextSpan(text: ' - '),
                              TextSpan(text: DateFormat('dd/MM/yyyy', 'es').format(selectedDate.end)),
                            ]))
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text('Tecnico: '),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 220,
                          child: DropdownSearch(
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                        hintText: 'Seleccione un tecnico')),
                            items: tecnicos,
                            popupProps: const PopupProps.menu(
                                showSearchBox: true,
                                searchDelay: Duration.zero),
                            onChanged: (value) {
                              setState(() {
                                selectedTecnico = value;
                                tecnicoFiltro = value!.tecnicoId;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30,),
                    Center(
                      child: CustomButton(
                        onPressed: () async {
                          await buscar(token);
                        },
                        text: 'Buscar',
                        tamano: 20,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: CustomButton(
                        onPressed: () {
                          Provider.of<OrdenProvider>(context,listen: false).clearSelectedMarca();
                          router.push('/editMarcas');
                        },
                        text: 'Crear marca',
                        tamano: 20,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: marcas.length,
                    itemBuilder: (context, i) {
                      Marca marca = marcas[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.primary,
                            child: Text(marca.marcaId.toString(), style: const TextStyle(color: Colors.white),),
                          ),
                          title: Text('${marca.codTecnico} - ${marca.nombreTecnico}'),
                          subtitle: Column(
                            children: [
                              if(marca.modo == '') ... [
                                Text('Entrada: ${marca.ubicacion} - Salida: `${marca.ubicacionHasta}'),
                              ] 
                              else ... [
                                Text('Entrada: ${marca.ubicacion} - Salida: `${marca.ubicacionHasta}'),
                                const SizedBox(height: 10,),
                                const Text('Modo: Administrativo'),
                              ]
                            ],
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(DateFormat('d/MM/yyyy').format(marca.desde)),
                              const SizedBox(height: 8,),
                              Text(marca.hasta != null ? DateFormat('d/MM/yyyy').format(marca.hasta!) : 'No marcó salida'),
                            ],
                          ),
                          onTap: (){
                            Provider.of<OrdenProvider>(context, listen: false).setMarca(marca);
                            router.push('/editMarcas');
                          },
                        ),
                      );
                    }, 
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> buscar(String token) async {
    String fechaDesde = ('${selectedDate.start.year}-${selectedDate.start.month}-${selectedDate.start.day}');
    String fechaHasta = ('${selectedDate.end.year}-${selectedDate.end.month}-${selectedDate.end.day} 23:59:59');
    String tecnicoId = selectedTecnico != null ? selectedTecnico!.tecnicoId.toString() : '';

    List<Marca> results = await MarcaServices().getMarca(
      context, 
      tecnicoId,
      fechaDesde,
      fechaHasta,
      token,
    );
    setState(() {
      marcas = results;
    });
  }
}