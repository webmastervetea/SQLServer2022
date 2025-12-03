CREATE PROCEDURE SP_RegistrarIncidencia
    @ComunidadID INT,
    @UnidadID INT = NULL, -- Opcional
    @Descripcion TEXT,
    @Prioridad VARCHAR(20),
    @ReportadoPor VARCHAR(100) -- Quién reporta (Ej: Nombre de propietario o portero)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @NuevaIncidenciaID INT;

        -- 1. Insertar la nueva incidencia
        INSERT INTO Incidencias (ComunidadID, UnidadID, FechaReporte, Descripcion, Estado, Prioridad, ResponsableSeguimiento)
        VALUES (@ComunidadID, @UnidadID, GETDATE(), @Descripcion, 'Reportada', @Prioridad, 'Administrador de Fincas');

        SET @NuevaIncidenciaID = SCOPE_IDENTITY();

        -- 2. Registrar el primer seguimiento (la creación)
        INSERT INTO SeguimientoIncidencias (IncidenciaID, FechaActualizacion, Detalle, UsuarioActualiza)
        VALUES (@NuevaIncidenciaID, GETDATE(), 'Incidencia reportada por ' + @ReportadoPor + '. Se ha clasificado como ' + @Prioridad + '.', @ReportadoPor);

        COMMIT TRANSACTION;
        SELECT @NuevaIncidenciaID AS IncidenciaID, 'Incidencia registrada exitosamente.' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
        RETURN;
    END CATCH
END;
GO
-- Registrar una avería de alta prioridad en la Comunidad 1
EXEC SP_RegistrarIncidencia 
    @ComunidadID = 1,
    @UnidadID = NULL, -- Afecta a zonas comunes
    @Descripcion = 'Fallo en la bomba de presión del agua. Baja presión en todo el edificio.',
    @Prioridad = 'Alta',
    @ReportadoPor = 'Laura García Pérez';
GO