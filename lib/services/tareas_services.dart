// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/tarea.dart';
import 'package:sedel_oficina_maqueta/models/tareaXtpi.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';

class TareasServices {
  final _dio = Dio();
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/tareas/';

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

  Future getTareaById(BuildContext context, String id, String token) async {
    try {
      var headers = {'Authorization': token};
      String link = apiLink;
      var resp = await _dio.request(
        link += id,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      final Tarea tarea = Tarea.fromJson(resp.data);

      return tarea;
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

  Future getTareas(BuildContext context, String descripcion, String codTarea, String token) async {
    bool yaTieneFiltro = false;
    String link = apiLink;
    if (descripcion != '') {
      link += '?descripcion=$descripcion';
      yaTieneFiltro = true;
    }
    if (codTarea != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'codTarea=$codTarea';
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
      final List<dynamic> tareaList = resp.data;

      return tareaList.map((obj) => Tarea.fromJson(obj)).toList();
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

  Future putTarea(BuildContext context, Tarea tarea, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(link += tarea.tareaId.toString(),
          data: tarea.toMap(),
          options: Options(method: 'PUT', headers: headers));

      if (resp.statusCode == 200) {
        showDialogs(context, 'Tarea actualizada correctamente', false, false);
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

  Future postTarea(BuildContext context, Tarea tarea, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(link,
          data: tarea.toMap(),
          options: Options(method: 'POST', headers: headers));

      tarea.tareaId = resp.data["tareaId"];

      if (resp.statusCode == 201) {
        showDialogs(context, 'Tarea creada correctamente', false, false);
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

  Future deleteTarea(BuildContext context, Tarea tarea, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(link += tarea.tareaId.toString(),
          options: Options(method: 'DELETE', headers: headers));
          
      if (resp.statusCode == 204) {
        showDialogs(context, 'Tarea borrada correctamente', true, true);
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

  Future getTareasXTPI(BuildContext context, TipoPtosInspeccion tPI,String modo, String token) async {
    String link = '${apiUrl}api/v1/tipos/puntos/${tPI.tipoPuntoInspeccionId}/tareas?modo=$modo';

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List<dynamic> tareaXPTIList = resp.data;

      return tareaXPTIList.map((obj) => TareaXtpi.fromJson(obj)).toList();
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
