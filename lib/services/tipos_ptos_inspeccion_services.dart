import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/config/config.dart';
import 'package:sedel_oficina_maqueta/models/material_tipo_pto.dart';
import 'package:sedel_oficina_maqueta/models/plaga_tipo_pto.dart';
import 'package:sedel_oficina_maqueta/models/tarea_tipo_pto.dart';
import 'package:sedel_oficina_maqueta/models/tipos_ptos_inspeccion.dart';

class TiposPtosInspeccionServices{
  final _dio = Dio();
  String apiUrl = Config.APIURL;
  late String apiLink = '${apiUrl}api/v1/tipos/puntos/';

  static Future<void> showDialogs(BuildContext context, String errorMessage, bool doblePop, bool triplePop,) async {
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

  Future getTiposPtosInspeccion(BuildContext context, String codigo, String descripcion, String token) async {
    String link = apiLink;
     bool yaTieneFiltro = false;
    if (codigo != '') {
      link += '?codTipoPuntoInspeccion=$codigo';
      yaTieneFiltro = true;
    }
    if (descripcion != '') {
      yaTieneFiltro ? link += '&' : link += '?';
      link += 'descripcion=$descripcion';
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
      final List tipoPtoInspeccionList = resp.data;
      var retorno = tipoPtoInspeccionList.map((e) => TipoPtosInspeccion.fromJson(e)).toList();

      return retorno;
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

  Future deleteTipoPto(BuildContext context, TipoPtosInspeccion tipoPto, String token) async {
    String link = '$apiLink${tipoPto.tipoPuntoInspeccionId}';
    try {
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link,
        options: Options(
          method: 'DELETE', 
          headers: headers
        )
      );
          
      if (resp.statusCode == 204) {
        showDialogs(context, 'Tipo punto de inspección borrado correctamente', true, true);
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

  Future putTipoPto(BuildContext context, TipoPtosInspeccion tipoPto, String token) async {
    String link = '$apiLink${tipoPto.tipoPuntoInspeccionId}';
    try {
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link,
        data: tipoPto.toMap(),
        options: Options(
          method: 'PUT', 
          headers: headers
        )
      );

      if (resp.statusCode == 200) {
        showDialogs(context, 'Tipo de punto de inspección actualizado correctamente', false, false);
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

  Future postTipoPto(BuildContext context, TipoPtosInspeccion tipoPto, String token) async {
    try {
      String link = apiLink;
      var headers = {'Authorization': token};

      final resp = await _dio.request(
        link,
        data: tipoPto.toMap(),
        options: Options(
          method: 'POST', 
          headers: headers
        )
      );
      tipoPto.tipoPuntoInspeccionId = resp.data["tipoPuntoInspeccionId"];
      if (resp.statusCode == 201) {
        showDialogs(context, 'Tipo de punto de inspección creado correctamente', false, false);
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

  Future getMaterialesTiposPtosInspeccion(BuildContext context, int tipoPtoId, String token) async {
    String link = '$apiLink$tipoPtoId/materiales';
  
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List materialesTipoPtoInspeccionList = resp.data;
      var retorno = materialesTipoPtoInspeccionList.map((e) => MaterialTipoPto.fromJson(e)).toList();

      return retorno;
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

  Future postMaterialesTiposPtosInspeccion(BuildContext context, int tipoPtoId, int materialId, String token) async {
    String link = '$apiLink$tipoPtoId/materiales';
    var data = {
      "materialId": materialId
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
      if(resp.statusCode == 201){
        return ;
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

  Future deleteMaterialesTiposPtosInspeccion(BuildContext context, int tipoPtoId, int materialId, String token) async {
    String link = '$apiLink$tipoPtoId/materiales/$materialId';
  
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
        return ;
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

  Future getPlagasTiposPtosInspeccion(BuildContext context, int tipoPtoId, String token) async {
    String link = '$apiLink$tipoPtoId/plagas';
  
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List plagasTipoPtoInspeccionList = resp.data;
      var retorno = plagasTipoPtoInspeccionList.map((e) => PlagaTipoPto.fromJson(e)).toList();

      return retorno;
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

  Future postPlagasTiposPtosInspeccion(BuildContext context, int tipoPtoId, int plagaId, String token) async {
    String link = '$apiLink$tipoPtoId/plagas';
    var data = {
      "plagaId": plagaId
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
      if(resp.statusCode == 201){
        return ;
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

  Future deletePlagasTiposPtosInspeccion(BuildContext context, int tipoPtoId, int plagaId, String token) async {
    String link = '$apiLink$tipoPtoId/plagas/$plagaId';
  
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
        return ;
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

  Future getTareasTiposPtosInspeccion(BuildContext context, int tipoPtoId, String modo, String token) async {
    String link = '$apiLink$tipoPtoId/tareas?modo=$modo';
  
    try {
      var headers = {'Authorization': token};
      var resp = await _dio.request(
        link,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      final List tareasTipoPtoInspeccionList = resp.data;
      var retorno = tareasTipoPtoInspeccionList.map((e) => TareaTipoPto.fromJson(e)).toList();

      return retorno;
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

  Future postTareasTiposPtosInspeccion(BuildContext context, int tipoPtoId, int tareaId, String modo, String token) async {
    String link = '$apiLink$tipoPtoId/tareas';
    var data = {
      "tareaId": tareaId,
      "modo": modo
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
      if(resp.statusCode == 201){
        return ;
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

  Future deleteTareasTiposPtosInspeccion(BuildContext context, int tipoPtoId, int tareaId,String modo, String token) async {
    String link = '$apiLink$tipoPtoId/tareas/$tareaId/$modo';
  
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
        return ;
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