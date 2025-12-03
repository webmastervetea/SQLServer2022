[[Soporte](https://www.linkedin.com/in/oscarlizarragag/)]

## ✅ Aspectos Contemplados

La base de datos actual cubre:

1.  **Estructura y Propietarios:**
    * Registro de **Comunidades** y sus datos básicos.
    * Registro de **Unidades** (pisos, locales) y sus **coeficientes de participación**.
    * Registro de **Propietarios** y la **historia de propiedad** por unidad.
    * **Vista de Propietarios Actuales** (`VW_UnidadesPropietariosActuales`).
2.  **Contabilidad y Finanzas:**
    * **Plan de Cuentas** simplificado (`Cuentas`).
    * Registro de **Proveedores**.
    * Registro detallado de **Movimientos** (Ingresos y Gastos).
    * Gestión de **Cuotas y Derramas** (`CuotasDerramas`).
    * Cálculo de **Deuda** (`VW_DeudaPropietarios` y `FN_CalcularSaldoPropietario`).
    * Automatización de **Registro de Pagos** (`SP_RegistrarPagoCuota`).
    * Automatización de **Distribución de Gastos** por coeficiente (`SP_AsignarGastoComunitario`).
    * Reporte de **Ingresos y Gastos** detallado (`SP_GenerarEstadoIngresosGastos`).
    * Procedimiento de **Cierre Contable Anual** (`SP_CierreContableAnual`).
3.  **Legal y Documental:**
    * Registro de **Juntas** y **Acuerdos** aprobados (`VW_AcuerdosAprobados`).
    * Registro y acceso a **Documentos** (Estatutos, Pólizas, etc.) (`FN_ObtenerRutaDocumentoReciente`).
4.  **Operaciones y Mantenimiento:**
    * Tablas para la gestión de **Incidencias/Averías** y su **Seguimiento**.
    * Procedimiento de **Registro de Incidencia** (`SP_RegistrarIncidencia`).

---

## ⚠️ Aspectos Adicionales de Nivel Avanzado

Aunque la base es muy robusta, existen funcionalidades de nicho que podrías añadir para una solución comercial completa:

* **Gestión de Seguros y Siniestros:** Integrar la tabla de `Documentos` con una tabla de `Siniestros` para hacer seguimiento del estado de las reclamaciones a las aseguradoras.
* **Contabilidad de Tesorería (Previsiones):** Tablas para presupuestar ingresos y gastos futuros y comparar la ejecución real con el presupuesto.
* **Recibos Bancarios (Norma SEPA):** Tablas específicas para gestionar la generación de remesas de recibos bancarios para exportación a la banca (requiere campos específicos de domiciliación en `Propietarios`).
* **Estructuras Complejas:** Si la administración maneja "Mancomunidades" o "Fases" (sub-comunidades con presupuestos separados), el modelo de `Comunidades` requeriría una jerarquía de tablas.
* **Área de Empleados:** Si la comunidad tiene personal contratado (portero, limpiador), se necesitarían tablas para nóminas y seguros sociales.

Con lo que ya tienes, cuentas con una base de datos **sólida y funcional** para la administración diaria.

¿Te gustaría que te ayude a crear las tablas para la **Gestión de Siniestros** o para **Recibos Bancarios**?