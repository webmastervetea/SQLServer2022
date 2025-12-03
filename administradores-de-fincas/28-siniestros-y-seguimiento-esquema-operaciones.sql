-- 14. Siniestros
CREATE TABLE Operaciones.Siniestros (
    SiniestroID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    FechaOcurrencia DATETIME NOT NULL,
    DescripcionSiniestro TEXT NOT NULL,
    TipoSiniestro VARCHAR(100), 
    NumeroPoliza VARCHAR(50), 
    CompaniaAseguradora VARCHAR(100),
    NumeroExpedienteAseguradora VARCHAR(50) UNIQUE, 
    Estado VARCHAR(50) NOT NULL, 
    FechaCierre DATE,
    MontoIndemnizacion DECIMAL(10, 2), 
    -- Se usan claves foráneas a las tablas del esquema Admin
    FOREIGN KEY (ComunidadID) REFERENCES Admin.Comunidades(ComunidadID)
);

-- 15. SeguimientoSiniestros
CREATE TABLE Operaciones.SeguimientoSiniestros (
    SeguimientoSiniestroID INT PRIMARY KEY IDENTITY(1,1),
    SiniestroID INT NOT NULL,
    FechaActualizacion DATETIME NOT NULL,
    Detalle TEXT NOT NULL,
    UsuarioActualiza VARCHAR(50),
    FOREIGN KEY (SiniestroID) REFERENCES Operaciones.Siniestros(SiniestroID)
);
GO
-- 16. RemesasSEPA
CREATE TABLE Contabilidad.RemesasSEPA (
    RemesaID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    FechaCreacion DATETIME NOT NULL,
    FechaCargoPrevista DATE NOT NULL,
    ConceptoRemesa VARCHAR(100) NOT NULL,
    TotalRecibos INT NOT NULL,
    MontoTotal DECIMAL(10, 2) NOT NULL,
    EstadoRemesa VARCHAR(50),
    RutaArchivoXML VARCHAR(255),
    FOREIGN KEY (ComunidadID) REFERENCES Admin.Comunidades(ComunidadID)
);

-- 17. DetalleRemesa (Relaciona Remesa con Cuotas)
CREATE TABLE Contabilidad.DetalleRemesa (
    DetalleRemesaID INT PRIMARY KEY IDENTITY(1,1),
    RemesaID INT NOT NULL,
    CuotaDerramaID INT UNIQUE NOT NULL,
    MontoCobrado DECIMAL(10, 2) NOT NULL,
    EstadoRecibo VARCHAR(50), 
    FOREIGN KEY (RemesaID) REFERENCES Contabilidad.RemesasSEPA(RemesaID),
    FOREIGN KEY (CuotaDerramaID) REFERENCES Contabilidad.CuotasDerramas(CuotaDerramaID)
);
GO
