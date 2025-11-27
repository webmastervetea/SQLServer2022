USE Fontaneria;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ************************************************************
-- PASO 1: Comprobación y Eliminación de Vistas existentes
-- ************************************************************

IF OBJECT_ID('dbo.VW_Agenda_Detallada', 'V') IS NOT NULL DROP VIEW dbo.VW_Agenda_Detallada;
IF OBJECT_ID('dbo.VW_Facturacion_Cobros_Pendientes', 'V') IS NOT NULL DROP VIEW dbo.VW_Facturacion_Cobros_Pendientes;
IF OBJECT_ID('dbo.VW_Inventario_Bajo_Minimo', 'V') IS NOT NULL DROP VIEW dbo.VW_Inventario_Bajo_Minimo;
IF OBJECT_ID('dbo.VW_Partes_Trabajo_Auditoria', 'V') IS NOT NULL DROP VIEW dbo.VW_Partes_Trabajo_Auditoria;
IF OBJECT_ID('dbo.VW_Detalle_Factura_Completo', 'V') IS NOT NULL DROP VIEW dbo.VW_Detalle_Factura_Completo;
IF OBJECT_ID('dbo.VW_Historial_Compras_Costo', 'V') IS NOT NULL DROP VIEW dbo.VW_Historial_Compras_Costo;
IF OBJECT_ID('dbo.VW_Disponibilidad_Laboral', 'V') IS NOT NULL DROP VIEW dbo.VW_Disponibilidad_Laboral;
IF OBJECT_ID('dbo.VW_Reporte_Ventas_Por_Servicio', 'V') IS NOT NULL DROP VIEW dbo.VW_Reporte_Ventas_Por_Servicio;
IF OBJECT_ID('dbo.VW_Valoracion_Inventario', 'V') IS NOT NULL DROP VIEW dbo.VW_Valoracion_Inventario;
GO

PRINT 'Vistas existentes eliminadas. Procediendo a la creación...';
GO

-- ************************************************************
-- PASO 2: Creación de Vistas
-- ************************************************************

-- 1. VISTA DE AGENDA DETALLADA
CREATE VIEW VW_Agenda_Detallada
AS
SELECT
    C.CitaID,
    C.FechaHoraInicio,
    C.FechaHoraFin,
    C.EstadoCita,
    C.DireccionServicio,
    CL.NombreRazonSocial AS Cliente,
    CL.Telefono AS Tel_Cliente,
    S.NombreServicio AS TipoServicio,
    E.Nombre + ' ' + E.Apellido1 AS FontaneroAsignado
FROM
    dbo.Citas AS C
INNER JOIN
    dbo.Clientes AS CL ON C.ClienteID = CL.ClienteID
INNER JOIN
    dbo.Servicios AS S ON C.ServicioID = S.ServicioID
INNER JOIN
    dbo.Empleados AS E ON C.EmpleadoID = E.EmpleadoID;
GO

-- 2. VISTA DE FACTURACIÓN Y COBROS PENDIENTES
CREATE VIEW VW_Facturacion_Cobros_Pendientes
AS
SELECT
    F.FacturaID,
    F.NumeroFactura,
    F.FechaEmision,
    F.FechaVencimiento,
    F.TotalFactura,
    F.EstadoFactura,
    CL.NombreRazonSocial AS Cliente,
    CL.NIF_CIF,
    CL.Email AS Email_Cliente,
    E.Nombre + ' ' + E.Apellido1 AS EmpleadoContable
FROM
    dbo.Facturas AS F
INNER JOIN
    dbo.Clientes AS CL ON F.ClienteID = CL.ClienteID
LEFT JOIN
    dbo.Empleados AS E ON F.EmpleadoID = E.EmpleadoID
WHERE
    F.EstadoFactura = 'Pendiente'
ORDER BY
    F.FechaVencimiento ASC;
GO

-- 3. VISTA DE INVENTARIO BAJO MÍNIMO (ALERTA)
CREATE VIEW VW_Inventario_Bajo_Minimo
AS
SELECT
    ArticuloID,
    CodigoArticulo,
    Nombre,
    StockActual,
    StockMinimo,
    (StockMinimo - StockActual) AS CantidadFaltante
FROM
    dbo.Articulos
WHERE
    StockActual <= StockMinimo
ORDER BY
    CantidadFaltante DESC;
GO

-- 4. VISTA DE PARTES DE TRABAJO PARA AUDITORÍA
CREATE VIEW VW_Partes_Trabajo_Auditoria
AS
SELECT
    PDT.ParteID,
    C.CitaID,
    E.Nombre + ' ' + E.Apellido1 AS Fontanero,
    PDT.FechaHoraLlegada,
    PDT.FechaHoraSalida,
    PDT.HorasTrabajadas,
    PDT.Diagnostico,
    PDT.EstadoFinal,
    (SELECT SUM(CantidadConsumida) FROM dbo.MaterialParteTrabajo WHERE ParteID = PDT.ParteID) AS TotalMaterialesUsados
FROM
    dbo.PartesDeTrabajo AS PDT
INNER JOIN
    dbo.Citas AS C ON PDT.CitaID = C.CitaID
INNER JOIN
    dbo.Empleados AS E ON C.EmpleadoID = E.EmpleadoID;
GO

