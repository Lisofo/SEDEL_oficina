import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/revision_materiales.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/materiales_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class MetodosAplicacionDesktop extends StatefulWidget {
  const MetodosAplicacionDesktop({super.key});

  @override
  State<MetodosAplicacionDesktop> createState() => _MetodosAplicacionDesktopState();
}

class _MetodosAplicacionDesktopState extends State<MetodosAplicacionDesktop> {
  late List<MetodoAplicacion> metodos = [];
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _codMetodoController = TextEditingController();

  
  
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Métodos de aplicación',),
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
                    const SizedBox(height: 10,),
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
                            Provider.of<OrdenProvider>(context, listen: false).clearSelectedMetodo();
                            router.push('/editMetodosAplicacion');
                          },
                          text: 'Agregar método',
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
                  itemCount: metodos.length,
                  itemBuilder: (context, i) {
                    var metodo = metodos[i];
                    return Card(
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: colors.primary,),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(metodos[i].codMetodoAplicacion, style: const TextStyle(color: Colors.white),),
                          )
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
            )
          ],
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