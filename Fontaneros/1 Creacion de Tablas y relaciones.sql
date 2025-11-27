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