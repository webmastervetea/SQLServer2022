CREATE PROCEDURE SP_RegistrarPagoCuota
    @CuotaDerramaID INT,
    @FechaPago DATE
AS
BEGIN
    -- 1. Validar si la cuota existe
    IF NOT EXISTS (SELECT 1 FROM CuotasDerramas WHERE CuotaDerramaID = @CuotaDerramaID)
    BEGIN
        -- Usar RAISERROR para notificar el error
        RAISERROR('Error: La CuotaDerramaID %d no existe.', 16, 1, @CuotaDerramaID)
        RETURN
    END

    -- 2. Validar que la cuota no haya sido pagada previamente
    IF EXISTS (SELECT 1 FROM CuotasDerramas WHERE CuotaDerramaID = @CuotaDerramaID AND EstadoPago = 'Pagado')
    BEGIN
        RAISERROR('Advertencia: La cuota con ID %d ya se encuentra en estado "Pagado". No se realizó ninguna actualización.', 10, 1, @CuotaDerramaID)
        RETURN
    END

    -- Iniciar la transacción para asegurar que la actualización se complete
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 3. Actualizar el estado y la fecha de pago de la cuota
        UPDATE CuotasDerramas
        SET 
            EstadoPago = 'Pagado',
            FechaPago = @FechaPago
        WHERE 
            CuotaDerramaID = @CuotaDerramaID;

        -- 4. Confirmar la transacción
        COMMIT TRANSACTION;
        PRINT 'Pago de cuota registrado exitosamente para CuotaDerramaID: ' + CAST(@CuotaDerramaID AS VARCHAR);

    END TRY
    BEGIN CATCH
        -- Si algo sale mal, revertir los cambios
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Lanzar el error de SQL Server
        THROW;
        RETURN;
    END CATCH
END;
GO