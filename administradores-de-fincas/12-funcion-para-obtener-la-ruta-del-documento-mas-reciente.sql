CREATE FUNCTION FN_ObtenerRutaDocumentoReciente
(
    @ComunidadID INT,
    @TipoDocumento VARCHAR(50) -- Ej: 'Póliza Seguro', 'Estatutos'
)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @Ruta VARCHAR(255);

    SELECT TOP 1
        @Ruta = RutaArchivo
    FROM
        Documentos
    WHERE
        ComunidadID = @ComunidadID
        AND TipoDocumento = @TipoDocumento
    ORDER BY
        FechaSubida DESC,
        DocumentoID DESC; -- En caso de misma fecha, usa el ID mayor

    -- Devolver la ruta del documento más reciente
    RETURN @Ruta;
END;
GO
-- Obtener la ruta del archivo de la Póliza de Seguro más reciente para la ComunidadID 1
SELECT dbo.FN_ObtenerRutaDocumentoReciente(1, 'Póliza Seguro') AS RutaArchivoPoliza;