CREATE VIEW VW_SaldoContableMensual
AS
SELECT
    C.Nombre AS Comunidad,
    YEAR(M.FechaMovimiento) AS Anio,
    MONTH(M.FechaMovimiento) AS Mes,
    SUM(CASE WHEN M.TipoMovimiento = 'Ingreso' THEN M.Monto ELSE 0 END) AS TotalIngresos,
    SUM(CASE WHEN M.TipoMovimiento = 'Gasto' THEN M.Monto ELSE 0 END) AS TotalGastos,
    SUM(CASE WHEN M.TipoMovimiento = 'Ingreso' THEN M.Monto ELSE -M.Monto END) AS SaldoMensual
FROM
    Comunidades C
JOIN
    Movimientos M ON C.ComunidadID = M.ComunidadID
GROUP BY
    C.Nombre,
    YEAR(M.FechaMovimiento),
    MONTH(M.FechaMovimiento);