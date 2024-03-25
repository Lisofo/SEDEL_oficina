import 'dart:convert';

List<ClienteUsuario> clienteUsuarioFromMap(String str) =>
    List<ClienteUsuario>.from(
        json.decode(str).map((x) => ClienteUsuario.fromJson(x)));

String clienteUsuarioToMap(List<ClienteUsuario> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ClienteUsuario {
  late int usuarioId;
  late String login;
  late String usuario;
  late int clienteId;
  late String codCliente;
  late String cliente;
  late String direccion;
  late String telefono1;
  late String email;

  ClienteUsuario({
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

  factory ClienteUsuario.fromJson(Map<String, dynamic> json) => ClienteUsuario(
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
}
