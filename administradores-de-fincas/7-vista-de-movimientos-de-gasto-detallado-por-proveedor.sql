CREATE VIEW VW_GastosPorProveedor
AS
SELECT
    C.Nombre AS Comunidad,
    P.RazonSocial AS Proveedor,
    CC.Descripcion AS CuentaContable,
    M.FechaMovimiento,
    M.Concepto,
    M.Monto AS ImporteGasto,
    M.NumeroFactura
FROM
    Movimientos M
JOIN
    Comunidades C ON M.ComunidadID = C.ComunidadID
JOIN
    Proveedores P ON M.ProveedorID = P.ProveedorID
JOIN
    Cuentas CC ON M.CuentaContableID = CC.CuentaID
WHERE
    M.TipoMovimiento = 'Gasto';