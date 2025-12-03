-- 5. Cuentas Contables (Plan de cuentas simplificado: Ingresos, Gastos, Bancos)
CREATE TABLE Cuentas (
    CuentaID INT PRIMARY KEY IDENTITY(1000, 1), -- Iniciar en un número típico
    ComunidadID INT NOT NULL,
    CodigoCuenta VARCHAR(10) NOT NULL,
    Descripcion VARCHAR(100) NOT NULL,
    TipoCuenta VARCHAR(50) NOT NULL, -- Ej: 'Ingreso', 'Gasto', 'Banco', 'Deuda'
    FOREIGN KEY (ComunidadID) REFERENCES Comunidades(ComunidadID),
    UNIQUE (ComunidadID, CodigoCuenta)
);

-- 6. Proveedores (Empresas o profesionales que prestan servicios)
CREATE TABLE Proveedores (
    ProveedorID INT PRIMARY KEY IDENTITY(1,1),
    NIF_CIF VARCHAR(20) UNIQUE,
    RazonSocial VARCHAR(150) NOT NULL,
    Contacto VARCHAR(100),
    Telefono VARCHAR(20),
    Email VARCHAR(100)
);

-- 7. Movimientos Contables (Facturas, recibos, pagos, etc.)
CREATE TABLE Movimientos (
    MovimientoID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    FechaMovimiento DATE NOT NULL,
    TipoMovimiento VARCHAR(10) NOT NULL, -- Ej: 'Ingreso', 'Gasto'
    Concepto VARCHAR(255) NOT NULL,
    Monto DECIMAL(10, 2) NOT NULL,
    CuentaContableID INT NOT NULL,
    ProveedorID INT, -- NULL si no es un gasto/ingreso de proveedor (ej: cuota de propietario)
    NumeroFactura VARCHAR(50), -- Opcional
    FOREIGN KEY (ComunidadID) REFERENCES Comunidades(ComunidadID),
    FOREIGN KEY (CuentaContableID) REFERENCES Cuentas(CuentaID),
    FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID)
);

-- 8. Derramas y Cuotas (Detalle de lo que debe pagar cada unidad)
CREATE TABLE CuotasDerramas (
    CuotaDerramaID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    UnidadID INT NOT NULL,
    Mes YEAR, -- Año y mes de la cuota
    MontoCuota DECIMAL(10, 2) NOT NULL,
    EstadoPago VARCHAR(20) DEFAULT 'Pendiente', -- Ej: 'Pagado', 'Pendiente', 'Abonado'
    FechaVencimiento DATE,
    FechaPago DATE,
    FOREIGN KEY (ComunidadID) REFERENCES Comunidades(ComunidadID),
    FOREIGN KEY (UnidadID) REFERENCES Unidades(UnidadID),
    UNIQUE (UnidadID, Mes)
);