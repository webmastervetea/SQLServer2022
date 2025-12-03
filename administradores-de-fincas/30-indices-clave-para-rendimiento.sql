-- Optimización de búsquedas y JOINS frecuentes

-- En Movimientos: Búsqueda frecuente por comunidad y fecha para reportes contables
CREATE NONCLUSTERED INDEX IX_Movimientos_ComunidadFecha 
ON Movimientos (ComunidadID, FechaMovimiento);

-- En CuotasDerramas: Búsqueda frecuente para morosidad
CREATE NONCLUSTERED INDEX IX_CuotasDerramas_EstadoUnidad 
ON CuotasDerramas (ComunidadID, EstadoPago, UnidadID);

-- En Propietarios: Búsqueda rápida por nombre (además del índice en NIF_NIE que es UNIQUE)
CREATE NONCLUSTERED INDEX IX_Propietarios_Nombre 
ON Propietarios (NombreCompleto);

-- En Unidades: Búsqueda por comunidad
CREATE NONCLUSTERED INDEX IX_Unidades_Comunidad 
ON Unidades (ComunidadID);
GO