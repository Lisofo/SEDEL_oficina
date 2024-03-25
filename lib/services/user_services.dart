// ignore_for_file: use_build_context_synchronously, empty_catches, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/cliente_usuario.dart';
import 'package:sedel_oficina_maqueta/models/perfil.dart';
import 'package:sedel_oficina_maqueta/models/perfil_usuario.dart';
import 'package:sedel_oficina_maqueta/models/usuario.dart';

class UserServices {
  final _dio = Dio();

  static Future<void> showDialogs(BuildContext context, String errorMessage,
      bool doblePop, bool triplePop) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mensaje'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (doblePop) {
                  Navigator.of(context).pop();
                }
                if (triplePop) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarError(BuildContext context, String mensaje) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mensaje'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
  
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/usuarios/';

  Future getUsers(BuildContext context, String login, String nombre, String apellido, String token) async {
    bool yaTieneFiltro = false;
    String link = '$apiLink?sort=nombre&limit=1000';
    yaTieneFiltro = true;
    if (login != '') {
      link += '&login=$login';
      yaTieneFiltro = true;
    }
    if (nombre != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'nombre=$nombre';
      yaTieneFiltro = true;
    }
    if (apellido != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'apellido=$apellido';
      yaTieneFiltro = true;
    }
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> userList = resp.data;

      return userList.map((obj) => Usuario.fromJson(obj)).toList();
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future putUsuario(BuildContext context, Usuario usuario, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(link += usuario.usuarioId.toString(),
          data: usuario.toMap(),
          options: Options(method: 'PUT', headers: headers));

      if (resp.statusCode == 200) {
        showDialogs(context, 'Usuario actualizado correctamente', false, false);
      }
      return;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future postUsuario(BuildContext context, Usuario usuario, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(link,
          data: usuario.toMap(),
          options: Options(method: 'POST', headers: headers));

      usuario.usuarioId = resp.data["usuarioId"];
      if (resp.statusCode == 201) {
        showDialogs(context, 'Usuario creado correctamente', false, false);
      }
      return;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future deleteUser(BuildContext context, Usuario usuario, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(link += usuario.usuarioId.toString(),
          options: Options(method: 'DELETE', headers: headers));
      if (resp.statusCode == 204) {
        showDialogs(context, 'Cambio hecho correctamente', false, false);
      }
      return resp.statusCode;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future patchPwd(BuildContext context, String userId, String password, String token) async {
    String link = apiLink;

    try {
      var headers = {'Authorization': token};

      final resp = await _dio.request(link += userId,
          data: {"password": password},
          options: Options(method: 'PATCH', headers: headers));

      if (resp.statusCode == 200) {
        showDialogs(context, 'Cambio hecho correctamente', false, false);
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future patchPIN(BuildContext context, String userId, String pin, String token) async {
    String link = apiLink;

    try {
      var headers = {'Authorization': token};

      final resp = await _dio.request(link += userId,
          data: {"pin2": pin},
          options: Options(method: 'PATCH', headers: headers));

      if (resp.statusCode == 200) {}
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future getClientUsers(BuildContext context, String userId, String token) async {
    String link = '$apiLink$userId/clientes';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> clientesUserList = resp.data;

      return clientesUserList
          .map((obj) => ClienteUsuario.fromJson(obj))
          .toList();
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future postClientUsers(BuildContext context, String userId, String clienteId, String token) async {
    String link = '$apiLink$userId/clientes';

    try {
      var headers = {'Authorization': token};
      final resp = await _dio.request(link,
          data: {"clienteId": clienteId},
          options: Options(method: 'POST', headers: headers));
      if (resp.statusCode == 201) {
        showDialogs(context, 'Cambio hecho correctamente', true, false);
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future deleteClientUsers(BuildContext context, String userId, String clienteId, String token) async {
    String link = '$apiLink$userId/clientes/$clienteId';

    try {
      var headers = {'Authorization': token};

      final resp = await _dio.request(link,
          options: Options(method: 'DELETE', headers: headers));
      if (resp.statusCode == 204) {
        showDialogs(context, 'Cliente borrado correctamente', true, false);
      }
      return resp.statusCode;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            final errors = responseData['errors'] as List<dynamic>;
            final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            _mostrarError(context, errorMessages.join('\n'));
          } else {
            _mostrarError(context, 'Error: ${e.response!.data}');
          }
        } else {
          _mostrarError(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future getPerfiles(BuildContext context, String token) async {
    String link = '${apiUrl}api/auth/perfiles';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> listaPerfiles = resp.data;

      return listaPerfiles.map((obj) => Perfil.fromJson(obj)).toList();
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }
  
  Future getUsuarioPerfiles(BuildContext context, Usuario user, String token) async {
    String link = '$apiLink${user.usuarioId}/perfiles';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> listaPerfilesUser = resp.data;

      return listaPerfilesUser.map((obj) => PerfilUsuario.fromJson(obj)).toList();
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future postUsuarioPerfiles(BuildContext context, Usuario user, int perfilId, String token) async {
    String link = '$apiLink${user.usuarioId}/perfiles';
    var data = {"perfilId": perfilId};
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data
      );

      if(resp.statusCode == 201){
        return;
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

  Future deleteUsuarioPerfiles(BuildContext context, Usuario user, int perfilId, String token) async {
    String link = '$apiLink${user.usuarioId}/perfiles/$perfilId';
    
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );

      if(resp.statusCode == 204){
        return;
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else{
              final errors = responseData['errors'] as List<dynamic>;
              final errorMessages = errors.map((error) {
              return "Error: ${error['message']}";
            }).toList();
            showErrorDialog(context, errorMessages.join('\n'));
          }
          } else {
            showErrorDialog(context, 'Error: ${e.response!.data}');
          }
        } else {
          showErrorDialog(context, 'Error: ${e.message}');
        }
      }
    }
  }

}
