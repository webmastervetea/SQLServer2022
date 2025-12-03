CREATE TABLE Siniestros (
    SiniestroID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    FechaOcurrencia DATETIME NOT NULL,
    DescripcionSiniestro TEXT NOT NULL,
    TipoSiniestro VARCHAR(100), -- Ej: 'Daños por Agua', 'Robo', 'Incendio', 'Rotura Cristales'
    NumeroPoliza VARCHAR(50), -- Número de póliza afectada
    CompaniaAseguradora VARCHAR(100),
    NumeroExpedienteAseguradora VARCHAR(50) UNIQUE, -- El número de referencia que nos da la aseguradora
    Estado VARCHAR(50) NOT NULL, -- Ej: 'Abierto', 'Peritado', 'En reparación', 'Cerrado con Cargo', 'Cerrado sin Cargo'
    FechaCierre DATE,
    MontoIndemnizacion DECIMAL(10, 2), -- Monto pagado por la aseguradora (si aplica)
    FOREIGN KEY (ComunidadID) REFERENCES Comunidades(ComunidadID)
);
GO
CREATE TABLE SeguimientoSiniestros (
    SeguimientoSiniestroID INT PRIMARY KEY IDENTITY(1,1),
    SiniestroID INT NOT NULL,
    FechaActualizacion DATETIME NOT NULL,
    Detalle TEXT NOT NULL, -- Ej: 'Se ha llamado al perito', 'Se ha enviado la factura al seguro'
    UsuarioActualiza VARCHAR(50),
    FOREIGN KEY (SiniestroID) REFERENCES Siniestros(SiniestroID)
);
GO
CREATE PROCEDURE SP_ActualizarEstadoSiniestro
    @SiniestroID INT,
    @NuevoEstado VARCHAR(50),
    @DetalleActualizacion TEXT,
    @Usuario VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Actualizar el estado del siniestro
        UPDATE Siniestros
        SET 
            Estado = @NuevoEstado,
            FechaCierre = CASE WHEN @NuevoEstado = 'Cerrado con Cargo' OR @NuevoEstado = 'Cerrado sin Cargo' THEN GETDATE() ELSE FechaCierre END
        WHERE SiniestroID = @SiniestroID;

        -- 2. Registrar el seguimiento
        INSERT INTO SeguimientoSiniestros (SiniestroID, FechaActualizacion, Detalle, UsuarioActualiza)
        VALUES (@SiniestroID, GETDATE(), @DetalleActualizacion, @Usuario);

        COMMIT TRANSACTION;
        PRINT 'Estado del siniestro ' + CAST(@SiniestroID AS VARCHAR) + ' actualizado a ' + @NuevoEstado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
        RETURN;
    END CATCH
END;
GO
