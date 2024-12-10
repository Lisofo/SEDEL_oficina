import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sedel_oficina_maqueta/config/router/app_router.dart';
import 'package:sedel_oficina_maqueta/models/cliente.dart';
import 'package:sedel_oficina_maqueta/models/frecuencia.dart';
import 'package:sedel_oficina_maqueta/models/servicios_clientes.dart';
import 'package:sedel_oficina_maqueta/services/servicio_services.dart';
import 'package:sedel_oficina_maqueta/widgets/appbar_desktop.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_button.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_dropdown.dart';
import 'package:sedel_oficina_maqueta/widgets/custom_form_field.dart';
import 'package:sedel_oficina_maqueta/widgets/drawer.dart';

class FrecuenciaServicioDesktop extends StatefulWidget {
  final Cliente cliente;
  final String token;
  final ServicioCliente servicioCliente;
  const FrecuenciaServicioDesktop({super.key, required this.cliente, required this.token, required this.servicioCliente});

  @override
  State<FrecuenciaServicioDesktop> createState() => _FrecuenciaServicioDesktopState();
}

class _FrecuenciaServicioDesktopState extends State<FrecuenciaServicioDesktop> {
  List<Frecuencia> frecuencias = [];
  List<FechasFrecuencias> fechas = [
    FechasFrecuencias(fecha: 'Domingo', activo: false),
    FechasFrecuencias(fecha: 'Lunes', activo: false),
    FechasFrecuencias(fecha: 'Martes', activo: false),
    FechasFrecuencias(fecha: 'Miércoles', activo: false),
    FechasFrecuencias(fecha: 'Jueves', activo: false),
    FechasFrecuencias(fecha: 'Viernes', activo: false),
    FechasFrecuencias(fecha: 'Sábado', activo: false),
  ];
  List<SubFrecuencia> subFrecuencias = [
    SubFrecuencia(frecuenciaId: 1, codFrecuencia: 'SEM', descripcion: 'Semanal'),
    SubFrecuencia(frecuenciaId: 2, codFrecuencia: '15D', descripcion: 'Quincenal'),
    SubFrecuencia(frecuenciaId: 3, codFrecuencia: '30D', descripcion: 'Mensual'),
    SubFrecuencia(frecuenciaId: 4, codFrecuencia: 'CNM', descripcion: 'Cada n meses'),
  ];
  late SubFrecuencia frecuenciaSeleccionada = SubFrecuencia.empty();
  late bool cargando = false;
  final TextEditingController comentarioController = TextEditingController();
  final TextEditingController mesesController = TextEditingController();
  late bool repetir = false;


  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  cargarDatos() async {
    frecuencias = await ServiciosServices().getFrecuencias(context, widget.cliente.clienteId, widget.servicioCliente.clienteServicioId, widget.token);
    cargando = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDesktop(titulo: 'Frecuencia del servicio ${widget.servicioCliente.descripcion}'),
      drawer: const Drawer(
        child: BotonesDrawer(),
      ),
      body: 
      !cargando ? const Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text('Cargando, por favor espere...')
        ],
      ),
    ) : SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: frecuencias.length,
          itemBuilder: (context, i) {
            var frecuencia = frecuencias[i];
            return ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(frecuencia.frecuencia == 'Cada n meses' ? 'Cada ${frecuencia.meses} meses' : frecuencia.frecuencia),
                  const SizedBox(width: 5,),
                  Text(frecuencia.comentario ?? ''),
                  const SizedBox(width: 5,),
                  Text(frecuencia.desde == null ? '' : 'Desde: ${DateFormat('E, d, MMM, yyyy', 'es').format(frecuencia.desde!)}'),
                  const SizedBox(width: 5,),
                  Text(frecuencia.hasta == null ? '' : 'Hasta: ${DateFormat('E, d, MMM, yyyy', 'es').format(frecuencia.hasta!)}')
                ],
              ),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(frecuencia.d != false)
                  const Text('Do, '),
                  if(frecuencia.l != false)
                  const Text('Lu, '),
                  if(frecuencia.ma != false)
                  const Text('Ma, '),
                  if(frecuencia.mi != false)
                  const Text('Mi, '),
                  if(frecuencia.j != false)
                  const Text('Ju, '),
                  if(frecuencia.v != false)
                  const Text('Vi, '),
                  if(frecuencia.s != false)
                  const Text('Sá'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () async {
                      await borrarFrecuencia(context, frecuencia);
                    }, 
                    icon: const Icon(Icons.delete, color: Colors.red,)
                  ),
                  IconButton(
                    onPressed: () async {
                      await editarFrecuencia(context, frecuencia);
                    }, 
                    icon: const Icon(Icons.edit, color: Colors.blue,)
                  ),
                ],
              ),
            );
          }
        )
      ),
      bottomNavigationBar: BottomAppBar(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: 'Agregar frecuencia', 
                  tamano: 20,
                  onPressed: () async {
                    await agregarFrecuencia(context);
                  }
                )
              ],
            ),
          ),
        ),
    );
  }

  Future<void> agregarFrecuencia(BuildContext context) async {
    DateTime? fechaDesde;
    DateTime? fechaHasta;
    
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBd) {
            return AlertDialog(
              title: const Text('Nueva frecuencia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: CustomDropdownFormMenu(
                        hint: 'Seleccione frecuencia',
                        isDense: true,
                        items: subFrecuencias.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.descripcion),
                          );
                        }).toList(),
                        onChanged: (value) {
                          frecuenciaSeleccionada = value;
                          setStateBd((){});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Fecha Desde: '),
                        Text(fechaDesde != null ? DateFormat('dd/MM/yyyy').format(fechaDesde!) : 'No seleccionada'),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            fechaDesde = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            setStateBd(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Fecha Hasta: '),
                        Text(fechaHasta != null ? DateFormat('dd/MM/yyyy').format(fechaHasta!) : 'No seleccionada'),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            fechaHasta = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            setStateBd(() {});
                          },
                        ),
                      ],
                    ),
                    if(frecuenciaSeleccionada.frecuenciaId == 1)...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 270,
                        child: ListView.builder(
                          itemCount: fechas.length,
                          itemBuilder: (context, i) {
                            return CheckboxListTile(
                              title: Text(fechas[i].fecha),
                              value: fechas[i].activo,
                              onChanged: (value) {
                                fechas[i].activo = value!;
                                setStateBd(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    if(frecuenciaSeleccionada.frecuenciaId == 4)...[
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: mesesController,
                        hint: 'Ingrese cantidad de meses',
                        maxLines: 1,
                      )  
                    ],
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: comentarioController,
                      hint: 'Ingrese comentario',
                      maxLines: 1,
                    )
                  ],
                ),
              ),
              actions: [
                const Text('Repetir'),
                Switch(
                  value: repetir, 
                  onChanged: (value){
                    repetir = value;
                    setStateBd((){});
                  }
                ),
                ElevatedButton(
                  onPressed: () async {
                    Frecuencia nuevaFrecuencia = Frecuencia(
                      clienteServFrecuenciaId: 0,
                      clienteServicioId: widget.servicioCliente.clienteServicioId,
                      clienteId: widget.cliente.clienteId,
                      servicioId: widget.servicioCliente.servicioId,
                      codServicio: widget.servicioCliente.codServicio,
                      servicio: widget.servicioCliente.descripcion,
                      frecuenciaId: frecuenciaSeleccionada.frecuenciaId,
                      codFrecuencia: frecuenciaSeleccionada.codFrecuencia,
                      frecuencia: frecuenciaSeleccionada.descripcion,
                      desde: fechaDesde,
                      hasta: fechaHasta,
                      repetir: repetir ? 'S' : 'N',
                      d: fechas[0].activo,
                      l: fechas[1].activo,
                      ma: fechas[2].activo,
                      mi: fechas[3].activo,
                      j: fechas[4].activo,
                      v: fechas[5].activo,
                      s: fechas[6].activo,
                      meses: int.tryParse(mesesController.text),
                      comentario: comentarioController.text
                    );
                    await ServiciosServices().postFrecuencias(context, nuevaFrecuencia, widget.token);
                    frecuencias = await ServiciosServices().getFrecuencias(context, widget.cliente.clienteId, widget.servicioCliente.clienteServicioId, widget.token);
                    setState((){});
                  },
                  child: const Text('Agregar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    router.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> editarFrecuencia(BuildContext context, Frecuencia frec) async {
    DateTime? fechaDesde = frec.desde;
    DateTime? fechaHasta = frec.hasta;
    if(frec.clienteServFrecuenciaId != 0){
      comentarioController.text = frec.comentario!;
      mesesController.text = frec.meses.toString();
      repetir = frec.repetir == 'S' ? true : false;
      if(frec.frecuenciaId == 1) {
        frecuenciaSeleccionada = subFrecuencias[0];
      } else if(frec.frecuenciaId == 2){
        frecuenciaSeleccionada = subFrecuencias[1];
      } else if(frec.frecuenciaId == 3){
        frecuenciaSeleccionada = subFrecuencias[2];
      } else if(frec.frecuenciaId == 4){
        frecuenciaSeleccionada = subFrecuencias[3];
      }
      for(var fecha in fechas) {
        switch (fecha.fecha){
          case 'Domingo' :
            if(frec.d == true){
             fecha.activo = true;
            }
          break;
          case 'Lunes' :
            if(frec.l == true){
             fecha.activo = true;
            }
          break;
          case 'Martes' :
            if(frec.ma == true){
             fecha.activo = true;
            }
          break;
          case 'Miércoles' :
            if(frec.mi == true){
             fecha.activo = true;
            }
          break;
          case 'Jueves' :
            if(frec.j == true){
             fecha.activo = true;
            }
          break;
          case 'Viernes' :
            if(frec.v == true){
             fecha.activo = true;
            }
          break;
          case 'Sábado' :
            if(frec.s == true){
             fecha.activo = true;
            }
          break;
        }
      }
    }
  
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBd) {
            return AlertDialog(
              title: const Text('Editar frecuencia'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: CustomDropdownFormMenu(
                        hint: 'Seleccione frecuencia',
                        isDense: true,
                        value: frecuenciaSeleccionada,
                        items: subFrecuencias.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.descripcion),
                          );
                        }).toList(),
                        onChanged: (value) {
                          frecuenciaSeleccionada = value;
                          setStateBd((){});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Fecha Desde: '),
                        Text(fechaDesde != null ? DateFormat('dd/MM/yyyy').format(fechaDesde!) : 'No seleccionada'),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            fechaDesde = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            setStateBd(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Fecha Hasta: '),
                        Text(fechaHasta != null ? DateFormat('dd/MM/yyyy').format(fechaHasta!) : 'No seleccionada'),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            fechaHasta = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            setStateBd(() {});
                          },
                        ),
                      ],
                    ),
                    if(frecuenciaSeleccionada.frecuenciaId == 1)...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: 270,
                        child: ListView.builder(
                          itemCount: fechas.length,
                          itemBuilder: (context, i) {
                            return CheckboxListTile(
                              title: Text(fechas[i].fecha),
                              value: fechas[i].activo,
                              onChanged: (value) {
                                fechas[i].activo = value!;
                                setStateBd(() {});
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    if(frecuenciaSeleccionada.frecuenciaId == 4)...[
                      const SizedBox(height: 16,),
                      CustomTextFormField(
                        controller: mesesController,
                        hint: 'Ingrese cantidad de meses',
                        maxLines: 1,
                      )  
                    ],
                    const SizedBox(height: 16,),
                    CustomTextFormField(
                      controller: comentarioController,
                      hint: 'Ingrese comentario',
                      maxLines: 1,
                    )
                  ],
                ),
              ),
              actions: [
                const Text('Repetir'),
                Switch(
                  value: repetir, 
                  onChanged: (value){
                    repetir = value;
                    setStateBd((){});
                  }
                ),
                ElevatedButton(
                  onPressed: () async {
                    Frecuencia nuevaFrecuencia = Frecuencia(
                      clienteServFrecuenciaId: frec.clienteServFrecuenciaId,
                      clienteServicioId: frec.clienteServicioId,
                      clienteId: frec.clienteId,
                      servicioId: widget.servicioCliente.servicioId,
                      codServicio: widget.servicioCliente.codServicio,
                      servicio: widget.servicioCliente.descripcion,
                      frecuenciaId: frecuenciaSeleccionada.frecuenciaId,
                      codFrecuencia: frecuenciaSeleccionada.codFrecuencia,
                      frecuencia: frecuenciaSeleccionada.descripcion,
                      desde: fechaDesde,
                      hasta: fechaHasta,
                      repetir: repetir ? 'S' : 'N',
                      d: fechas[0].activo,
                      l: fechas[1].activo,
                      ma: fechas[2].activo,
                      mi: fechas[3].activo,
                      j: fechas[4].activo,
                      v: fechas[5].activo,
                      s: fechas[6].activo,
                      meses: int.tryParse(mesesController.text),
                      comentario: comentarioController.text
                    );
                    await ServiciosServices().putFrecuencias(context, nuevaFrecuencia, widget.token);
                    frecuencias = await ServiciosServices().getFrecuencias(context, widget.cliente.clienteId, widget.servicioCliente.clienteServicioId, widget.token);
                    setState((){
                      comentarioController.text = '';
                    });
                  },
                  child: const Text('Guardar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    router.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> borrarFrecuencia(BuildContext context, Frecuencia frec) async{
    await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Borrar frecuencia'),
          content: Text('Está por borrar la frecuencia ${frec.frecuencia} desde ${DateFormat('dd/MM/yyyy').format(frec.desde!)} hasta ${DateFormat('dd/MM/yyyy').format(frec.hasta!)}.\nEstá seguro de querer borrarla?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await ServiciosServices().deleteFrecuencias(context, frec, widget.token);
                frecuencias = await ServiciosServices().getFrecuencias(context, widget.cliente.clienteId, widget.servicioCliente.clienteServicioId, widget.token);
                setState((){});
              },
              child: const Text('Borrar'),
            ),
            ElevatedButton(
              onPressed: () {
                router.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      }
    );
  }


}