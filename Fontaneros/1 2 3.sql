USE Fontaneria;
GO

-- ************************************************************
-- PASO 1: Comprobación y Eliminación de Tablas (Por orden de FK)
-- ************************************************************
-- Se eliminan las tablas que son referenciadas primero, y las que tienen FK después.

IF OBJECT_ID('dbo.MaterialParteTrabajo', 'U') IS NOT NULL DROP TABLE dbo.MaterialParteTrabajo;
IF OBJECT_ID('dbo.PartesDeTrabajo', 'U') IS NOT NULL DROP TABLE dbo.PartesDeTrabajo;
IF OBJECT_ID('dbo.ZonasOperacion', 'U') IS NOT NULL DROP TABLE dbo.ZonasOperacion;
IF OBJECT_ID('dbo.Ausencias', 'U') IS NOT NULL DROP TABLE dbo.Ausencias;
IF OBJECT_ID('dbo.HorariosLaborales', 'U') IS NOT NULL DROP TABLE dbo.HorariosLaborales;
IF OBJECT_ID('dbo.Citas', 'U') IS NOT NULL DROP TABLE dbo.Citas;
IF OBJECT_ID('dbo.LineasFactura', 'U') IS NOT NULL DROP TABLE dbo.LineasFactura;
IF OBJECT_ID('dbo.Facturas', 'U') IS NOT NULL DROP TABLE dbo.Facturas;
IF OBJECT_ID('dbo.DetallesCompra', 'U') IS NOT NULL DROP TABLE dbo.DetallesCompra;
IF OBJECT_ID('dbo.Compras', 'U') IS NOT NULL DROP TABLE dbo.Compras;
IF OBJECT_ID('dbo.Servicios', 'U') IS NOT NULL DROP TABLE dbo.Servicios;
IF OBJECT_ID('dbo.Articulos', 'U') IS NOT NULL DROP TABLE dbo.Articulos;
IF OBJECT_ID('dbo.Proveedores', 'U') IS NOT NULL DROP TABLE dbo.Proveedores;
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL DROP TABLE dbo.Clientes;
IF OBJECT_ID('dbo.Empleados', 'U') IS NOT NULL DROP TABLE dbo.Empleados;
GO

PRINT 'Tablas existentes eliminadas. Procediendo a la creación...';
GO

-- ************************************************************
-- PASO 2: Creación de Tablas con Comprobación (CREATE IF NOT EXISTS)
-- ************************************************************

-- 1. Tablas Base: Empleados, Clientes, Proveedores

-- 1.1. Empleados
IF OBJECT_ID('dbo.Empleados', 'U') IS NULL
BEGIN
    CREATE TABLE Empleados (
        EmpleadoID INT PRIMARY KEY IDENTITY(1,1),
        NIF VARCHAR(15) NOT NULL UNIQUE,
        Nombre VARCHAR(50) NOT NULL,
        Apellido1 VARCHAR(50) NOT NULL,
        Apellido2 VARCHAR(50),
        Telefono VARCHAR(15),
        Email VARCHAR(100) UNIQUE,
        Direccion VARCHAR(200),
        Cargo VARCHAR(50) NOT NULL,
        FechaContratacion DATE NOT NULL,
        Activo BIT DEFAULT 1
    );
END
GO

-- 1.2. Clientes
IF OBJECT_ID('dbo.Clientes', 'U') IS NULL
BEGIN
    CREATE TABLE Clientes (
        ClienteID INT PRIMARY KEY IDENTITY(1,1),
        TipoCliente CHAR(1) NOT NULL CHECK (TipoCliente IN ('P', 'E')),
        NIF_CIF VARCHAR(20) UNIQUE,
        NombreRazonSocial VARCHAR(100) NOT NULL,
        NombreContacto VARCHAR(100),
        Telefono VARCHAR(15),
        Email VARCHAR(100) UNIQUE,
        Direccion VARCHAR(200) NOT NULL,
        CondicionesPago VARCHAR(50)
    );
END
GO

-- 1.3. Proveedores
IF OBJECT_ID('dbo.Proveedores', 'U') IS NULL
BEGIN
    CREATE TABLE Proveedores (
        ProveedorID INT PRIMARY KEY IDENTITY(1,1),
        CIF VARCHAR(20) NOT NULL UNIQUE,
        NombreComercial VARCHAR(100) NOT NULL,
        NombreContacto VARCHAR(100),
        Telefono VARCHAR(15),
        Email VARCHAR(100) UNIQUE,
        Direccion VARCHAR(200) NOT NULL,
        CondicionesPago VARCHAR(50)
    );
