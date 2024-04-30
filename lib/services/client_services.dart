// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/servicios_clientes.dart';
import 'package:sedel_oficina_maqueta/models/tipo_clientes.dart';
import 'package:sedel_oficina_maqueta/models/usuarios_x_clientes.dart';
import 'package:flutter/material.dart';

class ClientServices {
  int? statusCode;
  List posts = [];
  List pagina = [];
  String apiUrl = Config.APIURL;

  int limit = 20;
  bool isLoadingMore = false;
  final _dio = Dio();

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

  Future getClientes(BuildContext context, String nombre, String codCliente,
      String? estado, String tecnicoId, String token) async {
    String link = '${apiUrl}api/v1/clientes/?offset=0&sort=nombre';
    bool yaTieneFiltro = true;
    if (nombre != '') {
      link += '&nombre=$nombre';
      yaTieneFiltro = true;
    }
    if (codCliente != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'codCliente=$codCliente';
      yaTieneFiltro = true;
    }
    if (estado != '' && estado != null) {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'estado=$estado';
      yaTieneFiltro = true;
    }
    if (tecnicoId != '' && tecnicoId != '0') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'tecnicoId=$tecnicoId';
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
      final List<dynamic> clienteList = resp.data;

      return clienteList.map((obj) => Cliente.fromJson(obj)).toList();
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

  Future getUsuariosXCliente(BuildContext context, String clienteId, String token) async {
    String link = apiUrl += 'api/v1/clientes/$clienteId/usuarios';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List usuariosXClienteList = resp.data;

      return usuariosXClienteList.map((obj) => UsuariosXCliente.fromJson(obj)).toList();
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

  Future getClienteServices(BuildContext context, String clienteId, String token) async {
    String link = apiUrl += 'api/v1/clientes/$clienteId/servicios';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List serviciosClientesList = resp.data;

      return serviciosClientesList.map((obj) => ServicioCliente.fromJson(obj)).toList();
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

  Future putClienteServices(BuildContext context, String clienteId,
      ServicioCliente? servicio, String servicioId, String token) async {
    String link = apiUrl += 'api/v1/clientes/$clienteId/servicios/$servicioId';
    try {
      var headers = {'Authorization': token};
      final resp = await _dio.request(link,
          data: servicio?.toMap(),
          options: Options(method: 'PUT', headers: headers));

      statusCode = resp.statusCode;

      if (resp.statusCode == 200) {
        showDialogs(context, 'Servicio actualizado correctamente', true, false);
      } else {
        _mostrarError(
            context, 'Hubo un error al momento de editar el servicio');
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

  Future postClienteServices(BuildContext context, String clienteId, ServicioCliente servicioCliente, String token) async {
    try {
      String link = '${apiUrl}api/v1/clientes/$clienteId/servicios';
      var headers = {'Authorization': token};
      var xx = servicioCliente.toMap();
      final resp = await _dio.request(
        link,
        data: xx, 
        options: Options(method: 'POST', headers: headers)
      );

      servicioCliente.clienteServicioId = resp.data['clienteServicioId'];

      if (resp.statusCode == 201) {
        showDialogs(context, 'Servicio agregado correctamente', true, false);
      } else {
        _mostrarError(context, 'Hubo un error al momento de crear el servicio');
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

  Future deleteClienteServices(BuildContext context, String clienteId,
      String servicioId, String token) async {
    try {
      String link = apiUrl;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
          '${link}api/v1/clientes/$clienteId/servicios/$servicioId',
          options: Options(method: 'DELETE', headers: headers));
      if (resp.statusCode == 204) {
        await showDialogs(
            context, 'Servicio borrado correctamente', false, false);
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

  Future getClientesDepartamentos(BuildContext context, String token) async {
    String link = apiUrl += 'api/v1/clientes/departamentos';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List departamentosClientesList = resp.data;

      return departamentosClientesList.map((obj) => Departamento.fromJson(obj)).toList();
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

  Future getTipoClientes(BuildContext context, String token) async {
    String link = apiUrl += 'api/v1/clientes/tipos';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List tiposClientesList = resp.data;

      return tiposClientesList.map((obj) => TipoClientes.fromJson(obj)).toList();
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

  Future putCliente(BuildContext context, Cliente cliente, String token) async {
    String link = apiUrl += 'api/v1/clientes/';
    var headers = {'Authorization': token};

    var map = cliente.toMap();

    try {
      final resp = await _dio.request(link += cliente.clienteId.toString(),
          data: map, options: Options(method: 'PUT', headers: headers));
      print(resp.statusCode);
      if (resp.statusCode == 200) {
        await showDialogs(
            context, 'Cliente actualizado correctamente', false, false);
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

  Future postCliente(BuildContext context, Cliente cliente, String token) async {
    try {
      String link = apiUrl += 'api/v1/clientes/';
      var headers = {'Authorization': token};

      final resp = await _dio.request(link,
          data: cliente.toMap(),
          options: Options(method: 'POST', headers: headers));

      cliente.clienteId = resp.data['clienteId'];

      if (resp.statusCode == 201) {
        showDialogs(context, 'Cliente creado correctamente', false, false);
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

  Future deleteCliente(BuildContext context, Cliente cliente, String token) async {
    try {
      String link = '${apiUrl}api/v1/clientes/';
      var headers = {'Authorization': token};

      final resp = await _dio.request(link += cliente.clienteId.toString(),
          options: Options(method: 'DELETE', headers: headers));
      if (resp.statusCode == 204) {
        showDialogs(context, 'Cliente borrado correctamente', true, true);
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
}
