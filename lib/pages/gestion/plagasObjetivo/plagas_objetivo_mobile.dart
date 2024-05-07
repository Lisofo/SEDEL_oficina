import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/plaga_objetivo.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/plagas_objetivo_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';


class PlagasObjetivoMobile extends StatefulWidget {
  const PlagasObjetivoMobile({super.key});

  @override
  State<PlagasObjetivoMobile> createState() => _PlagasObjetivoMobileState();
}

class _PlagasObjetivoMobileState extends State<PlagasObjetivoMobile> {
  List<PlagaObjetivo> plagasObjetivo = [];
  final _plagaObjetivoServices = PlagaObjetivoServices();
  final _descripcionController = TextEditingController();
  final _codPlagaObjetivoController = TextEditingController();
  int buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Plagas objetivo',),
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
                      width: 30,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: CustomTextFormField(
                        controller: _codPlagaObjetivoController,
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
                        Provider.of<OrdenProvider>(context, listen: false).clearSelectedPlagaObjetivo();
                        router.push('/editPlagasObjetivo');
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
                    )
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
                  itemCount: plagasObjetivo.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(
                            plagasObjetivo[index].plagaObjetivoId.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(plagasObjetivo[index].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setPlagaObjetivo(plagasObjetivo[index]);
                          router.push('/editPlagasObjetivo');
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
    List<PlagaObjetivo> results =
        await _plagaObjetivoServices.getPlagasObjetivo(
            context,
            _descripcionController.text,
            _codPlagaObjetivoController.text,
            token);
    setState(() {
      plagasObjetivo = results;
    });
  }
}