END
GO

-- 2. Almacén e Inventario

-- 2.1. Articulos
IF OBJECT_ID('dbo.Articulos', 'U') IS NULL
BEGIN
    CREATE TABLE Articulos (
        ArticuloID INT PRIMARY KEY IDENTITY(1,1),
        CodigoArticulo VARCHAR(50) UNIQUE NOT NULL,
        Nombre VARCHAR(100) NOT NULL,
        Descripcion TEXT,
        PrecioVenta DECIMAL(10, 2) NOT NULL,
        UnidadMedida VARCHAR(20),
        StockActual INT NOT NULL DEFAULT 0,
        StockMinimo INT DEFAULT 5
    );
END
GO

-- 2.2. Compras (Relaciona Artículos con Proveedores)
IF OBJECT_ID('dbo.Compras', 'U') IS NULL
BEGIN
    CREATE TABLE Compras (
        CompraID INT PRIMARY KEY IDENTITY(1,1),
        ProveedorID INT NOT NULL,
        FechaCompra DATE NOT NULL,
        NumeroFacturaProveedor VARCHAR(50) UNIQUE NOT NULL,
        TotalCompra DECIMAL(10, 2) NOT NULL,
        EmpleadoID INT NOT NULL,
        CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID),
        CONSTRAINT FK_Compra_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID)
    );
END
GO

-- 2.3. DetallesCompra (M-M entre Compras y Artículos)
IF OBJECT_ID('dbo.DetallesCompra', 'U') IS NULL
BEGIN
    CREATE TABLE DetallesCompra (
        DetalleCompraID INT PRIMARY KEY IDENTITY(1,1),
        CompraID INT NOT NULL,
        ArticuloID INT NOT NULL,
        Cantidad INT NOT NULL,
        PrecioUnitarioCompra DECIMAL(10, 2) NOT NULL,
        CONSTRAINT FK_DetalleCompra_Compra FOREIGN KEY (CompraID) REFERENCES Compras(CompraID),
        CONSTRAINT FK_DetalleCompra_Articulo FOREIGN KEY (ArticuloID) REFERENCES Articulos(ArticuloID),
        CONSTRAINT UQ_Compra_Articulo UNIQUE (CompraID, ArticuloID)
    );
END
GO

-- 3. Facturación

-- 3.1. Facturas
IF OBJECT_ID('dbo.Facturas', 'U') IS NULL
BEGIN
    CREATE TABLE Facturas (
        FacturaID INT PRIMARY KEY IDENTITY(1,1),
        NumeroFactura VARCHAR(50) UNIQUE NOT NULL,
        ClienteID INT NOT NULL,
        FechaEmision DATE NOT NULL,
        FechaVencimiento DATE,
        TotalNeto DECIMAL(10, 2) NOT NULL,
        IVA DECIMAL(10, 2) NOT NULL,
        TotalFactura DECIMAL(10, 2) NOT NULL,
        EstadoFactura VARCHAR(20) NOT NULL CHECK (EstadoFactura IN ('Pendiente', 'Pagada', 'Anulada')),
        EmpleadoID INT,
        CONSTRAINT FK_Factura_Cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
        CONSTRAINT FK_Factura_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID)
    );
END
GO

-- 3.2. LineasFactura (Detalles de la Factura)
IF OBJECT_ID('dbo.LineasFactura', 'U') IS NULL
BEGIN
    CREATE TABLE LineasFactura (
        LineaFacturaID INT PRIMARY KEY IDENTITY(1,1),
        FacturaID INT NOT NULL,
        ArticuloID INT,
        DescripcionServicio TEXT,
        Cantidad DECIMAL(10, 2) NOT NULL,
        PrecioUnitario DECIMAL(10, 2) NOT NULL,
        Subtotal DECIMAL(10, 2) NOT NULL,
        CONSTRAINT FK_LineaFactura_Factura FOREIGN KEY (FacturaID) REFERENCES Facturas(FacturaID),
        CONSTRAINT FK_LineaFactura_Articulo FOREIGN KEY (ArticuloID) REFERENCES Articulos(ArticuloID)
    );
