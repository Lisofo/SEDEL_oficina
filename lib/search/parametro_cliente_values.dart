// ignore_for_file: overridden_fields

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/informes_values.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/informes_services.dart';


class ParametroClientSearchDelegate extends SearchDelegate {
  @override
  final String searchFieldLabel;
  final List<ParametrosValues> historial;
  final int informeId;
  final int parametroId;
  ParametroClientSearchDelegate(this.searchFieldLabel, this.historial, this.informeId, this.parametroId);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
      IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.more_horiz)
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_ios_new),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Text('No hay criterios de búsqueda');
    }

    final clientServices = InformesServices();
    final token = context.watch<OrdenProvider>().token;

    final List<String> searchParams = query.split(" ");

    String id = '';
    String descripcion = '';

    if (searchParams.length >= 2) {
      id = searchParams[0];
      descripcion = searchParams.sublist(1).join(' ');
    } else {
      if (int.tryParse(searchParams[0]) != null) {
        id = searchParams[0];
        descripcion = '';
      } else {
        id = '';
        descripcion = searchParams[0];
      }
    }

    return FutureBuilder(
      // Especifica explícitamente el tipo de dato para el FutureBuilder
      future: clientServices.getParametrosValues(context, token, informeId, parametroId, id, descripcion),
      builder: (_, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const ListTile(
            title: Text('No hay ningún cliente con ese nombre'),
          );
        }

        if (snapshot.hasData) {
          return _showClient(snapshot.data!);
        } else {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 4),
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _showClient(historial);
  }

  Widget _showClient(List<ParametrosValues> clients) {
    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, i) {
        final cliente = clients[i];
        return ListTile(
          title: Text(cliente.descripcion.toString()),
          onTap: () {
            close(context, cliente);
          },
        );
      }
    );
  }
}
