// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/constancia_visita.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:flutter/material.dart';

class OrdenServices {
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/ordenes/';
  final _dio = Dio();
  int? statusCode;

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

  Future<int?> getStatusCode () async {
    return statusCode;
  }

  Future<void> resetStatusCode () async {
    statusCode = null;
  }
  
  Future getOrdenByid(BuildContext context, String id, String token) async {
    String link = apiLink;
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link += id,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> ordenList = resp.data;

      return ordenList.map((obj) => Orden.fromJson(obj)).toList();
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future getOrden(BuildContext context, String clienteId, String tecnicoId, String desde, String hasta, String ordenTrabajoId, String estado, int tipoOrdenId, String token) async {
    bool yaTieneFiltro = false;
    String link = apiLink;
    String linkFiltrado = link += '?sort=fechaDesde&limit=1000';
    yaTieneFiltro = true;
    if (clienteId != '0' && clienteId != '') {
      linkFiltrado += '&clienteId=$clienteId';
      yaTieneFiltro = true;
    }
    if (tecnicoId != '' && tecnicoId != '0') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'tecnicoId=$tecnicoId';
      yaTieneFiltro = true;
    }
    if (desde != '') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'fechaDesde=$desde';
      yaTieneFiltro = true;
    }
    if (hasta != '') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'fechaHasta=$hasta';
      yaTieneFiltro = true;
    }
    if (ordenTrabajoId != '' && ordenTrabajoId != '0') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'ordenTrabajoId=$ordenTrabajoId';
      yaTieneFiltro = true;
    }
    if (estado != '' && ordenTrabajoId != '0') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'estado=$estado';
      yaTieneFiltro = true;
    }
    if (tipoOrdenId != 0 && ordenTrabajoId != '0') {
      yaTieneFiltro ? linkFiltrado += '&' : linkFiltrado += '?';
      linkFiltrado += 'tipoOrdenId=$tipoOrdenId';
      yaTieneFiltro = true;
    }

    print(linkFiltrado);
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        linkFiltrado,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> ordenList = resp.data;
      var retorno = ordenList.map((obj) => Orden.fromJson(obj)).toList();
      print(retorno.length);
      return retorno;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future getOrdenCV(BuildContext context, int ordenId, String token) async {
    String link = '${apiLink}cv?ordenTrabajoId=$ordenId';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> ordenCvList = resp.data;
      var retorno = ordenCvList.map((obj) => ConstanciaVisita.fromJson(obj)).toList();
      print(retorno.length);
      return retorno;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future patchOrden(BuildContext context, Orden orden, String estado, int ubicacionId, String token) async {
    String link = apiLink;
    link += orden.ordenTrabajoId.toString();

    try {
      var headers = {'Authorization': token};
      var data = ({"estado": estado, "ubicacionId": ubicacionId});
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PATCH',
          headers: headers,
        ),
        data: data
      );

      statusCode = 1;
      if (resp.statusCode == 200) {
        orden.estado = estado;
      } else {
        showErrorDialog(context, 'Hubo un error al momento de cambiar el servicio');
      }

      return;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }


  Future patchInicioFin(BuildContext context, Orden orden, String desde, String hasta, String token) async {
    String link = '$apiLink${orden.ordenTrabajoId}/fechas';

    try {
      var headers = {'Authorization': token};
      var data = ({
        "iniciadaEn": desde, 
        "finalizadaEn": hasta
      });
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PATCH',
          headers: headers,
        ),
        data: data
      );

      statusCode = 1;
      if (resp.statusCode == 200) {
        showDialogs(context, "Fechas cambiadas correctamente", true, false);
      } else {
        showErrorDialog(context, 'Hubo un error al momento de cambiar el servicio');
      }

      return;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future cambiarTecnicoDeLaOrden(BuildContext context, Orden orden, int tecnicoId, String token) async {
    String link = apiLink;
    link += orden.ordenTrabajoId.toString();

    try {
      var headers = {'Authorization': token};
      var data = ({"tecnicoId": tecnicoId});
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PUT',
          headers: headers,
        ),
        data: data
      );

      statusCode = 1;
      if (resp.statusCode == 200) {
        orden.tecnico.tecnicoId = tecnicoId;
      } else {
        showErrorDialog(context, 'Hubo un error al momento de cambiar el tecnico');
      }

      return;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future putOrden(BuildContext context, Orden orden, String token) async {
    String link = apiLink;
    link += orden.ordenTrabajoId.toString();

    try {
      var headers = {'Authorization': token};
      var data = orden.toMap();
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PUT',
          headers: headers,
        ),
        data: data
      );

      statusCode = 1;
      if (resp.statusCode == 200) {
        showDialogs(context, 'Orden modificada correctamente', false, false);
      } else {
        showErrorDialog(context, 'Hubo un error al momento de modificar la orden');}

      return;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }
  
  Future postOrden(BuildContext context, Orden orden, String token) async {
    String link = apiLink;

    try {
      var headers = {'Authorization': token};
      var data = orden.toMap();
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data
      );

      statusCode = 1;
      if (resp.statusCode == 201) {
        orden.ordenTrabajoId = resp.data["ordenTrabajoId"];
        showDialogs(context, 'Orden creada correctamente', false, false);
      } else {
        showErrorDialog(context, 'Hubo un error al momento de crear la orden');
      }

      return;
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }

  Future getTipoOrden(BuildContext context, String token) async {
    String link = apiLink;
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link += 'tipos',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List<dynamic> ordenList = resp.data;

      return ordenList.map((obj) => TipoOrden.fromJson(obj)).toList();
    } catch (e) {
      statusCode = 0;
      if (e is DioException) {
        if (e.response != null) {
          final responseData = e.response!.data;
          if (responseData != null) {
            if(e.response!.statusCode == 403){
              showErrorDialog(context, 'Error: ${e.response!.data['message']}');
            }else if(e.response!.statusCode! >= 500) {
              showErrorDialog(context, 'Error: No se pudo completar la solicitud');
            } else{
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }  
}
