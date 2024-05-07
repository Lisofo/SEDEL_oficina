import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/plaga.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/plaga_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';


class PlagasMobile extends StatefulWidget {
  const PlagasMobile({super.key});

  @override
  State<PlagasMobile> createState() => _PlagasMobileState();
}

class _PlagasMobileState extends State<PlagasMobile> {
  List<Plaga> plagas = [];
  final _plagaServices = PlagaServices();
  final _descripcionController = TextEditingController();
  final _codPlagaController = TextEditingController();
  int buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Plagas',),
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Descripcion: '),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
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
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text('Codigo: '),
                        const SizedBox(
                          width: 1,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: CustomTextFormField(
                            controller: _codPlagaController,
                            maxLines: 1,
                            label: 'Codigo',
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
                            Provider.of<OrdenProvider>(context, listen: false).clearSelectedPlaga();
                            router.push('/editPlagas');
                          break;
                          case 1:
                            await buscar(context, token);
                            router.pop();
                          break;
                        }
                      },
                      showUnselectedLabels: true,
                      selectedItemColor: colors.primary,
                      unselectedItemColor: Colors.grey,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.add_box_outlined),
                          label: 'Agregar Plaga',
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
                  itemCount: plagas.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(
                            plagas[index].plagaId.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(plagas[index].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setPlaga(plagas[index]);
                          router.push('/editPlagas');
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> buscar(BuildContext context, String token) async {
    List<Plaga> results = await _plagaServices.getPlagas(
        context, _descripcionController.text, _codPlagaController.text, token);
    setState(() {
      plagas = results;
    });
  }
}