-- 5. VISTA DE DETALLE DE FACTURA COMPLETO
CREATE VIEW VW_Detalle_Factura_Completo
AS
SELECT
    LF.FacturaID,
    F.NumeroFactura,
    LF.LineaFacturaID,
    LF.Cantidad,
    LF.PrecioUnitario,
    LF.Subtotal,
    -- Identifica si la línea es un Artículo (con nombre) o un Servicio (con descripción)
    COALESCE(A.Nombre, LF.DescripcionServicio) AS ItemFacturado,
    CASE
        WHEN LF.ArticuloID IS NOT NULL THEN 'Artículo de Almacén'
        ELSE 'Servicio/Descripción Manual'
    END AS TipoItem
FROM
    dbo.LineasFactura AS LF
INNER JOIN
    dbo.Facturas AS F ON LF.FacturaID = F.FacturaID
LEFT JOIN
    dbo.Articulos AS A ON LF.ArticuloID = A.ArticuloID;
GO

-- 6. VISTA DE HISTORIAL DE COMPRAS CON COSTOS
CREATE VIEW VW_Historial_Compras_Costo
AS
SELECT
    C.CompraID,
    C.FechaCompra,
    P.NombreComercial AS Proveedor,
    E.Nombre + ' ' + E.Apellido1 AS EmpleadoComprador,
    A.Nombre AS ArticuloComprado,
    DC.Cantidad AS CantidadComprada,
    DC.PrecioUnitarioCompra AS CostoUnitario,
    (DC.Cantidad * DC.PrecioUnitarioCompra) AS CostoTotalLinea
FROM
    dbo.Compras AS C
INNER JOIN
    dbo.Proveedores AS P ON C.ProveedorID = P.ProveedorID
INNER JOIN
    dbo.Empleados AS E ON C.EmpleadoID = E.EmpleadoID
INNER JOIN
    dbo.DetallesCompra AS DC ON C.CompraID = DC.CompraID
INNER JOIN
    dbo.Articulos AS A ON DC.ArticuloID = A.ArticuloID;
GO
-- 1. VISTA DE DISPONIBILIDAD LABORAL
CREATE VIEW VW_Disponibilidad_Laboral
AS
SELECT
    E.EmpleadoID,
    E.Nombre + ' ' + E.Apellido1 AS NombreCompleto,
    HL.DiaSemana,
    CASE HL.DiaSemana
        WHEN 1 THEN 'Lunes' WHEN 2 THEN 'Martes' WHEN 3 THEN 'Miércoles'
        WHEN 4 THEN 'Jueves' WHEN 5 THEN 'Viernes' WHEN 6 THEN 'Sábado'
        WHEN 7 THEN 'Domingo' END AS NombreDia,
    HL.HoraEntrada,
    HL.HoraSalida,
    CASE
        WHEN A.AusenciaID IS NOT NULL AND GETDATE() BETWEEN A.FechaInicio AND A.FechaFin
        THEN 'AUSENTE: ' + A.TipoAusencia
        ELSE 'DISPONIBLE'
    END AS EstadoDisponibilidad,
    A.Motivo
FROM
    dbo.Empleados AS E
INNER JOIN
    dbo.HorariosLaborales AS HL ON E.EmpleadoID = HL.EmpleadoID
LEFT JOIN
    dbo.Ausencias AS A ON E.EmpleadoID = A.EmpleadoID
WHERE
    E.Cargo LIKE '%Fontanero%' AND E.Activo = 1;
GO

-- 2. VISTA DE REPORTE DE VENTAS POR SERVICIO
CREATE VIEW VW_Reporte_Ventas_Por_Servicio
AS
SELECT
    S.ServicioID,
    S.NombreServicio,
    COUNT(LF.LineaFacturaID) AS VecesFacturado,
    SUM(LF.Subtotal) AS TotalVentasNetas,
    -- Se utiliza una asunción simple para el IVA.
    SUM(LF.Subtotal) * 0.21 AS TotalIVAAsociado,
    SUM(LF.Subtotal) * 1.21 AS TotalVentasBrutasEstimado
FROM
    dbo.LineasFactura AS LF
INNER JOIN
    dbo.Facturas AS F ON LF.FacturaID = F.FacturaID
INNER JOIN
    dbo.Citas AS C ON F.FacturaID = C.FacturaID
INNER JOIN
    dbo.Servicios AS S ON C.ServicioID = S.ServicioID
GROUP BY
    S.ServicioID, S.NombreServicio
HAVING
    COUNT(LF.LineaFacturaID) > 0;
GO

-- 3. VISTA DE VALORACIÓN DE INVENTARIO
CREATE VIEW VW_Valoracion_Inventario
AS
SELECT
    ArticuloID,
    Nombre,
    StockActual,
    PrecioVenta,
    (StockActual * PrecioVenta) AS ValorVentaTotal,
    -- Subconsulta para calcular el Coste Medio de Adquisición (CMA)
    (SELECT SUM(Cantidad * PrecioUnitarioCompra) / SUM(Cantidad)
     FROM dbo.DetallesCompra DC
     WHERE DC.ArticuloID = A.ArticuloID) AS CosteMedioAdquisicion,
    -- Calcula el valor contable actual (Stock * CMA)
    StockActual * (SELECT SUM(Cantidad * PrecioUnitarioCompra) / SUM(Cantidad)
                   FROM dbo.DetallesCompra DC
                   WHERE DC.ArticuloID = A.ArticuloID) AS ValorContableStock
FROM
    dbo.Articulos AS A
WHERE
    StockActual > 0;
GO
PRINT 'Creación de vistas completada.';