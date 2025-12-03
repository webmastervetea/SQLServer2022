CREATE TRIGGER TR_ControlCoeficienteParticipacion
ON Unidades
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declaramos una tabla para almacenar las comunidades afectadas por la operación
    DECLARE @ComunidadesAfectadas TABLE (ComunidadID INT);

    IF EXISTS (SELECT * FROM inserted)
        INSERT INTO @ComunidadesAfectadas SELECT ComunidadID FROM inserted;
    
    IF EXISTS (SELECT * FROM deleted)
        INSERT INTO @ComunidadesAfectadas SELECT ComunidadID FROM deleted;

    -- Iterar sobre cada comunidad afectada y verificar la suma
    IF EXISTS (
        SELECT 
            C.ComunidadID
        FROM 
            Comunidades C
        JOIN 
            @ComunidadesAfectadas CA ON C.ComunidadID = CA.ComunidadID
        LEFT JOIN (
            SELECT ComunidadID, SUM(CoeficienteParticipacion) AS SumaCoeficiente
            FROM Unidades
            GROUP BY ComunidadID
        ) AS Totales ON C.ComunidadID = Totales.ComunidadID
        WHERE Totales.SumaCoeficiente <> 100.00
    )
    BEGIN
        -- Si la suma no es 100, revertir la operación
        RAISERROR('Error de Integridad: La suma de los Coeficientes de Participación de una comunidad debe ser exactamente 100.00.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
