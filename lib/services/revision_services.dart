// ignore_for_file: unused_element, unused_local_variable, avoid_print, use_build_context_synchronously, prefer_typing_uninitialized_variables
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/clientesFirmas.dart';
import 'package:sedel_oficina_maqueta/models/observacion.dart';
import 'package:sedel_oficina_maqueta/models/orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_orden.dart';
import 'package:sedel_oficina_maqueta/models/revision_plaga.dart';
import 'package:sedel_oficina_maqueta/models/revision_tarea.dart';
import 'package:sedel_oficina_maqueta/provider/orden_provider.dart';

class RevisionServices {
  final _dio = Dio();
  String apiLink = Config.APIURL;
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

  Future getRevisiones(BuildContext context, Orden orden, String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      final List revisionesList = resp.data;
      var retorno = revisionesList.map((e) => RevisionOrden.fromJson(e)).toList();

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

  Future getRevision(BuildContext context, Orden orden, int revisionId, String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );

      statusCode = 1;
      String firmaDisponible = resp.data["firmaClienteDisponible"];
      return firmaDisponible;
      
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
  
  Future postRevision(BuildContext context, int uId, Orden orden, String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones';
    var data = ({"idUsuario": uId, "ordinal": 0, "comentario": ""});
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

      statusCode = 1;
      if (resp.statusCode == 201) {
        orden.otRevisionId = resp.data["otRevisionId"];
        print(resp);
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

  Future copyRevision(BuildContext context, Orden orden, RevisionOrden revision,  String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/${revision.otRevisionId}/copiar';

    var data = {
      "comentario": revision.comentario,
      "tipoRevision": revision.tipoRevision
    };
    
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

      statusCode = 1;
      if (resp.statusCode == 201) {
        revision.otRevisionId = resp.data["otRevisionId"];
        print(resp);
        await showDialogs(context, 'Copiado correctamente', true, false);
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

  Future deleteRevision(BuildContext context, Orden orden, RevisionOrden revision,  String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/${revision.otRevisionId}/';
    
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );

      statusCode = 1;
      if (resp.statusCode == 204) {
       await showDialogs(context, 'Revisión borrada correctamente', true, false);
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

  Future postObservacion(BuildContext context, Orden orden, Observacion obs, int revisionId, String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/observaciones';
    var data = obs.toMap();
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

      statusCode = 1;
      if (resp.statusCode == 201) {
        obs.otObservacionId = resp.data["otObservacionId"];
        showDialogs(context, 'Observaciones guardadas', false, false);
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

  Future putObservacion(BuildContext context, Orden orden, Observacion obs, int revisionId, String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/observaciones/${obs.otObservacionId}';
    var data = obs.toMap();
    try {
      var headers = {'Authorization': token};
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
        showDialogs(context, 'Observaciones guardadas', false, false);
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

  Future getObservacion(BuildContext context, Orden orden, Observacion obs, int revisionId, String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/observaciones';

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
      final List observacionList = resp.data;
      var retorno = observacionList.map((e) => Observacion.fromJson(e)).toList();

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

  Future getRevisionTareas(BuildContext context, Orden orden, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/tareas';

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
      final List<dynamic> revisionTareaList = resp.data;

      return revisionTareaList.map((obj) => RevisionTarea.fromJson(obj)).toList();
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

  Future postRevisionTarea(BuildContext context, Orden orden, int tareaId, RevisionTarea revisionTarea, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/tareas';
    var data = ({"idTarea": tareaId, "comentario": ""});

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      statusCode = 1;
      if (resp.statusCode == 201) {
        revisionTarea.otTareaId = resp.data["otTareaId"];
        showDialogs(context, 'Tarea guardada', false, false);
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

  Future deleteRevisionTarea(BuildContext context, Orden orden, RevisionTarea revisionTarea, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/tareas/${revisionTarea.otTareaId}';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );

      statusCode = 1;
      if (resp.statusCode == 204) {
        // showDialogs(context, 'Tarea borrada', true, false);
      }
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

  Future getRevisionPlagas(BuildContext context, Orden orden, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/plagas';

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
      final List<dynamic> revisionPlagasList = resp.data;

      return revisionPlagasList.map((obj) => RevisionPlaga.fromJson(obj)).toList();
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

  Future deleteRevisionPlaga(BuildContext context, Orden orden, RevisionPlaga revisionPlaga, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/plagas/${revisionPlaga.otPlagaId}';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );

      statusCode = 1;
      if (resp.statusCode == 204) {
        // showDialogs(context, 'Plaga borrada', true, false);
      }
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

  Future postRevisionPlaga(BuildContext context, Orden orden, int plagaId, int gradoInfestacionId, RevisionPlaga revisionPlaga, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/plagas';
    var data = ({
      "idPlaga": plagaId,
      "idGradoInfestacion": gradoInfestacionId,
      "comentario": ""
    });

    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      statusCode = 1;
      if (resp.statusCode == 201) {
        revisionPlaga.otPlagaId = resp.data["otPlagaId"];
        showDialogs(context, 'Plaga guardada', false, false);
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

  Future postRevisonFirma(BuildContext context, Orden orden, ClienteFirma firma, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/firmas';

    FormData formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(firma.firma as List<int>, filename: 'imagen.jpg'),
      'nombre': firma.nombre,
      'area': firma.area,
      'firmaMD5': firma.firmaMd5,
      'comentario': ''
    });
    
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.post(
        link,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: headers,
        ),
      );

      statusCode = 1;
      if (resp.statusCode == 201) {
        Provider.of<OrdenProvider>(context,listen: false).setStatusCode(resp.statusCode);
        firma.otFirmaId = resp.data["otFirmaId"];
        showDialogs(context, 'Firma guardada', false, false);
        // print('posteo $statusCode');
      }
      // print('termino posteo $statusCode'); 
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

  Future getRevisionFirmas(BuildContext context, Orden orden, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/firmas';

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
      final List<dynamic> revisionFirmasList = resp.data;

      return revisionFirmasList.map((obj) => ClienteFirma.fromJson(obj)).toList();
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

  Future deleteRevisionFirma(BuildContext context, Orden orden, ClienteFirma revisionFirma, int revisionId, String token) async {
    String link = '${apiLink}api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/firmas/${revisionFirma.otFirmaId}';
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'DELETE',
          headers: headers,
        ),
      );

      statusCode = 1;
      if (resp.statusCode == 204) {
        // showDialogs(context, 'Firma borrada', false, false);
      }
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

  Future putRevisionFirma(BuildContext context, Orden orden, ClienteFirma revisionFirma, String nombre, String area, int revisionId, String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/$revisionId/firmas/${revisionFirma.otFirmaId}';
    var data = ({
      "nombre": nombre,
      "area": area,
    });
    try {
      var headers = {'Authorization': token};
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
        showDialogs(context, 'Datos editados', true, false);
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

  Future patchFirma(BuildContext context, Orden orden, String? disponible, String token) async {
    String link = apiLink;
    link += 'api/v1/ordenes/${orden.ordenTrabajoId}/revisiones/${orden.otRevisionId}/firmas';
    var data = {
      "valor": disponible
    };


    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'PATCH',
          headers: headers,
        ),
        data: data
      );
      statusCode = 1;
      return;
    } catch (e) {
      statusCode = 0;
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
          showErrorDialog(context, 'Error: No se pudo completar la solicitud');
        } 
      } 
    }
  }
}
