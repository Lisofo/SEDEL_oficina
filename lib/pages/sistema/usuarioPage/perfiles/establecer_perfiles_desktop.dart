// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/perfil.dart';
import 'package:sedel_oficina_maqueta/models/perfil_usuario.dart';
import 'package:sedel_oficina_maqueta/models/usuario.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/user_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';


class EstablecerPerfilesDesktop extends StatefulWidget {
  const EstablecerPerfilesDesktop({super.key});

  @override
  State<EstablecerPerfilesDesktop> createState() => _EstablecerPerfilesDesktopState();
}

class _EstablecerPerfilesDesktopState extends State<EstablecerPerfilesDesktop> {
  late List<Perfil> perfiles = [];
  late String token = '';
  bool activo =  false;
  late List<int> perfilesId = [];
  late List<PerfilUsuario> perfilesUsuario = [];
  late Usuario user = Usuario.empty();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    token = context.read<OrdenProvider>().token;
    user = context.read<OrdenProvider>().usuario;
    perfiles = await UserServices().getPerfiles(context, token);
    perfilesUsuario = await UserServices().getUsuarioPerfiles(context, user, token);
    for (var perfil in perfiles) {
      activo = perfilesUsuario.any((pu) => pu.perfilId == perfil.perfilId);
      perfil.activo = activo;
      if (activo) {
        perfilesId.add(perfil.perfilId);
      }
  }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarMobile(titulo: 'Establecer perfiles de usuario ${user.nombre}'),
      
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              child: SizedBox(
                height: 300,
                width: 400,
                child:ListView.separated(
                  itemCount: perfiles.length,
                  itemBuilder: (context, i){
                    return SwitchListTile(
                      value: perfiles[i].activo,
                      onChanged: (value) async {
                        setState(() {
                          perfiles[i].activo = value;
                        });
                        if (value) {
                          perfilesId.add(perfiles[i].perfilId);
                          await UserServices().postUsuarioPerfiles(context, user, perfiles[i].perfilId, token);
                        } else {
                          perfilesId.remove(perfiles[i].perfilId);
                          await UserServices().deleteUsuarioPerfiles(context, user, perfiles[i].perfilId, token);
                        }
                      },
                      title: Text(perfiles[i].nombre),
                      );
                  }, 
                  separatorBuilder: (BuildContext context, int index) {
                     return const Divider();
                  }
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}