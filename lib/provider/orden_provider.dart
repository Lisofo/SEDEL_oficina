import 'package:flutter/material.dart';
import 'package:sedel_oficina_maqueta/models/marca.dart';
import '../models/indisponibilidades.dart';
import '../models/revision_materiales.dart';
import '../models/cliente.dart';
import '../models/orden.dart';
import '../models/material.dart';
import '../models/plaga.dart';
import '../models/plaga_objetivo.dart';
import '../models/revision_pto_inspeccion.dart';
import '../models/servicio.dart';
import '../models/tarea.dart';
import '../models/tecnico.dart';
import '../models/tipos_ptos_inspeccion.dart';
import '../models/usuario.dart';
import '../models/control.dart';

class OrdenProvider with ChangeNotifier {
  String _modo = '';
  String _menu = '';
  String _menuName = '';
  String _token = '';
  String _username = '';
  int? _statusCode = 0;

  bool _pendientes = false;

  TipoPtosInspeccion _tipoPtosInspeccion = TipoPtosInspeccion.empty();
  List<RevisionPtoInspeccion> _ptosInspeccion = [];
  RevisionPtoInspeccion _revisionPtoInspeccion = RevisionPtoInspeccion.empty();

  Orden _orden = Orden.empty();
  Indisponibilidad _indisponibilidad = Indisponibilidad.empty();
  Cliente _cliente = Cliente.empty();
  Cliente _clienteIndisponibilidad = Cliente.empty();
  Cliente _clienteEditIndisponibilidad = Cliente.empty();
  Cliente _clienteMonitoreo = Cliente.empty();
  Cliente _clienteMapa = Cliente.empty();
  Cliente _clientePlanificador = Cliente.empty();
  Cliente _clienteOrdenes = Cliente.empty();
  Cliente _clienteEditOrdenes = Cliente.empty();
  Tecnico _tecnico = Tecnico.empty();
  Tarea _tarea = Tarea.empty();
  Servicio _servicio = Servicio.empty();
  Plaga _plaga = Plaga.empty();
  PlagaObjetivo _plagaObjetivo = PlagaObjetivo.empty();
  Usuario _usuario = Usuario.empty();
  Materiales _materiales = Materiales.empty();
  MetodoAplicacion _metodoAplicacion = MetodoAplicacion.empty();
  Control _control = Control.empty();
  Marca _marca = Marca.empty();
  int _revisionId = 0;


  // Getters
  String get modo => _modo;
  String get menu => _menu;
  String get menuName => _menuName;
  String get token => _token;
  String get username => _username;
  bool get pendientes => _pendientes;
  int? get statusCode => _statusCode;

  TipoPtosInspeccion get tipoPtosInspeccion => _tipoPtosInspeccion;
  List<RevisionPtoInspeccion> get ptosInspeccion => _ptosInspeccion;
  List<RevisionPtoInspeccion> get puntosSeleccionados =>
      _ptosInspeccion.where((pto) => pto.seleccionado).toList();
  List<RevisionPtoInspeccion> get puntosFiltrados => _ptosInspeccion
      .where((pto) =>
          pto.tipoPuntoInspeccionId == tipoPtosInspeccion.tipoPuntoInspeccionId)
      .toList();
  List<RevisionPtoInspeccion> get listaPuntos => puntosFiltrados
      .where((element) => _pendientes
          ? element.codAccion == ''
          : element.codAccion == element.codAccion)
      .toList();

  Orden get orden => _orden;
  Indisponibilidad get indisponibilidad => _indisponibilidad;
  Cliente get cliente => _cliente;
  Cliente get clienteIndisponibilidad => _clienteIndisponibilidad;
  Cliente get clienteEditIndisponibilidad => _clienteEditIndisponibilidad;
  Cliente get clienteOrdenes => _clienteOrdenes;
  Cliente get clienteEditOrdenes => _clienteEditOrdenes;
  Cliente get clienteMonitoreo => _clienteMonitoreo;
  Cliente get clienteMapa => _clienteMapa;
  Cliente get clientePlanificador => _clientePlanificador;
  Tecnico get tecnico => _tecnico;
  Tarea get tarea => _tarea;
  Servicio get servicio => _servicio;
  Plaga get plaga => _plaga;
  PlagaObjetivo get plagaObjetivo => _plagaObjetivo;
  Usuario get usuario => _usuario;
  Materiales get materiales => _materiales;
  MetodoAplicacion get metodoAplicacion => _metodoAplicacion;
  RevisionPtoInspeccion get revisionPtoInspeccion => _revisionPtoInspeccion;
  Control get control => _control;
  Marca get marca => _marca;
  int get revisionId => _revisionId;

  // Setters
  void setPendiente(bool pendi) {
    _pendientes = pendi;
    notifyListeners();
  }

  void setModo(String modo) {
    _modo = modo;
    notifyListeners();
  }

  void setOrden(Orden orden) {
    _orden = orden;
    notifyListeners();
  }

  void setIndisponibilidad(Indisponibilidad indis) {
    _indisponibilidad = indis;
    notifyListeners();
  }

