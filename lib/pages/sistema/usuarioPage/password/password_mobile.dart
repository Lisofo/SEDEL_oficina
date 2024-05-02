import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/models/usuario.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';
import 'package:sedel_oficina_maqueta/services/user_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_mobile.dart';

import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';


class EditPasswordMobile extends StatefulWidget {
  const EditPasswordMobile({super.key});

  @override
  State<EditPasswordMobile> createState() => _EditPasswordMobileState();
}

class _EditPasswordMobileState extends State<EditPasswordMobile> {
  final _userServices = UserServices();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _pinController = TextEditingController();
  final _rePinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _rePasswordController.dispose();
    _pinController.dispose();
    _rePinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Usuario userSeleccionado = context.read<OrdenProvider>().usuario;
    final token = context.read<OrdenProvider>().token;

    return Scaffold(
      appBar: AppBarMobile(
        titulo: 'Establecer Contraseña',
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Contraseña"),
                  const SizedBox(
                    width: 85,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: CustomTextFormField(
                      maxLines: 1,
                      label: 'Contraseña',
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.length < 6 || value.length > 12) {
                          return 'Ingrese una contraseña valida';
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Reingrese contraseña "),
                  const SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: CustomTextFormField(
                      label: 'Reingrese contraseña',
                      controller: _rePasswordController,
                      maxLines: 1,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Reingrese correctamente la contraseña';
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("PIN"),
                  const SizedBox(
                    width: 130,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: CustomTextFormField(
                      maxLines: 1,
                      label: 'PIN',
                      controller: _pinController,
                      validator: (value) {
                        if (value!.length < 6 || value.length > 12) {
                          return 'Ingrese un PIN valido';
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text("Reingrese PIN"),
                  const SizedBox(
                    width: 65,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: CustomTextFormField(
                      label: 'Reingrese PIN',
                      controller: _rePinController,
                      maxLines: 1,
                      validator: (value) {
                        if (value != _pinController.text) {
                          return 'Reingrese correctamente el PIN';
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colors.primary)
              ),
              height: MediaQuery.of(context).size.height *0.1,
              child: InkWell(
      
                onTap: () async{
                  if (_formKey.currentState!.validate()) {
                                      _userServices.patchPwd(context,userSeleccionado.usuarioId.toString(),_passwordController.text,token);
                                      _userServices.patchPIN(context,userSeleccionado.usuarioId.toString(),_pinController.text,token);
                                    }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: colors.primary,),
                      Text('Guardar', style: TextStyle(color: colors.primary),)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
