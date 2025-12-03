CREATE VIEW VW_AcuerdosAprobados
AS
SELECT
    C.Nombre AS Comunidad,
    J.FechaJunta,
    J.TipoJunta,
    A.DescripcionAcuerdo,
    A.VotosFavor,
    A.VotosContra
FROM
    Acuerdos A
JOIN
    Juntas J ON A.JuntaID = J.JuntaID
JOIN
    Comunidades C ON J.ComunidadID = C.ComunidadID
WHERE
    A.AcuerdoAprobado = 1;