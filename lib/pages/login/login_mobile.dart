import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sedel_oficina_maqueta/pages/menu/menu.dart';

class LoginMobile extends StatefulWidget {
  const LoginMobile({super.key});

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  late bool isObscured;
  final _formKey = GlobalKey<FormState>();
  final passwordFocusNode = FocusNode();
  final userFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    isObscured = true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'images/logo.png',
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenido',
                  style: GoogleFonts.inter(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia Sesion en tu cuenta',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 35),
                Form(
                    key: _formKey,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: const BorderSide(),
                              borderRadius: BorderRadius.circular(20)),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: const Icon(Icons.person),
                          prefixIconColor: const Color.fromARGB(255, 41, 146, 41),
                          hintText: 'Ingrese su usuario'),
                    )),
                const SizedBox(height: 20),
                Form(
                    child: TextFormField(
                  obscureText: isObscured,
                  focusNode: passwordFocusNode,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(20)),
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: const Icon(Icons.lock),
                      prefixIconColor: const Color.fromARGB(255, 41, 146, 41),
                      suffixIcon: IconButton(
                        padding: const EdgeInsetsDirectional.only(end: 12.0),
                        icon: isObscured
                            ? const Icon(
                                Icons.visibility_off,
                                color: Colors.black,
                              )
                            : const Icon(Icons.visibility, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                      ),
                      hintText: 'Ingrese su contraseña'),
                )),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.white),
                        elevation: MaterialStatePropertyAll(10),
                        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(50),
                                right: Radius.circular(50))))),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MenuPage(),
                          ));
                    },
                    child: Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
