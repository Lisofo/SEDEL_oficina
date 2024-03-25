class EstadoCliente {
  late String codEstado;
  late String descripcion;

  EstadoCliente({required this.codEstado, required this.descripcion});

  EstadoCliente.empty() {
    codEstado = '';
    descripcion = '';
  }
}
