import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/tipos_ptos_inspeccion_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class TiposPuntosDesktop extends StatefulWidget {
  const TiposPuntosDesktop({super.key});

  @override
  State<TiposPuntosDesktop> createState() => _TiposPuntosDesktopState();
}

class _TiposPuntosDesktopState extends State<TiposPuntosDesktop> {
  late List<TipoPtosInspeccion> tiposPuntos = [];
  final _tiposPuntosServices = TiposPtosInspeccionServices();
  final _descripcionController = TextEditingController();
  final _codTipoPuntoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final token = context.watch<OrdenProvider>().token;
    return SafeArea(
      child: Scaffold(
        appBar: AppBarDesktop(titulo: 'Tipos de puntos de Inspección',),
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
                        const Text('Codigo: '),
                        const SizedBox(
                          width: 30,
                        ),
                        SizedBox(
                          width: 300,
                          child: CustomTextFormField(
                            controller: _codTipoPuntoController,
                            maxLines: 1,
                            label: 'Codigo',
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
                          Provider.of<OrdenProvider>(context, listen: false).clearSelectedTipo();
                          router.push('/editTiposPunto');
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.5),
                          child: Text(
                            'Crear Tipo de punto',
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
                  itemCount: tiposPuntos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colors.primary,
                          child: Text(
                            tiposPuntos[index].codTipoPuntoInspeccion,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(tiposPuntos[index].descripcion),
                        onTap: () {
                          Provider.of<OrdenProvider>(context, listen: false).setTipoPunto(tiposPuntos[index]);
                          router.push('/editTiposPunto');
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
    List<TipoPtosInspeccion> results = await _tiposPuntosServices.getTiposPtosInspeccion(context, _codTipoPuntoController.text, _descripcionController.text, token);
    setState(() {
      tiposPuntos = results;
    });
  }
}