import 'package:go_router/go_router.dart';


import '../../pages/pages.dart';

final router = GoRouter(initialLocation: '/', routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const Login(),
  ),
  GoRoute(
    path: '/menu',
    builder: (context, state) => const MenuPage(),
  ),
  GoRoute(
    path: '/planificador',
    builder: (context, state) => const PlanificadorPage(),
  ),
  GoRoute(
    path: '/ordenesTrabajo',
    builder: (context, state) => const OrdenesPlanificacion(),
  ),
  GoRoute(
    path: '/indisponibilidades',
    builder: (context, state) => const IndisponibilidadesPage(),
  ),
  GoRoute(
    path: '/editIndisponibilidades',
    builder: (context, state) => const EditIndisponibilidad(),
  ),
  GoRoute(
    path: '/mapa',
    builder: (context, state) => const MapaPage(),
  ),
  GoRoute(
    path: '/ordenesMonitoreo',
    builder: (context, state) => const Monitoreo(),
  ),
  GoRoute(
    path: '/clientes',
    builder: (context, state) => const Clientes(),
  ),
  GoRoute(
    path: '/tecnicos',
    builder: (context, state) => const TecnicosPage(),
  ),
  GoRoute(
    path: '/editTecnicos',
    builder: (context, state) => const EditTecnicos(),
  ),
  GoRoute(
    path: '/tareas',
    builder: (context, state) => const TareasPage(),
  ),
  GoRoute(
    path: '/editTareas',
    builder: (context, state) => const EditTareas(),
  ),
  GoRoute(
    path: '/plagas',
    builder: (context, state) => const PlagasPage(),
  ),
  GoRoute(
    path: '/editPlagas',
    builder: (context, state) => const EditPlagasPage(),
  ),
  GoRoute(
    path: '/plagas_objetivo',
    builder: (context, state) => const PlagasObjetivoPage(),
  ),
  GoRoute(
    path: '/editPlagasObjetivo',
    builder: (context, state) => const EditPlagasObjetivoPage(),
  ),
  GoRoute(
    path: '/usuarios',
    builder: (context, state) => const UsuariosPage(),
  ),
  GoRoute(
    path: '/editUsuarios',
    builder: (context, state) => const AddUsuarioPage(),
  ),
  GoRoute(
    path: '/editPwdPin',
    builder: (context, state) => const EditPassword(),
  ),
  GoRoute(
    path: '/establecerClientes',
    builder: (context, state) => const EstablecerClientes(),
  ),
  GoRoute(
    path: '/servicios',
    builder: (context, state) => const ServiciosPage(),
  ),
  GoRoute(
    path: '/editServicios',
    builder: (context, state) => const EditServiciosPage(),
  ),
  GoRoute(
    path: '/materiales',
    builder: (context, state) => const MaterialesPage(),
  ),
  GoRoute(
    path: '/editMateriales',
    builder: (context, state) => const EditMaterialesPage(),
  ),
  GoRoute(
    path: '/revisionOrden',
    builder: (context, state) => const RevisionOrdenMain()
  ),
  GoRoute(
    path: '/ptosInspeccionActividad',
    builder: (context, state) => const RevisionPtosInspeccionActividad(),
  ),
  GoRoute(
    path: '/ptosInspeccionRevision',
    builder: (context, state) => const RevisionPtosInspeccionRevision(),
  ),
  GoRoute(
    path: '/editOrden',
    builder: (context, state) => const EditOrden(),
  ),
  GoRoute(
    path: '/ptosInspeccionCliente',
    builder: (context, state) => const PtosInspeccionClientes(),
  ),
  GoRoute(
    path: '/establecerPerfiles',
    builder: (context, state) => const EstablecerPerfiles(),
  ),
  GoRoute(
    path: '/lotes',
    builder: (context, state) => const LotesPage(),
  ),
  GoRoute(
    path: '/detallesMaterial',
    builder: (context, state) => const DetallesMateriales(),
  ),
  GoRoute(
    path: '/habilitacionesMaterial',
    builder: (context, state) => const HabilitacionesMaterial(),
  ),
  GoRoute(
    path: '/metodosAplicacion',
    builder: (context, state) => const MetodosAplicacionPage(),
  ),
  GoRoute(
    path: '/editMetodosAplicacion',
    builder: (context, state) => const EditMetodosAplicacionPage(),
  ),
  GoRoute(
    path: '/controles',
    builder: (context, state) => const ControlesPage(),
  ),
  GoRoute(
    path: '/editControles',
    builder: (context, state) => const EditControlesPage(),
  ),
  GoRoute(
    path: '/marcas',
    builder: (context, state) => const MarcasPage(),
  ),
  GoRoute(
    path: '/editMarcas',
    builder: (context, state) => const EditMarcasPage(),
  ),
  GoRoute(
    path: '/editClientes',
    builder: (context, state) => const EditClientesPage(),
  ),
]);