END
GO

-- 4. Agenda y Servicios

-- 4.1. Servicios (Tipos de trabajos de fontanería)
IF OBJECT_ID('dbo.Servicios', 'U') IS NULL
BEGIN
    CREATE TABLE Servicios (
        ServicioID INT PRIMARY KEY IDENTITY(1,1),
        NombreServicio VARCHAR(100) NOT NULL,
        Descripcion TEXT,
        PrecioBase DECIMAL(10, 2)
    );
END
GO

-- 4.2. Citas (Agenda)
IF OBJECT_ID('dbo.Citas', 'U') IS NULL
BEGIN
    CREATE TABLE Citas (
        CitaID INT PRIMARY KEY IDENTITY(1,1),
        ClienteID INT NOT NULL,
        ServicioID INT NOT NULL,
        EmpleadoID INT NOT NULL,
        FechaHoraInicio DATETIME NOT NULL,
        FechaHoraFin DATETIME NOT NULL,
        DireccionServicio VARCHAR(200) NOT NULL,
        EstadoCita VARCHAR(20) NOT NULL CHECK (EstadoCita IN ('Pendiente', 'Confirmada', 'En Curso', 'Completada', 'Cancelada')),
        Comentarios TEXT,
        FacturaID INT UNIQUE,
        CONSTRAINT FK_Cita_Cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
        CONSTRAINT FK_Cita_Servicio FOREIGN KEY (ServicioID) REFERENCES Servicios(ServicioID),
        CONSTRAINT FK_Cita_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID),
        CONSTRAINT FK_Cita_Factura FOREIGN KEY (FacturaID) REFERENCES Facturas(FacturaID)
    );
END
GO

-- 5. Horarios (Gestión de la disponibilidad de los empleados)

-- 5.1. HorariosLaborales (Horario general del empleado)
IF OBJECT_ID('dbo.HorariosLaborales', 'U') IS NULL
BEGIN
    CREATE TABLE HorariosLaborales (
        HorarioID INT PRIMARY KEY IDENTITY(1,1),
        EmpleadoID INT NOT NULL,
        DiaSemana INT NOT NULL CHECK (DiaSemana BETWEEN 1 AND 7),
        HoraEntrada TIME NOT NULL,
        HoraSalida TIME NOT NULL,
        CONSTRAINT UQ_Empleado_Dia UNIQUE (EmpleadoID, DiaSemana),
        CONSTRAINT FK_HorarioLaboral_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID)
    );
END
GO

-- 5.2. Ausencias (Vacaciones, bajas, etc.)
IF OBJECT_ID('dbo.Ausencias', 'U') IS NULL
BEGIN
    CREATE TABLE Ausencias (
        AusenciaID INT PRIMARY KEY IDENTITY(1,1),
        EmpleadoID INT NOT NULL,
        FechaInicio DATE NOT NULL,
        FechaFin DATE NOT NULL,
        TipoAusencia VARCHAR(50) NOT NULL,
        Motivo TEXT,
        CONSTRAINT FK_Ausencia_Empleado FOREIGN KEY (EmpleadoID) REFERENCES Empleados(EmpleadoID)
    );
END
GO

-- 6. Tablas Adicionales (Zonas, Partes de Trabajo, Material)

IF OBJECT_ID('dbo.ZonasOperacion', 'U') IS NULL
BEGIN
    CREATE TABLE ZonasOperacion (
        ZonaID INT PRIMARY KEY IDENTITY(1,1),
        NombreZona VARCHAR(50) NOT NULL UNIQUE,
        CodigoPostalInicio VARCHAR(10),
        CodigoPostalFin VARCHAR(10)
    );
END
GO

IF OBJECT_ID('dbo.PartesDeTrabajo', 'U') IS NULL
BEGIN
    CREATE TABLE PartesDeTrabajo (
        ParteID INT PRIMARY KEY IDENTITY(1,1),
        CitaID INT NOT NULL UNIQUE,
        FechaHoraLlegada DATETIME NOT NULL,
        FechaHoraSalida DATETIME,
        Diagnostico TEXT,
        SolucionAplicada TEXT,
        EstadoFinal VARCHAR(20) NOT NULL CHECK (EstadoFinal IN ('Resuelto', 'Pendiente Material', 'Pendiente Aprobacion')),
        HorasTrabajadas DECIMAL(4, 2),
        CONSTRAINT FK_Parte_Cita FOREIGN KEY (CitaID) REFERENCES Citas(CitaID)
    );