  void setStatusCode(int? statusCode){
    _statusCode = statusCode;
    notifyListeners();
  }

  void setPage(String codPages) {
    _menu = codPages;
    notifyListeners();
  }

  void setPageName(String codPagesName) {
    _menuName = codPagesName;
    notifyListeners();
  }

  void setToken(String tok) {
    _token = tok;
    notifyListeners();
  }
  void setUsername(String user) {
    _username = user;
    notifyListeners();
  }

  void setCliente(Cliente cli, String nombreMenu) {
    switch (nombreMenu) {
      case 'Monitoreo':
        _clienteMonitoreo = cli;
        break;
      case 'Mapa':
        _clienteMapa = cli;
        break;
      case 'Planificador':
        _clientePlanificador = cli;
        break;
      case 'Ordenes':
        _clienteOrdenes = cli;
        break;
      case 'editOrdenes':
        _clienteEditOrdenes = cli;
        break;
      case 'Indisponibilidad':
        _clienteIndisponibilidad = cli;
        break;
      case 'editIndisponibilidad':
        _clienteEditIndisponibilidad = cli;
        break;
      default:
        _cliente = cli;
    }

    notifyListeners();
  }

  clearSelectedCliente(String nombreMenu) {
    switch (nombreMenu) {
      case 'Monitoreo':
        _clienteMonitoreo = Cliente.empty();
        break;
      case 'Mapa':
        _clienteMapa = Cliente.empty();
        break;
      case 'Planificador':
        _clientePlanificador = Cliente.empty();
        break;
      case 'Ordenes':
        _clienteOrdenes = Cliente.empty();
        break;
      case 'editOrdenes':
        _clienteEditOrdenes = Cliente.empty();
        break;
      case 'Indisponibilidad':
        _clienteIndisponibilidad = Cliente.empty();
        break;
      case 'editIndisponibilidad':
        _clienteEditIndisponibilidad = Cliente.empty();
        break;
      default:
        _cliente = Cliente.empty();
    }
    notifyListeners();
  }

  void setTecnico(Tecnico tec) {
    _tecnico = tec;
    notifyListeners();
  }

  void clearSelectedTecnico() {
    _tecnico = Tecnico.empty();
    notifyListeners();
  }
  
  void clearSelectedOrden() {
    _orden = Orden.empty();
    notifyListeners();
  }

  void setTarea(Tarea task) {
    _tarea = task;
    notifyListeners();
  }

  void clearSelectedTarea() {
    _tarea = Tarea.empty();
    notifyListeners();
  }

  void setServicio(Servicio service) {
    _servicio = service;
    notifyListeners();
  }

  void clearSelectedServicio() {
    _servicio = Servicio.empty();
    notifyListeners();
  }

  void clearSelectedIndisponibilidad() {
    _indisponibilidad = Indisponibilidad.empty();
    notifyListeners();
  }

  void setPlaga(Plaga pest) {
    _plaga = pest;
    notifyListeners();
  }

  void clearSelectedPlaga() {
    _plaga = Plaga.empty();
    notifyListeners();
  }

  void setPlagaObjetivo(PlagaObjetivo pestObjetivo) {
    _plagaObjetivo = pestObjetivo;
    notifyListeners();
  }

  void clearSelectedPlagaObjetivo() {
    _plaga = Plaga.empty();
    notifyListeners();
  }

  void setUsuario(Usuario user) {
    _usuario = user;
    notifyListeners();
  }

  void clearSelectedUsuario() {
    _usuario = Usuario.empty();
    notifyListeners();
  }
  void clearSelectedMetodo() {
    _metodoAplicacion = MetodoAplicacion.empty();
    notifyListeners();
  }

  void setMateriales(Materiales materials) {
    _materiales = materials;
    notifyListeners();
  }
  void setMetodo(MetodoAplicacion metodo) {
    _metodoAplicacion = metodo;
    notifyListeners();
  }

  void clearSelectedMaterial() {
    _materiales = Materiales.empty();
    notifyListeners();
  }

  void setPI(List<RevisionPtoInspeccion> listaPI) {
    _ptosInspeccion = listaPI;
    notifyListeners();
  }

  void setTipoPTI(TipoPtosInspeccion tPI) {
    _tipoPtosInspeccion = tPI;
    notifyListeners();
  }

  void setRevisionPI(RevisionPtoInspeccion revisionPI) {
    _revisionPtoInspeccion = revisionPI;
    notifyListeners();
  }

  void actualizarPunto(int i, RevisionPtoInspeccion punto) {
    puntosSeleccionados[i] = punto;
    notifyListeners();
  }

  void setControl(Control ctrl) {
    _control = ctrl;
    notifyListeners();
  }

  void clearSelectedControl() {
    _control = Control.empty();
    notifyListeners();
  }

  void setMarca(Marca mark) {
    _marca = mark;
    notifyListeners();
  }

  void clearSelectedMarca(){
    _marca = Marca.empty();
    notifyListeners();
  }

  void setRevisionId(int revision){
    _revisionId = revision;
    notifyListeners();
  }
}
