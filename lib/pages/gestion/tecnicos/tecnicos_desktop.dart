import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tecnico.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tecnico_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';
import 'package:intl/intl.dart';

class TecnicosPageDesktop extends StatefulWidget {
  const TecnicosPageDesktop({super.key});

  @override
  State<TecnicosPageDesktop> createState() => _TecnicosPageDesktopState();
}

class _TecnicosPageDesktopState extends State<TecnicosPageDesktop> {
  List<Tecnico> tecnicos = [];
  final _tecnicoServices = TecnicoServices();
  final _nombreController = TextEditingController();
  final _documentoController = TextEditingController();
  final _codTecnicoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(
          titulo: 'Tecnicos',
        ),
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
                        const Text('Documento: '),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            controller: _documentoController,
                            maxLines: 1,
                            label: 'Documento',
                            onFieldSubmitted: (value) async {
                              await buscarTecnico(token);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Text('Codigo: '),
                        const SizedBox(
                          width: 30,
                        ),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            controller: _codTecnicoController,
                            maxLines: 1,
                            label: 'Codigo',
                            onFieldSubmitted: (value) async {
                              await buscarTecnico(token);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const Text('Nombre: '),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            maxLines: 1,
                            label: 'Nombre',
                            controller: _nombreController,
                            onFieldSubmitted: (value) async {
                              await buscarTecnico(token);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              elevation: MaterialStatePropertyAll(10),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))))),
                          onPressed: () async {
                            await buscarTecnico(token);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.5),
                            child: Text(
                              'Buscar',
                              style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          )),
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              elevation: MaterialStatePropertyAll(10),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))))),
                          onPressed: () {
                            Provider.of<OrdenProvider>(context, listen: false)
                                .clearSelectedTecnico();
                            router.push('/editTecnicos');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.5),
                            child: Text(
                              'Agregar Tecnico',
                              style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          )),
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
                  itemCount: tecnicos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                             colors.primary,
                          child: Text(
                            tecnicos[index].codTecnico,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(tecnicos[index].nombre),
                        subtitle:
                            Text('Documento: ${tecnicos[index].documento}'),
                        trailing: Text(
                            'Fecha vencimiento del carne de salud: ${DateFormat("E d, MMM, yyyy", 'es').format(tecnicos[index].fechaVtoCarneSalud as DateTime)}'),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setTecnico(tecnicos[index]);
                          router.push('/editTecnicos');
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

  Future<void> buscarTecnico(String token) async {
    List<Tecnico> results = await _tecnicoServices.getTecnicos(
      context, 
      _documentoController.text,
      _codTecnicoController.text,
      _nombreController.text,
      token);
    setState(() {
      tecnicos = results;
    });
  }
}