END
GO

IF OBJECT_ID('dbo.MaterialParteTrabajo', 'U') IS NULL
BEGIN
    CREATE TABLE MaterialParteTrabajo (
        MaterialParteID INT PRIMARY KEY IDENTITY(1,1),
        ParteID INT NOT NULL,
        ArticuloID INT NOT NULL,
        CantidadConsumida INT NOT NULL,
        CONSTRAINT FK_MaterialParte_Parte FOREIGN KEY (ParteID) REFERENCES PartesDeTrabajo(ParteID),
        CONSTRAINT FK_MaterialParte_Articulo FOREIGN KEY (ArticuloID) REFERENCES Articulos(ArticuloID),
        CONSTRAINT UQ_Parte_Articulo UNIQUE (ParteID, ArticuloID)
    );
END
GO

PRINT 'Creación de tablas finalizada. Las tablas existentes no fueron duplicadas.';


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
CREATE PROCEDURE SP_AgendarNuevaCita
    @ClienteID INT,
    @ServicioID INT,
    @EmpleadoID INT,
    @FechaHoraInicio DATETIME,
    @FechaHoraFin DATETIME,
    @DireccionServicio VARCHAR(200),
    @Comentarios TEXT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación básica de fechas
    IF @FechaHoraInicio >= @FechaHoraFin
    BEGIN
        RAISERROR('La fecha/hora de inicio debe ser anterior a la fecha/hora de fin.', 16, 1);
        RETURN;
    END

    -- Insertar la nueva cita con estado 'Pendiente' por defecto
    INSERT INTO dbo.Citas (ClienteID, ServicioID, EmpleadoID, FechaHoraInicio, FechaHoraFin, DireccionServicio, EstadoCita, Comentarios)
    VALUES (@ClienteID, @ServicioID, @EmpleadoID, @FechaHoraInicio, @FechaHoraFin, @DireccionServicio, 'Pendiente', @Comentarios);

    SELECT CitaID, 'Cita agendada con éxito.' AS Mensaje FROM dbo.Citas WHERE CitaID = SCOPE_IDENTITY();
END
GO
CREATE TYPE TipoMaterialConsumido AS TABLE (
    ArticuloID INT,
    CantidadConsumida INT
);
GO

CREATE PROCEDURE SP_FinalizarServicioYGenerarParte
    @CitaID INT,
    @FechaHoraLlegada DATETIME,
    @FechaHoraSalida DATETIME,
    @Diagnostico TEXT,
    @SolucionAplicada TEXT,
    @HorasTrabajadas DECIMAL(4, 2),
    @Materiales TipoMaterialConsumido READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ParteID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Crear el Parte de Trabajo
        INSERT INTO dbo.PartesDeTrabajo (CitaID, FechaHoraLlegada, FechaHoraSalida, Diagnostico, SolucionAplicada, EstadoFinal, HorasTrabajadas)
        VALUES (@CitaID, @FechaHoraLlegada, @FechaHoraSalida, @Diagnostico, @SolucionAplicada, 'Resuelto', @HorasTrabajadas);

        SET @ParteID = SCOPE_IDENTITY();

        -- 2. Registrar el material consumido y actualizar stock
        IF EXISTS (SELECT 1 FROM @Materiales)
        BEGIN
            -- Insertar líneas en MaterialParteTrabajo
            INSERT INTO dbo.MaterialParteTrabajo (ParteID, ArticuloID, CantidadConsumida)
            SELECT @ParteID, ArticuloID, CantidadConsumida FROM @Materiales;

            -- Descontar el stock de Articulos
            UPDATE A
            SET A.StockActual = A.StockActual - M.CantidadConsumida
            FROM dbo.Articulos AS A
            INNER JOIN @Materiales AS M ON A.ArticuloID = M.ArticuloID;
        END

        -- 3. Actualizar estado de la Cita
        UPDATE dbo.Citas
        SET EstadoCita = 'Completada',
            Comentarios = @Diagnostico + ' / ' + @SolucionAplicada -- Concatenar el resumen
        WHERE CitaID = @CitaID;

        COMMIT TRANSACTION;
        SELECT @ParteID AS ParteID, 'Parte de Trabajo generado y Cita completada con éxito.' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW; -- Re-lanzar el error para que la aplicación lo gestione
    END CATCH
