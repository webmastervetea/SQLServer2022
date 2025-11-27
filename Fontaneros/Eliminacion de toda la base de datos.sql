-- ************************************************************
-- PASO 1: Establecer el Contexto de la Base de Datos
-- ************************************************************
-- Nota: Si el script se ejecuta desde un contexto diferente,
-- debe asegurarse de que la base de datos 'Fontaneria' existe.
USE Fontaneria;
GO

PRINT 'Iniciando eliminación de objetos de la base de datos Fontaneria...';
GO

-- ************************************************************
-- PASO 2: ELIMINAR PROCEDIMIENTOS ALMACENADOS (SPs)
-- ************************************************************

IF OBJECT_ID('dbo.SP_GenerarFacturaDesdeCita', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_GenerarFacturaDesdeCita;
GO

IF OBJECT_ID('dbo.SP_FinalizarServicioYGenerarParte', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_FinalizarServicioYGenerarParte;
GO

IF OBJECT_ID('dbo.SP_ProcesarRecepcionCompra', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_ProcesarRecepcionCompra;
GO

IF OBJECT_ID('dbo.SP_AgendarNuevaCita', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_AgendarNuevaCita;
GO

PRINT 'Procedimientos Almacenados eliminados.';
GO

-- ************************************************************
-- PASO 3: ELIMINAR FUNCIONES (UDFs)
-- ************************************************************

IF OBJECT_ID('dbo.FN_CalcularDisponibilidadDiaria', 'FN') IS NOT NULL
    DROP FUNCTION dbo.FN_CalcularDisponibilidadDiaria;
GO

IF OBJECT_ID('dbo.FN_ObtenerTotalArticulosFactura', 'TF') IS NOT NULL
    DROP FUNCTION dbo.FN_ObtenerTotalArticulosFactura;
GO

PRINT 'Funciones definidas por el usuario eliminadas.';
GO

-- ************************************************************
-- PASO 4: ELIMINAR VISTAS
-- ************************************************************

IF OBJECT_ID('dbo.VW_Valoracion_Inventario', 'V') IS NOT NULL DROP VIEW dbo.VW_Valoracion_Inventario;
IF OBJECT_ID('dbo.VW_Reporte_Ventas_Por_Servicio', 'V') IS NOT NULL DROP VIEW dbo.VW_Reporte_Ventas_Por_Servicio;
IF OBJECT_ID('dbo.VW_Disponibilidad_Laboral', 'V') IS NOT NULL DROP VIEW dbo.VW_Disponibilidad_Laboral;
IF OBJECT_ID('dbo.VW_Historial_Compras_Costo', 'V') IS NOT NULL DROP VIEW dbo.VW_Historial_Compras_Costo;
IF OBJECT_ID('dbo.VW_Detalle_Factura_Completo', 'V') IS NOT NULL DROP VIEW dbo.VW_Detalle_Factura_Completo;
IF OBJECT_ID('dbo.VW_Partes_Trabajo_Auditoria', 'V') IS NOT NULL DROP VIEW dbo.VW_Partes_Trabajo_Auditoria;
IF OBJECT_ID('dbo.VW_Inventario_Bajo_Minimo', 'V') IS NOT NULL DROP VIEW dbo.VW_Inventario_Bajo_Minimo;
IF OBJECT_ID('dbo.VW_Facturacion_Cobros_Pendientes', 'V') IS NOT NULL DROP VIEW dbo.VW_Facturacion_Cobros_Pendientes;
IF OBJECT_ID('dbo.VW_Agenda_Detallada', 'V') IS NOT NULL DROP VIEW dbo.VW_Agenda_Detallada;
GO

PRINT 'Vistas eliminadas.';
GO

-- ************************************************************
-- PASO 5: ELIMINAR SECUENCIAS Y TIPOS DEFINIDOS POR EL USUARIO
-- ************************************************************

IF OBJECT_ID('dbo.SQ_NumeroFactura', 'SO') IS NOT NULL
    DROP SEQUENCE dbo.SQ_NumeroFactura;
GO

IF TYPE_ID('dbo.TipoMaterialConsumido') IS NOT NULL
    DROP TYPE dbo.TipoMaterialConsumido;
GO

PRINT 'Secuencias y Tipos de Tabla eliminados.';
GO

-- ************************************************************
-- PASO 6: ELIMINAR TABLAS (DE MAYOR A MENOR DEPENDENCIA)
-- ************************************************************

-- Tablas de unión y dependientes directas
IF OBJECT_ID('dbo.MaterialParteTrabajo', 'U') IS NOT NULL DROP TABLE dbo.MaterialParteTrabajo;
IF OBJECT_ID('dbo.PartesDeTrabajo', 'U') IS NOT NULL DROP TABLE dbo.PartesDeTrabajo;
IF OBJECT_ID('dbo.Ausencias', 'U') IS NOT NULL DROP TABLE dbo.Ausencias;
IF OBJECT_ID('dbo.HorariosLaborales', 'U') IS NOT NULL DROP TABLE dbo.HorariosLaborales;
IF OBJECT_ID('dbo.LineasFactura', 'U') IS NOT NULL DROP TABLE dbo.LineasFactura;
IF OBJECT_ID('dbo.DetallesCompra', 'U') IS NOT NULL DROP TABLE dbo.DetallesCompra;
GO

-- Tablas intermedias
IF OBJECT_ID('dbo.Citas', 'U') IS NOT NULL DROP TABLE dbo.Citas;
IF OBJECT_ID('dbo.Facturas', 'U') IS NOT NULL DROP TABLE dbo.Facturas;
IF OBJECT_ID('dbo.Compras', 'U') IS NOT NULL DROP TABLE dbo.Compras;
IF OBJECT_ID('dbo.Articulos', 'U') IS NOT NULL DROP TABLE dbo.Articulos;
GO

-- Tablas base
IF OBJECT_ID('dbo.ZonasOperacion', 'U') IS NOT NULL DROP TABLE dbo.ZonasOperacion;
IF OBJECT_ID('dbo.Servicios', 'U') IS NOT NULL DROP TABLE dbo.Servicios;
IF OBJECT_ID('dbo.Proveedores', 'U') IS NOT NULL DROP TABLE dbo.Proveedores;
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL DROP TABLE dbo.Clientes;
IF OBJECT_ID('dbo.Empleados', 'U') IS NOT NULL DROP TABLE dbo.Empleados;
GO

PRINT 'Tablas eliminadas.';
GO

-- ************************************************************
-- PASO 7: ELIMINAR ROLES DE SEGURIDAD (Opcional)
-- ************************************************************

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_fontanero' AND type = 'R')
    DROP ROLE db_fontanero;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_contable_facturacion' AND type = 'R')
    DROP ROLE db_contable_facturacion;
GO

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'db_administracion_agenda' AND type = 'R')
    DROP ROLE db_administracion_agenda;
GO

PRINT 'Roles de seguridad eliminados.';
GO

-- ************************************************************
-- PASO 8: ELIMINAR LA BASE DE DATOS (Opcional, pero para limpieza total)
-- ************************************************************

USE master;
GO

IF DB_ID('Fontanerias') IS NOT NULL
BEGIN
    ALTER DATABASE Fontanerias SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- Desconecta a todos los usuarios
    DROP DATABASE Fontanerias;
    PRINT 'Base de datos Fontanerias eliminada.';
END
GO