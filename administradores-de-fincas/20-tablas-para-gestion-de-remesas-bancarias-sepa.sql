-- Agregar campo de IBAN a la tabla Propietarios (si no se hizo ya)
ALTER TABLE Propietarios
ADD IBAN VARCHAR(34);
-- Y, opcionalmente, el Código BIC/SWIFT si se requiere.
ALTER TABLE Propietarios
ADD BIC VARCHAR(11);
GO
CREATE TABLE RemesasSEPA (
    RemesaID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    FechaCreacion DATETIME NOT NULL,
    FechaCargoPrevista DATE NOT NULL,
    ConceptoRemesa VARCHAR(100) NOT NULL, -- Ej: 'Cuotas Ordinarias Enero 2026'
    TotalRecibos INT NOT NULL,
    MontoTotal DECIMAL(10, 2) NOT NULL,
    EstadoRemesa VARCHAR(50), -- Ej: 'Creada', 'Exportada', 'Aceptada Banco', 'Rechazada'
    RutaArchivoXML VARCHAR(255), -- Ruta del archivo SEPA generado
    FOREIGN KEY (ComunidadID) REFERENCES Comunidades(ComunidadID)
);