END
GO
CREATE PROCEDURE SP_ProcesarRecepcionCompra
    @CompraID INT,
    @Detalles TipoMaterialConsumido READONLY -- Reutilizamos el mismo tipo de tabla para la estructura Articulo/Cantidad
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Insertar los detalles de la compra (Articulos recibidos)
        INSERT INTO dbo.DetallesCompra (CompraID, ArticuloID, Cantidad, PrecioUnitarioCompra)
        SELECT
            @CompraID,
            M.ArticuloID,
            M.CantidadConsumida,
            (SELECT PrecioBase.PrecioUnitarioCompra FROM dbo.DetallesCompra PrecioBase WHERE PrecioBase.ArticuloID = M.ArticuloID AND PrecioBase.CompraID != @CompraID) -- Usar precio de compra anterior como ejemplo, esto debería venir del formulario de compra real.
        FROM @Detalles AS M;

        -- 2. Actualizar el Stock Actual de los Artículos (Añadir)
        UPDATE A
        SET A.StockActual = A.StockActual + D.CantidadConsumida
        FROM dbo.Articulos AS A
        INNER JOIN @Detalles AS D ON A.ArticuloID = D.ArticuloID;

        COMMIT TRANSACTION;
        SELECT @CompraID AS CompraID, 'Stock actualizado y detalles de compra registrados con éxito.' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO
CREATE FUNCTION FN_CalcularDisponibilidadDiaria
(
    @EmpleadoID INT,
    @FechaHoraConsulta DATETIME
)
RETURNS BIT
AS
BEGIN
    DECLARE @Disponibilidad BIT = 0;
    DECLARE @DiaSemana INT;
    DECLARE @Hora TIME;

    SET @DiaSemana = DATEPART(dw, @FechaHoraConsulta); -- SQL Server: 1=Domingo, 2=Lunes, etc.
    SET @Hora = CAST(@FechaHoraConsulta AS TIME);

    -- Ajuste para hacer Lunes=1, Martes=2, etc., si la configuración regional lo requiere (Asumo 1=Lunes para los datos ingresados)
    -- Si tu entorno usa 1=Domingo, se ajusta el resultado para el chequeo de HorariosLaborales
    IF @DiaSemana = 1 SET @DiaSemana = 7; -- Si es Domingo (1), lo mapeamos a 7
    ELSE SET @DiaSemana = @DiaSemana - 1; -- Si es Lun(2), Mar(3), etc., los mapeamos a 1, 2, etc.

    -- 1. Verificar Ausencias
    IF EXISTS (
        SELECT 1
        FROM dbo.Ausencias
        WHERE EmpleadoID = @EmpleadoID
          AND @FechaHoraConsulta >= FechaInicio
          AND @FechaHoraConsulta < DATEADD(DAY, 1, FechaFin) -- Incluye el día de fin
    )
    BEGIN
        SET @Disponibilidad = 0; -- Ausente por vacaciones/baja
    END
    ELSE
    BEGIN
        -- 2. Verificar Horario Laboral y la hora actual
        IF EXISTS (
            SELECT 1
            FROM dbo.HorariosLaborales
            WHERE EmpleadoID = @EmpleadoID
              AND DiaSemana = @DiaSemana
              AND @Hora >= HoraEntrada
              AND @Hora <= HoraSalida
        )
        BEGIN
            -- 3. Verificar Citas Agendadas que se superpongan (excluyendo Canceladas)
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.Citas
                WHERE EmpleadoID = @EmpleadoID
                  AND EstadoCita NOT IN ('Completada', 'Cancelada')
                  AND @FechaHoraConsulta >= FechaHoraInicio
                  AND @FechaHoraConsulta < FechaHoraFin -- La hora de fin de una cita no bloquea la hora de inicio de la siguiente
            )
            BEGIN
                SET @Disponibilidad = 1; -- Disponible: No ausente, en horario, y sin cita superpuesta
            END
        END
    END

    RETURN @Disponibilidad;
