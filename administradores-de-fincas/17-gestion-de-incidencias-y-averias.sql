CREATE PROCEDURE SP_GenerarEstadoIngresosGastos
    @ComunidadID INT,
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Usamos una tabla temporal para la estructura del reporte
    CREATE TABLE #ReporteContable (
        TipoRegistro VARCHAR(20), -- 'Ingreso' o 'Gasto'
        CodigoCuenta VARCHAR(10),
        DescripcionCuenta VARCHAR(100),
        MontoTotal DECIMAL(10, 2)
    );

    -- 1. Insertar todos los Movimientos (Ingresos y Gastos) agrupados por Cuenta
    INSERT INTO #ReporteContable (TipoRegistro, CodigoCuenta, DescripcionCuenta, MontoTotal)
    SELECT
        M.TipoMovimiento AS TipoRegistro,
        CC.CodigoCuenta,
        CC.Descripcion AS DescripcionCuenta,
        SUM(M.Monto) AS MontoTotal
    FROM
        Movimientos M
    JOIN
        Cuentas CC ON M.CuentaContableID = CC.CuentaID
    WHERE
        M.ComunidadID = @ComunidadID
        AND M.FechaMovimiento >= @FechaInicio
        AND M.FechaMovimiento <= @FechaFin
    GROUP BY
        M.TipoMovimiento, CC.CodigoCuenta, CC.Descripcion
    ORDER BY
        M.TipoMovimiento DESC, CC.CodigoCuenta;

    -- 2. Mostrar el reporte detallado
    SELECT
        TipoRegistro,
        CodigoCuenta,
        DescripcionCuenta,
        MontoTotal
    FROM
        #ReporteContable
    ORDER BY TipoRegistro DESC, CodigoCuenta;
    
    -- 3. Calcular y mostrar el Total y el Saldo (Resumen)
    SELECT
        'Total Ingresos' AS Concepto,
        SUM(CASE WHEN TipoRegistro = 'Ingreso' THEN MontoTotal ELSE 0 END) AS Valor
    FROM #ReporteContable
    UNION ALL
    SELECT
        'Total Gastos' AS Concepto,
        SUM(CASE WHEN TipoRegistro = 'Gasto' THEN MontoTotal ELSE 0 END) AS Valor
    FROM #ReporteContable
    UNION ALL
    SELECT
        'SALDO EJERCICIO' AS Concepto,
        SUM(CASE WHEN TipoRegistro = 'Ingreso' THEN MontoTotal ELSE -MontoTotal END) AS Valor
    FROM #ReporteContable;

    DROP TABLE #ReporteContable;
END;
GO