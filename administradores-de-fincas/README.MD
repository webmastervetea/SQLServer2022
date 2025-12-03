## Administración de fincas. Base de datos en sql server 2022
### [[Soporte](https://www.linkedin.com/in/oscarlizarragag/)]


#### Como ejecutar los archivso
Debes de ejecutar en el SQL Management Studio 22 estos archivos en el mismo orden que estan marcados, en caso contrario puede instalarse mal. Si te equivocas lo recomendable es volver a empezar para asegurarse

Abre cada archivo dentro del SQL Management Studio 22 desde "new query" y haz click en ejecutar

* [[0](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/0-base-de-datos.sql)] Base de datos (Crea una base de datos llamada "administracion-fincas", puedes cambiar el nombre si lo deseas, modificando el archivo.)
* [[1](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/1-tablas-de-comunidades-y-estructura.sql)] Tablas de Comunidades y Estructura
* [[2](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/2-tablas-de-contabilidad-y-movimientos.sql)] Tablas de Contabilidad y Movimientos
* [[3](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/3-tablas-reuniones-y-documentacion.sql)] Tablas Reuniones y Documentacion
* [[4](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/4-vista-de-unidades-y-propietarios-activos.sql)] Vista de unidades y propietarios activos
* [[5](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/5-vista-del-estado-de-cuentas-por-comunidad-y-mes.sql)] Vista del Estado de Cuentas por Comunidad y Mes
* [[6](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/6-vista-de-deudas-de-propietarios.sql)] Vista de Deudas de Propietarios
* [[7](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/7-vista-de-movimientos-de-gasto-detallado-por-proveedor.sql)] Vista de Movimientos de Gasto Detallado por Proveedor
* [[8](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/8-vista-de-acuerdos-aprobados-recientes.sql)] Vista de Acuerdos Aprobados Recientes
* [[9](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/9-procedimiento-almacenado-sp-registrarpagocuota.sql)] Procedimiento Almacenado SP-RegistrarPagoCuota
* [[10](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/10-ejecutar-el-procedimiento-para-registrar-el-pago.sql)] Ejecutar el procedimiento para registrar el pago
* [[11](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/11-procedimiento-almacenado-para-asignacion-de-gastos-proporcionales.sql)] Procedimiento Almacenado para Asignación de Gastos Proporcionales
* [[12](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/12-funcion-para-obtener-la-ruta-del-documento-mas-reciente.sql)] Función para Obtener la Ruta del Documento más Reciente
* [[13](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/13-funcion-para-calcular-el-saldo-pendiente-del-propietario.sql)] Función para Calcular el Saldo Pendiente del Propietario
* [[14](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/14-procedimiento-almacenado-para-registrar-el-cierre-contable-anual.sql)] Procedimiento Almacenado para Registrar el Cierre Contable Anual
* [[15](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/15-insercion-de-datos-en-la-base-de-datos.sql)] Insercion de datos en la base de datos
* [[16](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/16-procedimiento-para-reporte-contable-detallado.sql)] Procedimiento para Reporte Contable Detallado
* [[17](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/17-gestion-de-incidencias-y-averias.sql)] Gestión de Incidencias y Averías
* [[18](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/18-procedimiento-para-registrar-incidencia.sql)] Procedimiento para Registrar Incidencia
* [[19](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/19-tablas-para-gestion-de-siniestros-seguros.sql)] Tablas para Gestión de Siniestros (Seguros)
* [[20](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/20-tablas-para-gestion-de-remesas-bancarias-sepa.sql)] Tablas para Gestión de Remesas Bancarias (SEPA)
* [[21](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/21-detalleremesa-relacion-entre-remesa-y-cuotas-a-cobrar.sql)] DetalleRemesa (Relación entre Remesa y Cuotas a Cobrar)
* [[22](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/22-trigger-para-mantener-el-coeficiente-de-participacion.sql)] Trigger para Mantener el Coeficiente de Participación
* [[23](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/23-trigger-para-actualizar-el-estado-de-morosidad-del-propietario.sql)] Trigger para Actualizar el Estado de Morosidad del Propietario
* [[24](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/24-secuencia-para-actas-de-junta.sql)] Secuencia para Actas de Junta
* [[25](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/25-secuencia-para-facturas-emitidas-si-la-comunidad-factura-algo.sql)] Secuencia para Facturas Emitidas (si la comunidad factura algo)
* [[26](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/26-indices-performance.sql)] Índices (Performance)
* [[27](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/27-creacion-de-esquemas-organizacion-y-seguridad.sql)] Creación de Esquemas (Organización y Seguridad)
* [[28](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/28-siniestros-y-seguimiento-esquema-operaciones.sql)] Siniestros y Seguimiento (Esquema Operaciones)
* [[29](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/29-secuencias-de-numeracion.sql)] Secuencias de Numeración
* [[30](https://github.com/webmastervetea/SQLServer2022/blob/main/administradores-de-fincas/30-indices-clave-para-rendimiento.sql)]Índices Clave para Rendimiento
