## 📑 Documentación General de la Base de Datos [[Soporte](https://www.linkedin.com/in/oscarlizarragag/)]

| Característica | Detalle |
| :--- | :--- |
| **Plataforma** | SQL Server 2022 |
| **Objetivo** | Administración integral de comunidades, contabilidad, gestión documental y operativa (incidencias/siniestros). |
| **Esquemas** | `Admin`, `Contabilidad`, `Operaciones` (para segregación de permisos y organización). |
| **Integridad** | Controlada por Claves Primarias (`PK`), Claves Foráneas (`FK`), Restricciones `UNIQUE` y *Triggers*. |

---

## 🛠️ I. Estructura de Tablas por Esquema

Se han definido **17 tablas** principales distribuidas en tres esquemas para una mejor seguridad y segregación de datos.

### A. Esquema `Admin` (Estructura y Propietarios)

| Tabla | Descripción | Campos Clave | Campos Importantes |
| :--- | :--- | :--- | :--- |
| `Comunidades` | Datos de la comunidad (edificio). | `ComunidadID (PK)` | `Nombre`, `CIF`, `CuentaBancaria`. |
| `Propietarios` | Datos de los dueños. | `PropietarioID (PK)` | `NIF_NIE (UNIQUE)`, `NombreCompleto`, **`IBAN`, `BIC`**. |
| `Unidades` | Elementos privativos (pisos, locales). | `UnidadID (PK)` | `ComunidadID (FK)`, `CoeficienteParticipacion`. |
| `PropiedadUnidad` | Histórico de quién es dueño de qué unidad. | `PropiedadUnidadID (PK)` | `UnidadID (FK)`, `PropietarioID (FK)`, `FechaFinPropiedad`. |

### B. Esquema `Contabilidad` (Finanzas y Proveedores)

| Tabla | Descripción | Campos Clave | Campos Importantes |
| :--- | :--- | :--- | :--- |
| `Cuentas` | Plan de Cuentas (Ingreso/Gasto/Banco). | `CuentaID (PK)` | `ComunidadID (FK)`, `CodigoCuenta`. |
| `Proveedores` | Empresas que prestan servicios. | `ProveedorID (PK)` | `NIF_CIF (UNIQUE)`, `RazonSocial`. |
| `Movimientos` | Registro de facturas, pagos, cobros. | `MovimientoID (PK)` | `Monto`, `TipoMovimiento`, `CuentaContableID (FK)`. |
| `CuotasDerramas` | Deudas/Pagos pendientes por unidad. | `CuotaDerramaID (PK)` | `UnidadID (FK)`, `Mes`, `MontoCuota`, `EstadoPago`. |
| `RemesasSEPA` | Cabecera para agrupar recibos domiciliados. | `RemesaID (PK)` | `FechaCargoPrevista`, `MontoTotal`. |
| `DetalleRemesa` | Enlace entre remesa y cuotas. | `DetalleRemesaID (PK)` | `RemesaID (FK)`, `CuotaDerramaID (FK, UNIQUE)`. |

### C. Esquema `Operaciones` (Juntas, Documentos y Mantenimiento)

| Tabla | Descripción | Campos Clave | Campos Importantes |
| :--- | :--- | :--- | :--- |
| `Juntas` | Registro de convocatorias y actas. | `JuntaID (PK)` | `FechaJunta`, `TipoJunta`, `ActaRutaArchivo`. |
| `Acuerdos` | Acuerdos tomados en cada junta. | `AcuerdoID (PK)` | `JuntaID (FK)`, `AcuerdoAprobado`. |
| `Documentos` | Archivos legales (pólizas, estatutos, contratos). | `DocumentoID (PK)` | `TipoDocumento`, `RutaArchivo`. |
| `Incidencias` | Averías o problemas de mantenimiento. | `IncidenciaID (PK)` | `FechaReporte`, `Estado`, `Prioridad`. |
| `SeguimientoIncidencias` | Trazabilidad de la resolución de la incidencia. | `SeguimientoID (PK)` | `IncidenciaID (FK)`, `Detalle`. |
| `Siniestros` | Gestión de partes de seguro. | `SiniestroID (PK)` | `NumeroExpedienteAseguradora (UNIQUE)`, `Estado`, `MontoIndemnizacion`. |
| `SeguimientoSiniestros` | Trazabilidad del proceso de seguro. | `SeguimientoSiniestroID (PK)` | `SiniestroID (FK)`, `Detalle`. |

