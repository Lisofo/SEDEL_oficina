import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class MenuMobile extends StatefulWidget {
  const MenuMobile({super.key});

  @override
  State<MenuMobile> createState() => _MenuMobileState();
}


 



class _MenuMobileState extends State<MenuMobile> {
  late String name = '';

  @override
  void initState() {
    super.initState();
    name = context.read<OrdenProvider>().username;
  }


  @override
   Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.primary,
          title: const Text(
            'Menú',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: colors.onPrimary),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(name,style: const TextStyle(color: Colors.white, fontSize: 24)),
            )
          ],
        ),
        drawer: const Drawer(
          backgroundColor: Colors.white,
          child: BotonesDrawer(),
        ),
        backgroundColor: Colors.white,
        body: Center(child: Image.asset('images/logo.png')),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
            elevation: 0,
            child: IconButton.filledTonal(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(colors.primary)
              ),
                onPressed: () {
                  logout();
                },
                icon: const Icon(Icons.logout))),
      ),
    );
  }


  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesion'),
          content: const Text('Esta seguro de querer cerrar sesion?'),
          actions: [
            TextButton(
                onPressed: () {
                  router.pop();
                },
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () {
                  Provider.of<OrdenProvider>(context, listen: false)
                      .setToken('');
                  router.pushReplacement('/');
                },
                child: const Text(
                  'Cerrar Sesion',
                  style: TextStyle(color: Colors.red),
                )),
          ],
        );
      },
    );
  }
}