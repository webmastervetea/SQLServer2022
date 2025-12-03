-- 9. Juntas de Propietarios (Registro de Actas y Acuerdos)
CREATE TABLE Juntas (
    JuntaID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    FechaJunta DATETIME NOT NULL,
    TipoJunta VARCHAR(50) NOT NULL, -- Ej: 'Ordinaria', 'Extraordinaria'
    AsuntoPrincipal VARCHAR(255) NOT NULL,
    ActaRutaArchivo VARCHAR(255), -- Ruta o URL al documento del acta
    FOREIGN KEY (ComunidadID) REFERENCES Comunidades(ComunidadID)
);

-- 10. Acuerdos Tomados en Junta
CREATE TABLE Acuerdos (
    AcuerdoID INT PRIMARY KEY IDENTITY(1,1),
    JuntaID INT NOT NULL,
    DescripcionAcuerdo TEXT NOT NULL,
    VotosFavor INT DEFAULT 0,
    VotosContra INT DEFAULT 0,
    VotosAbstencion INT DEFAULT 0,
    AcuerdoAprobado BIT,
    FOREIGN KEY (JuntaID) REFERENCES Juntas(JuntaID)
);

-- 11. Documentos Generales (Estatutos, Seguros, Contratos, etc.)
CREATE TABLE Documentos (
    DocumentoID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    NombreDocumento VARCHAR(150) NOT NULL,
    TipoDocumento VARCHAR(50) NOT NULL, -- Ej: 'Estatutos', 'Póliza Seguro', 'Contrato Mantenimiento'
    FechaSubida DATE DEFAULT GETDATE(),
    RutaArchivo VARCHAR(255) NOT NULL,
    FOREIGN KEY (ComunidadID) REFERENCES Comunidades(ComunidadID)
);