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

class MarcasPageMobile extends StatefulWidget {
  const MarcasPageMobile({super.key});

  @override
  State<MarcasPageMobile> createState() => _MarcasPageMobileState();
}

class _MarcasPageMobileState extends State<MarcasPageMobile> {
  late String token = '';
  List<Tecnico> tecnicos = [];
  Tecnico? selectedTecnico;
  int tecnicoFiltro = 0;
  late DateTimeRange selectedDate = DateTimeRange(start: DateTime.now(), end: DateTime.now());
  List<Marca> marcas = [];
  int buttonIndex = 0;

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
      drawer: Drawer(
        width: MediaQuery.of(context).size.width *0.9,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10,),
                const Text('Seleccione periodo: '),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(colors.secondary)
                      ),
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
                        )
                    ),
                    RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Colors.black),
                        children: <TextSpan>[
                      TextSpan(text: DateFormat('dd/MM/yyyy', 'es').format(selectedDate.start)),
                      const TextSpan(text: ' - '),
                      TextSpan(text: DateFormat('dd/MM/yyyy', 'es').format(selectedDate.end)),
                    ])
                    )
                  ],
                ),
                
                
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Tecnico: '),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width *0.7,
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
            const Spacer(),            
            BottomNavigationBar(
              currentIndex: buttonIndex,
              onTap: (index) async {
                buttonIndex = index;
                switch (buttonIndex){
                  case 0: 
                    await buscar(token);
                  break;
                  case 1:
                    Provider.of<OrdenProvider>(context,listen: false).clearSelectedMarca();
                    router.push('/editMarcas');
                  break;
                }
              },
              showUnselectedLabels: true,
              selectedItemColor: colors.primary,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_box_outlined),
                  label: 'Crear Marca',
                ),
        
              ],
            ),
          ],
        ),
        
      ),
      body: Row(
        children: [
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