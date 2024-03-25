// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/plano.dart';
import 'package:sedel_oficina_maqueta/models/pto_inspeccion.dart';

class PlanosServices{
  final _dio = Dio();
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/clientes/';

  static Future<void> showDialogs(BuildContext context, String errorMessage, bool doblePop, bool triplePop) async {
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

  Future<void> mostrarError(BuildContext context, String mensaje) async {
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

  Future getClientPlano(BuildContext context, Cliente cliente, String token) async {
    String link = apiLink += '${cliente.clienteId}/planos';
  
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      final List<dynamic> planoList = resp.data;

      return planoList.map((obj) => Plano.fromJson(obj)).toList();
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

  Future getPuntosPlano(BuildContext context, Cliente cliente, Plano plano, String token) async {
    String link = apiLink += '${cliente.clienteId}/planos/${plano.planoId}/puntos';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      final List<dynamic> ptoList = resp.data;

      return ptoList.map((obj) => Ptoinspeccion.fromJson(obj)).toList();
    } catch (e) {
      print(e);
    }
  }

  Future postPtoInspeccion(BuildContext context, Cliente cliente, Plano plano, Ptoinspeccion ptoinspeccion, String token) async {
    String link = '$apiLink${cliente.clienteId}/planos/${plano.planoId}/puntos/';
    print(link);

    var data = ptoinspeccion.toMap();
    
    print(data);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(link,
          options: Options(
            method: 'POST',
            headers: headers,
          ),
          data: data);
      if (resp.statusCode == 201) {
        ptoinspeccion.puntoInspeccionId = resp.data["puntoInspeccionId"];
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

  Future postPlano(BuildContext context, Cliente cliente, Plano plano, String token) async {
    String link = '$apiLink${cliente.clienteId}/planos/';
    // print(link);

    var data = plano.toMap();
    
    // print(data);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(link,
          options: Options(
            method: 'POST',
            headers: headers,
          ),
          data: data);
      if (resp.statusCode == 201) {
        plano.planoId = resp.data["planoId"];
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
  
  Future deletePlano(BuildContext context, Cliente cliente, Plano plano, String token) async {
    String link = '$apiLink${cliente.clienteId}/planos/${plano.planoId}';
    // print(link);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(link,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );
      if (resp.statusCode == 204) {
        showDialogs(context, 'Plano borrado correctamente', false, false);
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

  Future deletePtoInspeccion(BuildContext context, Cliente cliente, Plano plano, Ptoinspeccion punto, String token) async {
    String link = '$apiLink${cliente.clienteId}/planos/${plano.planoId}/puntos/${punto.puntoInspeccionId}';
    // print(link);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(link,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );
      if (resp.statusCode == 204) {
        
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

  Future putPtoInspeccion(BuildContext context, Cliente cliente, Plano plano, Ptoinspeccion ptoinspeccion, String token) async {
    String link = '$apiLink${cliente.clienteId}/planos/${plano.planoId}/puntos/${ptoinspeccion.puntoInspeccionId}';
    print(link);

    var data = ptoinspeccion.toMap();
    
    print(data);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(link,
          options: Options(
            method: 'PUT',
            headers: headers,
          ),
          data: data);
      if (resp.statusCode == 200) {}
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

  Future patchEstadoPunto(BuildContext context, Cliente cliente, Plano plano, Ptoinspeccion ptoInspeccion,
    String estado, String subEstado,String comentario, DateTime? desde,int? ordenTrabajoId, String token) async {


    String link = '$apiLink${cliente.clienteId}/planos/${plano.planoId}/puntos/${ptoInspeccion.puntoInspeccionId}';
    try {
      var headers =   {'Authorization': token};
      var data = ({
        "desde": desde!.toIso8601String(),
        "estado": estado, 
        "subEstado": subEstado,
        "comentario": comentario,
        "ordenTrabajoId": ordenTrabajoId
      });
      var resp = await _dio.request(link,
          options: Options(
            method: 'PATCH',
            headers: headers,
          ),
          data: data);

      if (resp.statusCode == 200) {
        ptoInspeccion.estado = estado;
        ptoInspeccion.subEstado = subEstado;
        ptoInspeccion.comentario = comentario;
        
      } else {
        mostrarError(
            context, 'Hubo un error al momento de cambiar el estado');
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

  Future patchEstadoPlano(BuildContext context, Cliente cliente, Plano plano, String estado, String token) async {

    String link = '$apiLink${cliente.clienteId}/planos/${plano.planoId}/';
    try {
      var headers =   {'Authorization': token};
      var data = ({
        "estado": estado, 
      });
      var resp = await _dio.request(link,
          options: Options(
            method: 'PATCH',
            headers: headers,
          ),
          data: data);

      if (resp.statusCode == 200) {
        plano.estado = estado;        
      } else {
        mostrarError(
            context, 'Hubo un error al momento de cambiar el estado');
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

  Future putPlano(BuildContext context, Cliente cliente, Plano plano, String token) async {
    String link = '$apiLink${cliente.clienteId}/planos/${plano.planoId}/';
    print(link);

    var data = plano.toMap();
    
    print(data);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(link,
          options: Options(
            method: 'PUT',
            headers: headers,
          ),
          data: data);
      if (resp.statusCode == 200) {
        showDialogs(context, 'Plano editado correctamente', true, false);
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
}