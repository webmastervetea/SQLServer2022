USE Fontaneria;
GO
-- 1. Crear el Rol
CREATE ROLE db_fontanero;
GO

-- 2. Asignar Permisos sobre Tablas y Vistas
GRANT SELECT ON dbo.Citas TO db_fontanero;
GRANT SELECT ON dbo.Empleados TO db_fontanero;
GRANT SELECT ON dbo.Clientes TO db_fontanero;
GRANT SELECT ON dbo.Articulos TO db_fontanero;
GRANT SELECT ON dbo.PartesDeTrabajo TO db_fontanero;
GRANT SELECT ON dbo.VW_Agenda_Detallada TO db_fontanero;
GRANT SELECT ON dbo.VW_Disponibilidad_Laboral TO db_fontanero;

-- 3. Asignar Permisos sobre Procedimientos
GRANT EXECUTE ON dbo.SP_FinalizarServicioYGenerarParte TO db_fontanero;

-- 4. Permisos de modificación (requiere implementación de seguridad a nivel de fila RLS para limitar a su propio ID,
-- o se confía en la lógica del procedimiento almacenado). Para simplificar, confiamos en el SP:
-- GRANT UPDATE ON dbo.Citas TO db_fontanero;
GO

-- 1. Crear el Rol
CREATE ROLE db_contable_facturacion;
GO

-- 2. Asignar Permisos sobre Tablas y Vistas
GRANT SELECT, INSERT, UPDATE ON dbo.Facturas TO db_contable_facturacion;
GRANT SELECT, INSERT, UPDATE ON dbo.LineasFactura TO db_contable_facturacion;
GRANT SELECT, INSERT ON dbo.Compras TO db_contable_facturacion;
GRANT SELECT, INSERT ON dbo.DetallesCompra TO db_contable_facturacion;

-- Solo SELECT para artículos y servicios (la modificación se hace vía SP para consistencia)
GRANT SELECT ON dbo.Articulos TO db_contable_facturacion;
GRANT SELECT ON dbo.Servicios TO db_contable_facturacion;
GRANT SELECT ON dbo.Clientes TO db_contable_facturacion;
GRANT SELECT ON dbo.Proveedores TO db_contable_facturacion;

GRANT SELECT ON dbo.VW_Facturacion_Cobros_Pendientes TO db_contable_facturacion;
GRANT SELECT ON dbo.VW_Inventario_Bajo_Minimo TO db_contable_facturacion;
GRANT SELECT ON dbo.VW_Historial_Compras_Costo TO db_contable_facturacion;
GRANT SELECT ON dbo.VW_Valoracion_Inventario TO db_contable_facturacion;

-- 3. Asignar Permisos sobre Procedimientos
GRANT EXECUTE ON dbo.SP_GenerarFacturaDesdeCita TO db_contable_facturacion;
GRANT EXECUTE ON dbo.SP_ProcesarRecepcionCompra TO db_contable_facturacion;
GO

-- 1. Crear el Rol
CREATE ROLE db_administracion_agenda;
GO

-- 2. Asignar Permisos sobre Tablas y Vistas
GRANT SELECT, INSERT, UPDATE ON dbo.Citas TO db_administracion_agenda;
GRANT SELECT, INSERT ON dbo.Clientes TO db_administracion_agenda;

-- Administración de personal/horarios
GRANT SELECT, INSERT, UPDATE ON dbo.Empleados TO db_administracion_agenda;
GRANT SELECT, INSERT, UPDATE ON dbo.HorariosLaborales TO db_administracion_agenda;
GRANT SELECT, INSERT, UPDATE ON dbo.Ausencias TO db_administracion_agenda;

GRANT SELECT ON dbo.VW_Agenda_Detallada TO db_administracion_agenda;
GRANT SELECT ON dbo.VW_Disponibilidad_Laboral TO db_administracion_agenda;

-- 3. Asignar Permisos sobre Procedimientos
GRANT EXECUTE ON dbo.SP_AgendarNuevaCita TO db_administracion_agenda;
GO



