import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/material.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class MaterialesPageDesktop extends StatefulWidget {
  const MaterialesPageDesktop({super.key});

  @override
  State<MaterialesPageDesktop> createState() => _MaterialesPageDesktopState();
}

class _MaterialesPageDesktopState extends State<MaterialesPageDesktop> {
  List<Materiales> materiales = [];
  final _materialesServices = MaterialesServices();
  final _descripcionController = TextEditingController();
  final _codMateriaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Materiales',),
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
                        const Text('Descripción: '),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            controller: _descripcionController,
                            maxLines: 1,
                            label: 'Descripción',
                            onFieldSubmitted: (value) async {
                              await buscar(context, token);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15,),
                    Center(
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                          elevation: WidgetStatePropertyAll(10),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(50),
                                right: Radius.circular(50)
                              )
                            )
                          )
                        ),
                        onPressed: () async {
                          await buscar(context, token);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.5),
                          child: Text(
                            'Buscar',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                        )
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                          elevation: WidgetStatePropertyAll(10),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(50),
                                right: Radius.circular(50)
                              )
                            )
                          )
                        ),
                        onPressed: () {
                          Provider.of<OrdenProvider>(context, listen: false).clearSelectedMaterial();
                          router.push('/editMateriales');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.5),
                          child: Text(
                            'Crear Material',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                        )
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
                  itemCount: materiales.length,
                  itemBuilder: (context, i) {
                    return Card(
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: colors.primary,),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(materiales[i].codMaterial, style: const TextStyle(color: Colors.white),),
                          )
                        ),
                        title: Text(materiales[i].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false).setMateriales(materiales[i]);
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
    List<Materiales> results = await _materialesServices.getMateriales(context, _descripcionController.text, _codMateriaController.text, token);
    setState(() {
      materiales = results;
    });
  }
}
