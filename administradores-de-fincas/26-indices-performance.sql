-- En Movimientos: Búsqueda frecuente por comunidad y fecha
CREATE NONCLUSTERED INDEX IX_Movimientos_ComunidadFecha 
ON Movimientos (ComunidadID, FechaMovimiento);

-- En CuotasDerramas: Búsqueda frecuente para morosidad
CREATE NONCLUSTERED INDEX IX_CuotasDerramas_EstadoUnidad 
ON CuotasDerramas (ComunidadID, EstadoPago, UnidadID);

-- En Propietarios: Búsqueda rápida por nombre o NIF (además de UNIQUE)
CREATE NONCLUSTERED INDEX IX_Propietarios_Nombre 
ON Propietarios (NombreCompleto);