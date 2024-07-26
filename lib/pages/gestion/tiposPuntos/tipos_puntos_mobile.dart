import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tipos_ptos_inspeccion_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class TiposPuntosMobile extends StatefulWidget {
  const TiposPuntosMobile({super.key});

  @override
  State<TiposPuntosMobile> createState() => _TiposPuntosMobileState();
}

class _TiposPuntosMobileState extends State<TiposPuntosMobile> {
  late List<TipoPtosInspeccion> tiposPuntos = [];
  final _tiposPuntosServices = TiposPtosInspeccionServices();
  final _descripcionController = TextEditingController();
  final _codTipoPuntoController = TextEditingController();
  int buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Tipos de puntos de Inspección',
        ),
        drawer:  Drawer(
          width: MediaQuery.of(context).size.width *0.9,
          child: Column(
            children: [
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('Descripcion: '),
                  const SizedBox(width: 1,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *0.6,
                    child: CustomTextFormField(
                      controller: _descripcionController,
                      maxLines: 1,
                      label: 'Descripcion',
                      onFieldSubmitted: (value) async {
                        await buscar(context, token);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              Divider(color: colors.primary,),
              const Spacer(),
              BottomNavigationBar(
                currentIndex: buttonIndex,
                onTap: (index) async {
                  buttonIndex = index;
                  switch (buttonIndex){
                    case 0:
                     Provider.of<OrdenProvider>(context, listen: false).clearSelectedTipo();
                     router.push('/editTiposPunto');
                    break;
                    case 1:
                      await buscar(context, token);
                    break;
                  }
                },
                showUnselectedLabels: true,
                selectedItemColor: colors.primary,
                unselectedItemColor: colors.primary,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_outlined),
                    label: 'Agregar Tipo de punto',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Buscar',
                  ),
                ],
              ),  
            ],
          ),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: [
            Flexible(
              flex: 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: tiposPuntos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(
                            tiposPuntos[index].codTipoPuntoInspeccion,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(tiposPuntos[index].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false).setTipoPunto(tiposPuntos[index]);
                          router.push('/editTiposPunto');
                        },
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> buscar(BuildContext context, String token) async {
    List<TipoPtosInspeccion> results = await _tiposPuntosServices.getTiposPtosInspeccion(context, _codTipoPuntoController.text, _descripcionController.text, token);
    setState(() {
      tiposPuntos = results;
    });
    router.pop();
  }
}