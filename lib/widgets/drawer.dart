import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/menu.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import '../provider/menu_provider.dart';
import 'icon_string.dart';

class BotonesDrawer extends StatefulWidget {
  const BotonesDrawer({super.key});

  @override
  State<BotonesDrawer> createState() => _BotonesDrawerState();
}

class _BotonesDrawerState extends State<BotonesDrawer> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final ordenProvider = context.read<OrdenProvider>(); // Asumiendo que tienes un OrdenProvider

    return FutureBuilder(
      future: menuProvider.cargarData(context, ordenProvider.token),
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay datos disponibles'));
        } else {
          final List<Ruta> rutas = snapshot.data as List<Ruta>;

          return ListView.builder(
            itemCount: rutas.length,
            itemBuilder: (context, index) {
              final Ruta ruta = rutas[index];
              return ExpansionTile(
                title: Text(
                  ruta.camino,
                  style: const TextStyle(color: Colors.black),
                ),
                collapsedIconColor: colors.secondary,
                iconColor: colors.secondary,
                initiallyExpanded: true,
                children: _filaBotones2(ruta.opciones, context),
              );
            },
          );
        }
      },
    );
  }
}

List<Widget> _filaBotones2(List<Opcion> opciones, BuildContext context) {
  final List<Widget> opcionesRet = [];
  for (var opt in opciones) {
    final widgetTemp = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          getIcon(opt.icon, context),
          TextButton(
            onPressed: () {
              Provider.of<OrdenProvider>(context, listen: false).setPageName(opt.texto);
              router.push(opt.ruta);
            },
            child: Text(
              opt.texto,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
    opcionesRet.add(widgetTemp);
  }
  return opcionesRet;
}
