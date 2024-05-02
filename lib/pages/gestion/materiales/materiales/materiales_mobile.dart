import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_container.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class MaterialesPageMobile extends StatefulWidget {
  const MaterialesPageMobile({super.key});

  @override
  State<MaterialesPageMobile> createState() => _MaterialesPageMobileState();
}

class _MaterialesPageMobileState extends State<MaterialesPageMobile> {
  List<Materiales> materiales = [];
  final _materialesServices = MaterialesServices();
  final _descripcionController = TextEditingController();
  final _codMateriaController = TextEditingController();
  int buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Materiales',),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.9,
          child: CustomContainer(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Codigo:'),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: CustomTextFormField(
                          controller: _codMateriaController,
                          maxLines: 1,
                          label: 'Codigo',
                          onFieldSubmitted: (value) async {
                            await buscar(context, token);
                            router.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: colors.primary,
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text('Descripcion:'),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: CustomTextFormField(
                          controller: _descripcionController,
                          maxLines: 1,
                          label: 'Descripcion',
                          onFieldSubmitted: (value) async {
                            await buscar(context, token);
                            router.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  BottomNavigationBar(
                    elevation: 0,
                    currentIndex: buttonIndex,
                    onTap: (index) async {
                      buttonIndex = index;
                      switch (buttonIndex){
                        case 0: 
                          await buscar(context, token);
                          router.pop();
                        break;
                        case 1:
                          Provider.of<OrdenProvider>(context, listen: false).clearSelectedMaterial();
                          router.push('/editMateriales');
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
                        label: 'Crear Material',
                      ),
              
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 4,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: materiales.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(
                            materiales[index].codMaterial,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(materiales[index].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false).setMateriales(materiales[index]);
                          router.push('/editMateriales');
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
    List<Materiales> results = await _materialesServices.getMateriales(context,
        _descripcionController.text, _codMateriaController.text, token);
    setState(() {
      materiales = results;
    });
  }
}
