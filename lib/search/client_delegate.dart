// ignore_for_file: overridden_fields

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';

import '../services/client_services.dart';

class ClientSearchDelegate extends SearchDelegate {
  @override
  final String searchFieldLabel;
  final List<Cliente> historial;
  final String nombreProvider;
  ClientSearchDelegate(this.searchFieldLabel, this.historial, this.nombreProvider);

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

    final clientServices = ClientServices();
    final token = context.watch<OrdenProvider>().token;

    final List<String> searchParams = query.split(" ");

    String codigo = '';
    String nombre = '';

    if (searchParams.length >= 2) {
      codigo = searchParams[0];
      nombre = searchParams.sublist(1).join(' ');
    } else {
      if (int.tryParse(searchParams[0]) != null) {
        codigo = searchParams[0];
        nombre = '';
      } else {
        codigo = '';
        nombre = searchParams[0];
      }
    }

    return FutureBuilder(
      // Especifica explícitamente el tipo de dato para el FutureBuilder
      future: clientServices.getClientes(context, nombre, codigo.toString(), '', '', token),
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

  Widget _showClient(List<Cliente> clients) {
    return ListView.builder(
      itemCount: clients.length,
      itemBuilder: (context, i) {
        final cliente = clients[i];
        return ListTile(
          title: Text(cliente.nombre.toString()),
          subtitle: Text(cliente.codCliente.toString()),
          onTap: () {
            Provider.of<OrdenProvider>(context, listen: false).setCliente(cliente,nombreProvider);
            close(context, cliente);
          },
        );
      }
    );
  }
}
