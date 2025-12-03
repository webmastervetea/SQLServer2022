CREATE TABLE DetalleRemesa (
    DetalleRemesaID INT PRIMARY KEY IDENTITY(1,1),
    RemesaID INT NOT NULL,
    CuotaDerramaID INT UNIQUE NOT NULL, -- Cada cuota solo puede estar en una remesa a la vez
    MontoCobrado DECIMAL(10, 2) NOT NULL,
    EstadoRecibo VARCHAR(50), -- Ej: 'Pendiente Cargo', 'Devuelto', 'Cobrado'
    FOREIGN KEY (RemesaID) REFERENCES RemesasSEPA(RemesaID),
    FOREIGN KEY (CuotaDerramaID) REFERENCES CuotasDerramas(CuotaDerramaID)
);
GO
CREATE PROCEDURE SP_CrearRemesaCuotas
    @ComunidadID INT,
    @MesCuota DATE,
    @FechaCargo DATE,
    @Concepto VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que existan cuotas pendientes para ese mes
    IF NOT EXISTS (
        SELECT 1 FROM CuotasDerramas CD
        JOIN Unidades U ON CD.UnidadID = U.UnidadID
        JOIN PropiedadUnidad PU ON U.UnidadID = PU.UnidadID
        JOIN Propietarios P ON PU.PropietarioID = P.PropietarioID
        WHERE CD.ComunidadID = @ComunidadID 
        AND CD.Mes = @MesCuota 
        AND CD.EstadoPago = 'Pendiente'
        AND P.IBAN IS NOT NULL -- Solo los que tienen IBAN
        AND PU.FechaFinPropiedad IS NULL -- Solo propietarios actuales
    )
    BEGIN
        RAISERROR('No se encontraron cuotas pendientes con IBAN para la comunidad y mes especificados.', 10, 1)
        RETURN
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @NuevaRemesaID INT;
        DECLARE @TotalMonto DECIMAL(10, 2);
        DECLARE @TotalRecibos INT;

        -- 1. Calcular totales para la cabecera
        SELECT 
            @TotalRecibos = COUNT(CD.CuotaDerramaID),
            @TotalMonto = SUM(CD.MontoCuota)
        FROM CuotasDerramas CD
        JOIN Unidades U ON CD.UnidadID = U.UnidadID
        JOIN PropiedadUnidad PU ON U.UnidadID = PU.UnidadID
        JOIN Propietarios P ON PU.PropietarioID = P.PropietarioID
        WHERE CD.ComunidadID = @ComunidadID 
        AND CD.Mes = @MesCuota 
        AND CD.EstadoPago = 'Pendiente'
        AND P.IBAN IS NOT NULL
        AND PU.FechaFinPropiedad IS NULL;

        -- 2. Insertar la Cabecera de la Remesa
        INSERT INTO RemesasSEPA (ComunidadID, FechaCreacion, FechaCargoPrevista, ConceptoRemesa, TotalRecibos, MontoTotal, EstadoRemesa)
        VALUES (@ComunidadID, GETDATE(), @FechaCargo, @Concepto, @TotalRecibos, @TotalMonto, 'Creada');

        SET @NuevaRemesaID = SCOPE_IDENTITY();

        -- 3. Insertar el Detalle de la Remesa (enlazando las Cuotas)
        INSERT INTO DetalleRemesa (RemesaID, CuotaDerramaID, MontoCobrado, EstadoRecibo)
        SELECT 
            @NuevaRemesaID, 
            CD.CuotaDerramaID, 
            CD.MontoCuota, 
            'Pendiente Cargo'
        FROM CuotasDerramas CD
        JOIN Unidades U ON CD.UnidadID = U.UnidadID
        JOIN PropiedadUnidad PU ON U.UnidadID = PU.UnidadID
        JOIN Propietarios P ON PU.PropietarioID = P.PropietarioID
        WHERE CD.ComunidadID = @ComunidadID 
        AND CD.Mes = @MesCuota 
        AND CD.EstadoPago = 'Pendiente'
        AND P.IBAN IS NOT NULL
        AND PU.FechaFinPropiedad IS NULL;

        COMMIT TRANSACTION;
        SELECT @NuevaRemesaID AS RemesaID, 'Remesa SEPA creada exitosamente con ' + CAST(@TotalRecibos AS VARCHAR) + ' recibos.' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
        RETURN;
    END CATCH
END;
GO
