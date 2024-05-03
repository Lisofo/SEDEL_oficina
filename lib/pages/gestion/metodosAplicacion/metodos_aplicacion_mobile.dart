import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';


class MetodosAplicacionMobile extends StatefulWidget {
  const MetodosAplicacionMobile({super.key});

  @override
  State<MetodosAplicacionMobile> createState() => _MetodosAplicacionMobileState();
}

class _MetodosAplicacionMobileState extends State<MetodosAplicacionMobile> {
  late List<MetodoAplicacion> metodos = [];
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _codMetodoController = TextEditingController();
  int buttonIndex = 0;

  
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Metodos de aplicación',),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width *0.9,
          child: Column(
            children: [

              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('Codigo: '),  
                  const SizedBox(width: 1,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *0.6,
                    child: CustomTextFormField(
                      controller: _codMetodoController,
                      maxLines: 1,
                      label: 'Codigo',
                      onFieldSubmitted: (value) async {
                        await buscar(context, token);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text('Descripcion: '),
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
              const Spacer(),
              BottomNavigationBar(
                currentIndex: buttonIndex,
                onTap: (index) async {
                  buttonIndex = index;
                  switch (buttonIndex){
                    case 0: 
                      Provider.of<OrdenProvider>(context, listen: false).clearSelectedMetodo();
                      router.push('/editMetodosAplicacion');
                    break;
                    case 1:
                      await buscar(context, token);
                    break;
                  }
                },
                showUnselectedLabels: true,
                selectedItemColor: colors.primary,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_outlined),
                    label: 'Agregar metodo',
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
                  itemCount: metodos.length,
                  itemBuilder: (context, i) {
                    var metodo = metodos[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(
                            metodo.codMetodoAplicacion,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(metodos[i].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false).setMetodo(metodo);
                          router.push('/editMetodosAplicacion');
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  Future<void> buscar(BuildContext context, String token) async {
    List<MetodoAplicacion> results = await MaterialesServices().getMetodosAplicacion(
        context, _descripcionController.text, _codMetodoController.text, token);
    setState(() {
      metodos = results;
    });
  }
}