---

## 🧮 II. Vistas, Funciones y Secuencias

### A. Vistas (Informes Simplificados)

| Nombre de la Vista | Esquema | Propósito |
| :--- | :--- | :--- |
| `VW_UnidadesPropietariosActuales` | `dbo` | Muestra el dueño actual de cada unidad (donde `FechaFinPropiedad IS NULL`). |
| `VW_SaldoContableMensual` | `dbo` | Muestra un resumen mensual de ingresos vs. gastos por comunidad. |
| `VW_DeudaPropietarios` | `dbo` | Identifica a los morosos sumando todas las cuotas en estado 'Pendiente'. |
| `VW_GastosPorProveedor` | `dbo` | Detalle de los gastos realizados a cada proveedor. |
| `VW_AcuerdosAprobados` | `dbo` | Lista de todos los acuerdos que han sido aprobados en las juntas. |

### B. Funciones Escalares (Cálculo Rápido)

| Nombre de la Función | Tipo | Propósito |
| :--- | :--- | :--- |
| `FN_CalcularSaldoPropietario` | Escalar | Devuelve la deuda neta total de una unidad específica. |
| `FN_ObtenerRutaDocumentoReciente` | Escalar | Devuelve la ruta del archivo más reciente para un tipo de documento dado. |

### C. Secuencias (Numeración Oficial)

| Nombre de la Secuencia | Propósito |
| :--- | :--- |
| `Seq_NumeroActa` | Genera números secuenciales para las Actas de Junta. |
| `Seq_NumeroFacturaComunidad` | Genera números secuenciales para las facturas emitidas por la comunidad. |

---

## 💻 III. Procedimientos Almacenados (*Stored Procedures*)

| Nombre del Procedimiento | Área | Funcionalidad |
| :--- | :--- | :--- |
| `SP_RegistrarPagoCuota` | Contabilidad | Actualiza el `EstadoPago` de una cuota a 'Pagado' y registra la fecha. |
| `SP_AsignarGastoComunitario` | Contabilidad | Reparte un gasto total entre todas las unidades según su **`CoeficienteParticipacion`**. |
| `SP_CierreContableAnual` | Contabilidad | Calcula el resultado final (saldo) del ejercicio y lo registra como movimiento de cierre. |
| `SP_GenerarEstadoIngresosGastos` | Contabilidad | Genera un reporte detallado de ingresos y gastos entre dos fechas, agrupado por cuenta contable. |
| `SP_RegistrarIncidencia` | Operaciones | Crea un nuevo registro en `Incidencias` y su primer registro en `SeguimientoIncidencias`. |
| `SP_ActualizarEstadoSiniestro` | Operaciones | Cambia el `Estado` de un siniestro y registra la acción en `SeguimientoSiniestros`. |
| `SP_CrearRemesaCuotas` | Contabilidad | Crea un registro en `RemesasSEPA` y `DetalleRemesa` para las cuotas domiciliadas pendientes de un mes. |

---

## ⚙️ IV. Triggers y Rendimiento

### A. Triggers (Reglas de Negocio Automatizadas)

| Nombre del Trigger | Tabla Afectada | Propósito |
| :--- | :--- | :--- |
| `TR_ControlCoeficienteParticipacion` | `Unidades` | **Impide** que la suma de todos los coeficientes de participación en una comunidad sea diferente al 100.00%. |
| `TR_ActualizarEstadoCuotaPorDetalleRemesa` | `DetalleRemesa` | Actualiza el `EstadoPago` en `CuotasDerramas` a 'Pagado' automáticamente si el recibo de la remesa pasa a estado 'Cobrado'. |

### B. Índices No Agrupados (Rendimiento)

Se crearon índices clave para optimizar la velocidad de las consultas más comunes:

* `IX_Movimientos_ComunidadFecha`
* `IX_CuotasDerramas_EstadoUnidad`
* `IX_Propietarios_Nombre`
* `IX_Unidades_Comunidad`

Esta documentación resume todas las partes de la solución. Si en el futuro necesitas ampliar o modificar alguna funcionalidad, esta estructura te servirá como mapa de referencia. 