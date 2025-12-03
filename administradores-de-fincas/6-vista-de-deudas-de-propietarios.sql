CREATE VIEW VW_DeudaPropietarios
AS
SELECT
    C.Nombre AS Comunidad,
    VUPA.Unidad,
    VUPA.PropietarioNombre,
    COUNT(CD.CuotaDerramaID) AS CuotasPendientes,
    SUM(CD.MontoCuota) AS DeudaTotal
FROM
    CuotasDerramas CD
JOIN
    Unidades U ON CD.UnidadID = U.UnidadID
JOIN
    Comunidades C ON U.ComunidadID = C.ComunidadID
JOIN
    VW_UnidadesPropietariosActuales VUPA ON U.UnidadID = VUPA.UnidadID -- Uso de la Vista 1
WHERE
    CD.EstadoPago = 'Pendiente'
GROUP BY
    C.Nombre,
    VUPA.Unidad,
    VUPA.PropietarioNombre
HAVING
    SUM(CD.MontoCuota) > 0;