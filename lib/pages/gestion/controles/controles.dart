import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/control.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/control_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class ControlesPage extends StatefulWidget {
  const ControlesPage({super.key});

  @override
  State<ControlesPage> createState() => _ControlesPageState();
}

class _ControlesPageState extends State<ControlesPage> {
  late String token = '';
  final TextEditingController _grupoController = TextEditingController();
  late List<Control> controles = [];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }
  
  cargarDatos(){
    token = context.read<OrdenProvider>().token;
  }
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Controles',),
        drawer: const Drawer(
          child: BotonesDrawer(),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Grupo: '),
                        SizedBox(
                          width: 300,
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
                    const SizedBox(height: 20,),
                    Center(
                      child: CustomButton(
                        onPressed: () async {
                          await buscar(context, token);
                        },
                        text: 'Buscar',
                        tamano: 20,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: CustomButton(
                        onPressed: () {
                          Provider.of<OrdenProvider>(context, listen: false).clearSelectedControl();
                          router.push('/editControles');
                        },
                        text: 'Agregar control',
                        tamano: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                          Provider.of<OrdenProvider>(context, listen: false).setControl(control);
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
    List<Control> results = await ControlServices().getControles(
        context, _grupoController.text, token);
    setState(() {
      controles = results;
    });
  }
}