// To parse this JSON data, do
//
//     final usuariosXCliente = usuariosXClienteFromMap(jsonString);

import 'dart:convert';

List<UsuariosXCliente> usuariosXClienteFromMap(String str) =>
    List<UsuariosXCliente>.from(
        json.decode(str).map((x) => UsuariosXCliente.fromJson(x)));

String usuariosXClienteToMap(List<UsuariosXCliente> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class UsuariosXCliente {
  late int usuarioId;
  late String login;
  late String usuario;
  late int clienteId;
  late String codCliente;
  late String cliente;
  late String direccion;
  late String telefono1;
  late String email;

  UsuariosXCliente({
    required this.usuarioId,
    required this.login,
    required this.usuario,
    required this.clienteId,
    required this.codCliente,
    required this.cliente,
    required this.direccion,
    required this.telefono1,
    required this.email,
  });

  factory UsuariosXCliente.fromJson(Map<String, dynamic> json) =>
      UsuariosXCliente(
        usuarioId: json["usuarioId"] as int? ?? 0,
        login: json["login"] as String? ?? '',
        usuario: json["usuario"] as String? ?? '',
        clienteId: json["clienteId"] as int? ?? 0,
        codCliente: json["codCliente"] as String? ?? '',
        cliente: json["cliente"] as String? ?? '',
        direccion: json["direccion"] as String? ?? '',
        telefono1: json["telefono1"] as String? ?? '',
        email: json["email"] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        "usuarioId": usuarioId,
        "login": login,
        "usuario": usuario,
        "clienteId": clienteId,
        "codCliente": codCliente,
        "cliente": cliente,
        "direccion": direccion,
        "telefono1": telefono1,
        "email": email,
      };

  UsuariosXCliente.empty() {
    usuarioId = 0;
    login = '';
    usuario = '';
    clienteId = 0;
    codCliente = '';
    cliente = '';
    direccion = '';
    telefono1 = '';
    email = '';
  }
}
