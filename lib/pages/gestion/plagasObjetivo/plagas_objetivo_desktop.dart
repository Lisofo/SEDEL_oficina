import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/plaga_objetivo.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/plagas_objetivo_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class PlagasObjetivoDesktop extends StatefulWidget {
  const PlagasObjetivoDesktop({super.key});

  @override
  State<PlagasObjetivoDesktop> createState() => _PlagasObjetivoDesktopState();
}

class _PlagasObjetivoDesktopState extends State<PlagasObjetivoDesktop> {
  List<PlagaObjetivo> plagasObjetivo = [];
  final _plagaObjetivoServices = PlagaObjetivoServices();
  final _descripcionController = TextEditingController();
  final _codPlagaObjetivoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Plagas objetivo',),
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
                        const Text('Descripcion: '),
                        SizedBox(
                          width: 300,
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
                    Center(
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                              elevation: WidgetStatePropertyAll(10),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))))),
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
                                  fontSize: 20),
                            ),
                          )),
                    ),
                    const Spacer(),
                    Center(
                      child: ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.white),
                              elevation: WidgetStatePropertyAll(10),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(50),
                                          right: Radius.circular(50))))),
                          onPressed: () {
                            Provider.of<OrdenProvider>(context, listen: false).clearSelectedPlagaObjetivo();
                            router.push('/editPlagasObjetivo');
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.5),
                            child: Text(
                              'Agregar Plaga',
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
                  itemCount: plagasObjetivo.length,
                  itemBuilder: (context, i) {
                    return Card(
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: colors.primary,),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(plagasObjetivo[i].codPlagaObjetivo, style: const TextStyle(color: Colors.white),),
                          )
                        ),
                        title: Text(plagasObjetivo[i].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false)
                              .setPlagaObjetivo(plagasObjetivo[i]);
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
      token
    );
    setState(() {
      plagasObjetivo = results;
    });
  }
}
