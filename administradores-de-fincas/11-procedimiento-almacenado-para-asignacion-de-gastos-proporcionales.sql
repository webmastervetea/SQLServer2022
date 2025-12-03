CREATE PROCEDURE SP_AsignarGastoComunitario
    @ComunidadID INT,
    @MontoGastoTotal DECIMAL(10, 2),
    @Concepto VARCHAR(255),
    @MesDistribucion DATE -- Usamos DATE para el mes/año de la cuota
AS
BEGIN
    -- Validar si la comunidad existe
    IF NOT EXISTS (SELECT 1 FROM Comunidades WHERE ComunidadID = @ComunidadID)
    BEGIN
        RAISERROR('Error: La ComunidadID especificada no existe.', 16, 1)
        RETURN
    END

    -- 1. Insertar el gasto total como un movimiento contable (opcional, pero recomendable para el registro)
    -- Asumimos que existe una CuentaID para "Gastos Comunes" (debería definirse)
    DECLARE @CuentaGastosID INT;
    -- Aquí deberías obtener el ID de la cuenta contable de gastos correspondiente.
    -- Por ejemplo, si el gasto es por Limpieza, obtener el CuentaID de "Limpieza".
    -- Por simplicidad, asumiremos un ID fijo (ej. 4000) o que la CuentaID se pasa como parámetro.
    
    -- Si no se pasa como parámetro, se usaría un SELECT para encontrarla.
    -- SET @CuentaGastosID = (SELECT CuentaID FROM Cuentas WHERE ComunidadID = @ComunidadID AND Descripcion = 'Limpieza');

    -- Se inicia la transacción para la distribución
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 2. Declarar variables para el cursor
        DECLARE @UnidadID INT;
        DECLARE @Coeficiente DECIMAL(5, 2);
        DECLARE @MontoUnidad DECIMAL(10, 2);

        -- 3. Definir el cursor para iterar sobre todas las unidades de la comunidad
        DECLARE Unidades_Cursor CURSOR FOR
        SELECT 
            UnidadID, 
            CoeficienteParticipacion 
        FROM 
            Unidades 
        WHERE 
            ComunidadID = @ComunidadID;

        OPEN Unidades_Cursor;
        FETCH NEXT FROM Unidades_Cursor INTO @UnidadID, @Coeficiente;

        -- 4. Iterar y calcular el monto individual
        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Cálculo de la parte proporcional (Monto Total * Coeficiente / 100)
            SET @MontoUnidad = @MontoGastoTotal * (@Coeficiente / 100.00);

            -- Insertar la nueva cuota (derrama) individual
            INSERT INTO CuotasDerramas (
                ComunidadID, 
                UnidadID, 
                Mes, 
                MontoCuota, 
                EstadoPago, 
                FechaVencimiento
            )
            VALUES (
                @ComunidadID,
                @UnidadID,
                @MesDistribucion,
                @MontoUnidad,
                'Pendiente',
                DATEADD(day, 15, @MesDistribucion) -- Vence 15 días después del mes de distribución
            );

            FETCH NEXT FROM Unidades_Cursor INTO @UnidadID, @Coeficiente;
        END

        CLOSE Unidades_Cursor;
        DEALLOCATE Unidades_Cursor;

        -- 5. Confirmar la transacción
        COMMIT TRANSACTION;
        PRINT 'Gasto total de ' + CAST(@MontoGastoTotal AS VARCHAR) + ' distribuido exitosamente entre todas las unidades de la ComunidadID: ' + CAST(@ComunidadID AS VARCHAR);

    END TRY
    BEGIN CATCH
        -- En caso de error, revertir
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
        RETURN;
    END CATCH
END;
GO

-- Ejecutar el procedimiento para distribuir un gasto de 500.00 EUR en la ComunidadID 1
-- por un concepto de 'Reparación de ascensor' para la cuota de Noviembre de 2025.
EXEC SP_AsignarGastoComunitario
    @ComunidadID = 1,
    @MontoGastoTotal = 500.00,
    @Concepto = 'Reparación de ascensor',
    @MesDistribucion = '2025-11-01';