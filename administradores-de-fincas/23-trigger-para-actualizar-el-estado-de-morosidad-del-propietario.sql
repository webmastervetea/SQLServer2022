CREATE TRIGGER TR_ActualizarEstadoCuotaPorDetalleRemesa
ON DetalleRemesa
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Si se inserta un registro en DetalleRemesa con EstadoRecibo='Cobrado', 
    -- actualizamos la cuota original a 'Pagado'.
    UPDATE CD
    SET CD.EstadoPago = 'Pagado',
        CD.FechaPago = GETDATE()
    FROM CuotasDerramas CD
    JOIN inserted i ON CD.CuotaDerramaID = i.CuotaDerramaID
    WHERE i.EstadoRecibo = 'Cobrado' AND CD.EstadoPago = 'Pendiente';

    -- Si el estado es 'Devuelto', podríamos revertir el estado o marcarlo como tal (requiere más lógica)
    -- Ejemplo:
    /*
    UPDATE CD
    SET CD.EstadoPago = 'Devuelto'
    FROM CuotasDerramas CD
    JOIN inserted i ON CD.CuotaDerramaID = i.CuotaDerramaID
    WHERE i.EstadoRecibo = 'Devuelto';
    */
END;
GO