END
GO
CREATE FUNCTION FN_ObtenerTotalArticulosFactura
(
    @FacturaID INT
)
RETURNS @TotalArticulos TABLE
(
    ArticuloID INT,
    NombreArticulo VARCHAR(100),
    CantidadTotal DECIMAL(10, 2),
    SubtotalArticulos DECIMAL(10, 2)
)
AS
BEGIN
    INSERT INTO @TotalArticulos (ArticuloID, NombreArticulo, CantidadTotal, SubtotalArticulos)
    SELECT
        A.ArticuloID,
        A.Nombre,
        SUM(LF.Cantidad) AS CantidadTotal,
        SUM(LF.Subtotal) AS SubtotalArticulos
    FROM
        dbo.LineasFactura AS LF
    INNER JOIN
        dbo.Articulos AS A ON LF.ArticuloID = A.ArticuloID
    WHERE
        LF.FacturaID = @FacturaID
        AND LF.ArticuloID IS NOT NULL -- Solo consideramos líneas que son artículos
    GROUP BY
        A.ArticuloID, A.Nombre;

    RETURN;
END
GO
-- Ejemplo de uso de la función de disponibilidad:
-- Verifica si el EmpleadoID 1 está disponible el 2025-11-26 a las 16:00
SELECT dbo.FN_CalcularDisponibilidadDiaria(1, '2025-11-26 16:00:00') AS EstaDisponible;

-- Puedes usarla en una consulta para encontrar el primer fontanero disponible:
SELECT TOP 1
    E.EmpleadoID,
    E.Nombre + ' ' + E.Apellido1 AS Fontanero,
    dbo.FN_CalcularDisponibilidadDiaria(E.EmpleadoID, '2025-11-26 16:00:00') AS Disponibilidad
FROM
    dbo.Empleados AS E
WHERE
    E.Cargo LIKE '%Fontanero%'
    AND dbo.FN_CalcularDisponibilidadDiaria(E.EmpleadoID, '2025-11-26 16:00:00') = 1;



