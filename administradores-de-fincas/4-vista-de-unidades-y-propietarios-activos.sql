CREATE VIEW VW_UnidadesPropietariosActuales
AS
SELECT
    C.Nombre AS Comunidad,
    U.Numero AS Unidad,
    U.CoeficienteParticipacion AS Coeficiente,
    P.NIF_NIE AS PropietarioNIF,
    P.NombreCompleto AS PropietarioNombre,
    P.Telefono AS PropietarioTelefono,
    P.Email AS PropietarioEmail,
    PU.FechaInicioPropiedad
FROM
    Comunidades C
JOIN
    Unidades U ON C.ComunidadID = U.ComunidadID
JOIN
    PropiedadUnidad PU ON U.UnidadID = PU.UnidadID
JOIN
    Propietarios P ON PU.PropietarioID = P.PropietarioID
WHERE
    PU.FechaFinPropiedad IS NULL;