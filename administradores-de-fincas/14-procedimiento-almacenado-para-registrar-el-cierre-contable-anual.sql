CREATE PROCEDURE SP_CierreContableAnual
    @ComunidadID INT,
    @AnioCerrar INT
AS
BEGIN
    -- Declaramos variables para el cálculo
    DECLARE @TotalIngresos DECIMAL(10, 2);
    DECLARE @TotalGastos DECIMAL(10, 2);
    DECLARE @ResultadoEjercicio DECIMAL(10, 2);
    
    -- Declaramos variables para las cuentas de destino
    DECLARE @CuentaCierreID INT;
    -- Asumir que existe una cuenta contable para "Remanente" o "Resultado del Ejercicio" (ej. CodigoCuenta '555')

    -- 1. Verificar si la cuenta de cierre existe (ej: CodigoCuenta '555' para Remanente)
    SELECT @CuentaCierreID = CuentaID
    FROM Cuentas 
    WHERE ComunidadID = @ComunidadID AND CodigoCuenta = '555'; -- Usar el código de tu Plan de Cuentas

    IF @CuentaCierreID IS NULL
    BEGIN
        RAISERROR('Error: La cuenta contable de Cierre (código 555) no está configurada para esta comunidad.', 16, 1)
        RETURN
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 2. Calcular los totales de ingresos y gastos para el año
        SELECT 
            @TotalIngresos = ISNULL(SUM(CASE WHEN TipoMovimiento = 'Ingreso' THEN Monto ELSE 0 END), 0),
            @TotalGastos = ISNULL(SUM(CASE WHEN TipoMovimiento = 'Gasto' THEN Monto ELSE 0 END), 0)
        FROM 
            Movimientos
        WHERE 
            ComunidadID = @ComunidadID
            AND YEAR(FechaMovimiento) = @AnioCerrar;

        SET @ResultadoEjercicio = @TotalIngresos - @TotalGastos;

        -- 3. Registrar el movimiento de cierre (traspaso del resultado a la cuenta de remanente)
        INSERT INTO Movimientos (
            ComunidadID, 
            FechaMovimiento, 
            TipoMovimiento, 
            Concepto, 
            Monto, 
            CuentaContableID, 
            ProveedorID, 
            NumeroFactura
        )
        VALUES (
            @ComunidadID,
            DATEFROMPARTS(@AnioCerrar, 12, 31), -- Fecha de cierre
            CASE WHEN @ResultadoEjercicio >= 0 THEN 'Ingreso' ELSE 'Gasto' END,
            'Cierre Contable Ejercicio ' + CAST(@AnioCerrar AS VARCHAR),
            ABS(@ResultadoEjercicio), -- Siempre positivo en el registro
            @CuentaCierreID,
            NULL, 
            NULL
        );
        
        -- 4. Confirmar la transacción
        COMMIT TRANSACTION;
        PRINT 'Cierre contable del año ' + CAST(@AnioCerrar AS VARCHAR) + ' registrado. Resultado: ' + CAST(@ResultadoEjercicio AS VARCHAR);

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
        RETURN;
    END CATCH
END;
GO
-- Cerrar el ejercicio contable para la Comunidad 1 del año 2024
EXEC SP_CierreContableAnual 
    @ComunidadID = 1,
    @AnioCerrar = 2024;