CREATE PROCEDURE SP_GenerarFacturaDesdeCita
    @CitaID INT,
    @EmpleadoContableID INT, -- ID del empleado que emite la factura (e.g., Contable o Gerente)
    @PorcentajeIVA DECIMAL(4, 2) = 0.21 -- Tasa de IVA por defecto (21%)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ClienteID INT;
    DECLARE @ServicioID INT;
    DECLARE @ParteID INT;
    DECLARE @HorasTrabajadas DECIMAL(4, 2);
    DECLARE @PrecioBaseServicio DECIMAL(10, 2);
    DECLARE @CostoHoraManoObra DECIMAL(10, 2); -- Precio del servicio 'Mano de Obra'
    
    DECLARE @FacturaID INT;
    DECLARE @TotalNeto DECIMAL(10, 2) = 0;
    DECLARE @TotalIVA DECIMAL(10, 2);
    DECLARE @TotalFactura DECIMAL(10, 2);
    
    -- ID fijo para el servicio de Mano de Obra (asumiendo que se definió un ID específico, e.g., 404)
    DECLARE @ServicioManoObraID INT = 404;
    
    -- ************************************************************
    -- 1. VALIDACIÓN Y OBTENCIÓN DE DATOS CLAVE
    -- ************************************************************
    
    -- Obtener datos de la Cita
    SELECT 
        @ClienteID = C.ClienteID, 
        @ServicioID = C.ServicioID
    FROM dbo.Citas AS C
    WHERE C.CitaID = @CitaID AND C.EstadoCita = 'Completada' AND C.FacturaID IS NULL;

    IF @ClienteID IS NULL
    BEGIN
        RAISERROR('La Cita no existe, no está completada, o ya ha sido facturada.', 16, 1);
        RETURN;
    END

    -- Obtener datos del Parte de Trabajo
    SELECT 
        @ParteID = P.ParteID, 
        @HorasTrabajadas = P.HorasTrabajadas
    FROM dbo.PartesDeTrabajo AS P
    WHERE P.CitaID = @CitaID;

    IF @ParteID IS NULL
    BEGIN
        RAISERROR('No se encontró un Parte de Trabajo asociado a la cita completada. No se puede facturar.', 16, 1);
        RETURN;
    END

    -- Obtener Precios Base
    SELECT @PrecioBaseServicio = PrecioBase FROM dbo.Servicios WHERE ServicioID = @ServicioID;
    SELECT @CostoHoraManoObra = PrecioBase FROM dbo.Servicios WHERE ServicioID = @ServicioManoObraID;
    
    IF @CostoHoraManoObra IS NULL OR @CostoHoraManoObra = 0
    BEGIN
        RAISERROR('No se encontró el precio base para el Servicio de Mano de Obra (ID %d).', 16, 1, @ServicioManoObraID);
        RETURN;
    END
    
    -- ************************************************************
    -- 2. CÁLCULO DE TOTALES (NETO)
    -- ************************************************************
    
    -- Inicializar con el servicio base de la cita
    SET @TotalNeto = @TotalNeto + @PrecioBaseServicio;
    
    -- Sumar la Mano de Obra (horas trabajadas * costo por hora)
    SET @TotalNeto = @TotalNeto + (@HorasTrabajadas * @CostoHoraManoObra);
    
    -- Sumar el material consumido (Cantidad * PrecioVenta de Articulos)
    SELECT @TotalNeto = @TotalNeto + ISNULL(SUM(MT.CantidadConsumida * A.PrecioVenta), 0)
    FROM dbo.MaterialParteTrabajo AS MT
    INNER JOIN dbo.Articulos AS A ON MT.ArticuloID = A.ArticuloID
    WHERE MT.ParteID = @ParteID;

    -- Calcular IVA y Total Final
    SET @TotalIVA = @TotalNeto * @PorcentajeIVA;
    SET @TotalFactura = @TotalNeto + @TotalIVA;
    
    
    -- ************************************************************
    -- 3. INSERCIÓN DE FACTURA Y LÍNEAS
    -- ************************************************************

    BEGIN TRANSACTION;
    
    -- 3.1. Insertar en Facturas
    INSERT INTO dbo.Facturas (NumeroFactura, ClienteID, FechaEmision, FechaVencimiento, TotalNeto, IVA, TotalFactura, EstadoFactura, EmpleadoID)
    VALUES (
        'F' + FORMAT(YEAR(GETDATE()), '0000') + '-' + FORMAT(NEXT VALUE FOR sys.sequences.SQ_NumeroFactura, '0000'), -- Genera un número de factura (asumiendo secuencia o lógica de negocio)
        @ClienteID,
        GETDATE(), -- Fecha de emisión
        DATEADD(day, 30, GETDATE()), -- Vencimiento a 30 días
        @TotalNeto,
        @TotalIVA,
        @TotalFactura,
        'Pendiente', -- Estado inicial
        @EmpleadoContableID
    );
    
    SET @FacturaID = SCOPE_IDENTITY();

    -- 3.2. Insertar LíneasFactura: Servicio Base
    INSERT INTO dbo.LineasFactura (FacturaID, DescripcionServicio, Cantidad, PrecioUnitario, Subtotal)
    SELECT @FacturaID, NombreServicio, 1.00, PrecioBase, PrecioBase
    FROM dbo.Servicios WHERE ServicioID = @ServicioID;

    -- 3.3. Insertar LíneasFactura: Mano de Obra
    INSERT INTO dbo.LineasFactura (FacturaID, DescripcionServicio, Cantidad, PrecioUnitario, Subtotal)
    SELECT @FacturaID, 'Mano de Obra (' + S.NombreServicio + ')', @HorasTrabajadas, S.PrecioBase, (@HorasTrabajadas * S.PrecioBase)
    FROM dbo.Servicios AS S WHERE S.ServicioID = @ServicioManoObraID;

    -- 3.4. Insertar LíneasFactura: Materiales Consumidos
    INSERT INTO dbo.LineasFactura (FacturaID, ArticuloID, Cantidad, PrecioUnitario, Subtotal)
    SELECT
        @FacturaID,
        MT.ArticuloID,
        CAST(MT.CantidadConsumida AS DECIMAL(10, 2)),
        A.PrecioVenta,
        MT.CantidadConsumida * A.PrecioVenta
    FROM dbo.MaterialParteTrabajo AS MT
    INNER JOIN dbo.Articulos AS A ON MT.ArticuloID = A.ArticuloID
    WHERE MT.ParteID = @ParteID;
    
    -- 3.5. Actualizar la Cita con el FacturaID
    UPDATE dbo.Citas
    SET FacturaID = @FacturaID
    WHERE CitaID = @CitaID;

    COMMIT TRANSACTION;
    
    SELECT @FacturaID AS FacturaIDGenerada, 'Factura creada y asociada a la Cita con éxito.' AS Mensaje;
    
END
GO