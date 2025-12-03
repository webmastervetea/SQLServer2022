CREATE FUNCTION FN_CalcularSaldoPropietario
(
    @ComunidadID INT,
    @UnidadID INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @SaldoPendiente DECIMAL(10, 2);

    SELECT 
        @SaldoPendiente = ISNULL(SUM(MontoCuota), 0)
    FROM 
        CuotasDerramas
    WHERE 
        ComunidadID = @ComunidadID
        AND UnidadID = @UnidadID
        AND EstadoPago = 'Pendiente';

    RETURN @SaldoPendiente;
END;
GO
-- Consultar el saldo pendiente de la Unidad 1 en la Comunidad 1
SELECT dbo.FN_CalcularSaldoPropietario(1, 1) AS DeudaTotalUnidad;