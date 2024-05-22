import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/control.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/control_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';

import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';

class ControlesMobile extends StatefulWidget {
  const ControlesMobile({super.key});

  @override
  State<ControlesMobile> createState() => _ControlesMobileState();
}

class _ControlesMobileState extends State<ControlesMobile> {
  late String token = '';
  final TextEditingController _grupoController = TextEditingController();
  late List<Control> controles = [];
  int buttonIndex = 0;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() {
    token = context.read<OrdenProvider>().token;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Controles',
        ),
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
                  const Text('Grupo: '),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: CustomTextFormField(
                      controller: _grupoController,
                      maxLines: 1,
                      label: 'Grupo',
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
                  switch (buttonIndex) {
                    case 0:
                      Provider.of<OrdenProvider>(context, listen: false)
                          .clearSelectedControl();
                      router.push('/editControles');
                      break;
                    case 1:
                      await buscar(context, token);
                      router.pop();
                      break;
                  }
                },
                showUnselectedLabels: true,
                selectedItemColor: colors.primary,
                unselectedItemColor: colors.primary,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_box_outlined),
                    label: 'Agregar Control',
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
                  itemCount: controles.length,
                  itemBuilder: (context, i) {
                    Control control = controles[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(
                            control.controlId.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(control.pregunta),
                        subtitle: Text(control.grupo),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setControl(control);
                          router.push('/editControles');
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
    List<Control> results = await ControlServices()
        .getControles(context, _grupoController.text, token);
    setState(() {
      controles = results;
    });
  }
}
