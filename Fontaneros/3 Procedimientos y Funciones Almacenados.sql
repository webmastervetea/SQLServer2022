USE Fontaneria;
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE SP_AgendarNuevaCita
    @ClienteID INT,
    @ServicioID INT,
    @EmpleadoID INT,
    @FechaHoraInicio DATETIME,
    @FechaHoraFin DATETIME,
    @DireccionServicio VARCHAR(200),
    @Comentarios TEXT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validación básica de fechas
    IF @FechaHoraInicio >= @FechaHoraFin
    BEGIN
        RAISERROR('La fecha/hora de inicio debe ser anterior a la fecha/hora de fin.', 16, 1);
        RETURN;
    END

    -- Insertar la nueva cita con estado 'Pendiente' por defecto
    INSERT INTO dbo.Citas (ClienteID, ServicioID, EmpleadoID, FechaHoraInicio, FechaHoraFin, DireccionServicio, EstadoCita, Comentarios)
    VALUES (@ClienteID, @ServicioID, @EmpleadoID, @FechaHoraInicio, @FechaHoraFin, @DireccionServicio, 'Pendiente', @Comentarios);

    SELECT CitaID, 'Cita agendada con éxito.' AS Mensaje FROM dbo.Citas WHERE CitaID = SCOPE_IDENTITY();
END

GO
CREATE TYPE TipoMaterialConsumido AS TABLE (
    ArticuloID INT,
    CantidadConsumida INT
);
GO

CREATE PROCEDURE SP_FinalizarServicioYGenerarParte
    @CitaID INT,
    @FechaHoraLlegada DATETIME,
    @FechaHoraSalida DATETIME,
    @Diagnostico TEXT,
    @SolucionAplicada TEXT,
    @HorasTrabajadas DECIMAL(4, 2),
    @Materiales TipoMaterialConsumido READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ParteID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Crear el Parte de Trabajo
        INSERT INTO dbo.PartesDeTrabajo (CitaID, FechaHoraLlegada, FechaHoraSalida, Diagnostico, SolucionAplicada, EstadoFinal, HorasTrabajadas)
        VALUES (@CitaID, @FechaHoraLlegada, @FechaHoraSalida, @Diagnostico, @SolucionAplicada, 'Resuelto', @HorasTrabajadas);

        SET @ParteID = SCOPE_IDENTITY();

        -- 2. Registrar el material consumido y actualizar stock
        IF EXISTS (SELECT 1 FROM @Materiales)
        BEGIN
            -- Insertar líneas en MaterialParteTrabajo
            INSERT INTO dbo.MaterialParteTrabajo (ParteID, ArticuloID, CantidadConsumida)
            SELECT @ParteID, ArticuloID, CantidadConsumida FROM @Materiales;

            -- Descontar el stock de Articulos
            UPDATE A
            SET A.StockActual = A.StockActual - M.CantidadConsumida
            FROM dbo.Articulos AS A
            INNER JOIN @Materiales AS M ON A.ArticuloID = M.ArticuloID;
        END

        -- 3. Actualizar estado de la Cita
        UPDATE dbo.Citas
        SET EstadoCita = 'Completada',
            Comentarios = @Diagnostico + ' / ' + @SolucionAplicada -- Concatenar el resumen
        WHERE CitaID = @CitaID;

        COMMIT TRANSACTION;
        SELECT @ParteID AS ParteID, 'Parte de Trabajo generado y Cita completada con éxito.' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW; -- Re-lanzar el error para que la aplicación lo gestione
    END CATCH
END
GO

CREATE PROCEDURE SP_ProcesarRecepcionCompra
    @CompraID INT,
    @Detalles TipoMaterialConsumido READONLY -- Reutilizamos el mismo tipo de tabla para la estructura Articulo/Cantidad
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Insertar los detalles de la compra (Articulos recibidos)
        INSERT INTO dbo.DetallesCompra (CompraID, ArticuloID, Cantidad, PrecioUnitarioCompra)
        SELECT
            @CompraID,
            M.ArticuloID,
            M.CantidadConsumida,
            (SELECT PrecioBase.PrecioUnitarioCompra FROM dbo.DetallesCompra PrecioBase WHERE PrecioBase.ArticuloID = M.ArticuloID AND PrecioBase.CompraID != @CompraID) -- Usar precio de compra anterior como ejemplo, esto debería venir del formulario de compra real.
        FROM @Detalles AS M;

        -- 2. Actualizar el Stock Actual de los Artículos (Añadir)
        UPDATE A
        SET A.StockActual = A.StockActual + D.CantidadConsumida
        FROM dbo.Articulos AS A
        INNER JOIN @Detalles AS D ON A.ArticuloID = D.ArticuloID;

        COMMIT TRANSACTION;
        SELECT @CompraID AS CompraID, 'Stock actualizado y detalles de compra registrados con éxito.' AS Mensaje;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE FUNCTION FN_CalcularDisponibilidadDiaria
(
    @EmpleadoID INT,
    @FechaHoraConsulta DATETIME
)
RETURNS BIT
AS
BEGIN
    DECLARE @Disponibilidad BIT = 0;
    DECLARE @DiaSemana INT;
    DECLARE @Hora TIME;

    SET @DiaSemana = DATEPART(dw, @FechaHoraConsulta); -- SQL Server: 1=Domingo, 2=Lunes, etc.
    SET @Hora = CAST(@FechaHoraConsulta AS TIME);

    -- Ajuste para hacer Lunes=1, Martes=2, etc., si la configuración regional lo requiere (Asumo 1=Lunes para los datos ingresados)
    -- Si tu entorno usa 1=Domingo, se ajusta el resultado para el chequeo de HorariosLaborales
    IF @DiaSemana = 1 SET @DiaSemana = 7; -- Si es Domingo (1), lo mapeamos a 7
    ELSE SET @DiaSemana = @DiaSemana - 1; -- Si es Lun(2), Mar(3), etc., los mapeamos a 1, 2, etc.

    -- 1. Verificar Ausencias
    IF EXISTS (
        SELECT 1
        FROM dbo.Ausencias
        WHERE EmpleadoID = @EmpleadoID
          AND @FechaHoraConsulta >= FechaInicio
          AND @FechaHoraConsulta < DATEADD(DAY, 1, FechaFin) -- Incluye el día de fin
    )
    BEGIN
        SET @Disponibilidad = 0; -- Ausente por vacaciones/baja
    END
    ELSE
    BEGIN
        -- 2. Verificar Horario Laboral y la hora actual
        IF EXISTS (
            SELECT 1
            FROM dbo.HorariosLaborales
            WHERE EmpleadoID = @EmpleadoID
              AND DiaSemana = @DiaSemana
              AND @Hora >= HoraEntrada
              AND @Hora <= HoraSalida
        )
        BEGIN
            -- 3. Verificar Citas Agendadas que se superpongan (excluyendo Canceladas)
            IF NOT EXISTS (
                SELECT 1
                FROM dbo.Citas
                WHERE EmpleadoID = @EmpleadoID
                  AND EstadoCita NOT IN ('Completada', 'Cancelada')
                  AND @FechaHoraConsulta >= FechaHoraInicio
                  AND @FechaHoraConsulta < FechaHoraFin -- La hora de fin de una cita no bloquea la hora de inicio de la siguiente
            )
            BEGIN
                SET @Disponibilidad = 1; -- Disponible: No ausente, en horario, y sin cita superpuesta
            END
        END
    END

    RETURN @Disponibilidad;
END
GO

CREATE FUNCTION FN_ObtenerTotalArticulosFactura
(
    @FacturaID INT
)
RETURNS @TotalArticulos TABLE
(
    ArticuloID INT,
    NombreArticulo VARCHAR(100),
    CantidadTotal DECIMAL(10, 2),
    SubtotalArticulos DECIMAL(10, 2)
)
AS
BEGIN
    INSERT INTO @TotalArticulos (ArticuloID, NombreArticulo, CantidadTotal, SubtotalArticulos)
    SELECT
        A.ArticuloID,
        A.Nombre,
        SUM(LF.Cantidad) AS CantidadTotal,
        SUM(LF.Subtotal) AS SubtotalArticulos
    FROM
        dbo.LineasFactura AS LF
    INNER JOIN
        dbo.Articulos AS A ON LF.ArticuloID = A.ArticuloID
    WHERE
        LF.FacturaID = @FacturaID
        AND LF.ArticuloID IS NOT NULL -- Solo consideramos líneas que son artículos
    GROUP BY
        A.ArticuloID, A.Nombre;

    RETURN;
END
GO
-- Ejemplo de uso de la función de disponibilidad:
-- Verifica si el EmpleadoID 1 está disponible el 2025-11-26 a las 16:00
SELECT dbo.FN_CalcularDisponibilidadDiaria(1, '2025-11-26 16:00:00') AS EstaDisponible;

-- Puedes usarla en una consulta para encontrar el primer fontanero disponible:
SELECT TOP 1
    E.EmpleadoID,
    E.Nombre + ' ' + E.Apellido1 AS Fontanero,
    dbo.FN_CalcularDisponibilidadDiaria(E.EmpleadoID, '2025-11-26 16:00:00') AS Disponibilidad
FROM
    dbo.Empleados AS E
WHERE
    E.Cargo LIKE '%Fontanero%'
    AND dbo.FN_CalcularDisponibilidadDiaria(E.EmpleadoID, '2025-11-26 16:00:00') = 1;
GO


CREATE PROCEDURE SP_GenerarFacturaDesdeCita
    @CitaID INT,
    @EmpleadoContableID INT, -- ID del empleado que emite la factura (e.g., Contable o Gerente)
    @PorcentajeIVA DECIMAL(4, 2) = 0.21 -- Tasa de IVA por defecto (21%)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ClienteID INT;
    DECLARE @ServicioID INT;
    DECLARE @ParteID INT;
    DECLARE @HorasTrabajadas DECIMAL(4, 2);
    DECLARE @PrecioBaseServicio DECIMAL(10, 2);
    DECLARE @CostoHoraManoObra DECIMAL(10, 2); -- Precio del servicio 'Mano de Obra'
    
    DECLARE @FacturaID INT;
    DECLARE @TotalNeto DECIMAL(10, 2) = 0;
    DECLARE @TotalIVA DECIMAL(10, 2);
    DECLARE @TotalFactura DECIMAL(10, 2);
    
    -- ID fijo para el servicio de Mano de Obra (asumiendo que se definió un ID específico, e.g., 404)
    DECLARE @ServicioManoObraID INT = 404;
    
    -- ************************************************************
    -- 1. VALIDACIÓN Y OBTENCIÓN DE DATOS CLAVE
    -- ************************************************************
    
    -- Obtener datos de la Cita
    SELECT 
        @ClienteID = C.ClienteID, 
        @ServicioID = C.ServicioID
    FROM dbo.Citas AS C
    WHERE C.CitaID = @CitaID AND C.EstadoCita = 'Completada' AND C.FacturaID IS NULL;

    IF @ClienteID IS NULL
    BEGIN
        RAISERROR('La Cita no existe, no está completada, o ya ha sido facturada.', 16, 1);
        RETURN;
    END

    -- Obtener datos del Parte de Trabajo
    SELECT 
        @ParteID = P.ParteID, 
        @HorasTrabajadas = P.HorasTrabajadas
    FROM dbo.PartesDeTrabajo AS P
    WHERE P.CitaID = @CitaID;

    IF @ParteID IS NULL
    BEGIN
        RAISERROR('No se encontró un Parte de Trabajo asociado a la cita completada. No se puede facturar.', 16, 1);
        RETURN;
    END

    -- Obtener Precios Base
    SELECT @PrecioBaseServicio = PrecioBase FROM dbo.Servicios WHERE ServicioID = @ServicioID;
    SELECT @CostoHoraManoObra = PrecioBase FROM dbo.Servicios WHERE ServicioID = @ServicioManoObraID;
    
    IF @CostoHoraManoObra IS NULL OR @CostoHoraManoObra = 0
    BEGIN
        RAISERROR('No se encontró el precio base para el Servicio de Mano de Obra (ID %d).', 16, 1, @ServicioManoObraID);
        RETURN;
    END
    
    -- ************************************************************
    -- 2. CÁLCULO DE TOTALES (NETO)
    -- ************************************************************
    
    -- Inicializar con el servicio base de la cita
    SET @TotalNeto = @TotalNeto + @PrecioBaseServicio;
    
    -- Sumar la Mano de Obra (horas trabajadas * costo por hora)
    SET @TotalNeto = @TotalNeto + (@HorasTrabajadas * @CostoHoraManoObra);
    
    -- Sumar el material consumido (Cantidad * PrecioVenta de Articulos)
    SELECT @TotalNeto = @TotalNeto + ISNULL(SUM(MT.CantidadConsumida * A.PrecioVenta), 0)
    FROM dbo.MaterialParteTrabajo AS MT
    INNER JOIN dbo.Articulos AS A ON MT.ArticuloID = A.ArticuloID
    WHERE MT.ParteID = @ParteID;

    -- Calcular IVA y Total Final
    SET @TotalIVA = @TotalNeto * @PorcentajeIVA;
    SET @TotalFactura = @TotalNeto + @TotalIVA;
    
    
    -- ************************************************************
    -- 3. INSERCIÓN DE FACTURA Y LÍNEAS
    -- ************************************************************

    BEGIN TRANSACTION;
    
    -- 3.1. Insertar en Facturas
    INSERT INTO dbo.Facturas (NumeroFactura, ClienteID, FechaEmision, FechaVencimiento, TotalNeto, IVA, TotalFactura, EstadoFactura, EmpleadoID)
    VALUES (
        'F' + FORMAT(YEAR(GETDATE()), '0000') + '-' + FORMAT(NEXT VALUE FOR sys.sequences.SQ_NumeroFactura, '0000'), -- Genera un número de factura (asumiendo secuencia o lógica de negocio)
        @ClienteID,
        GETDATE(), -- Fecha de emisión
        DATEADD(day, 30, GETDATE()), -- Vencimiento a 30 días
        @TotalNeto,
        @TotalIVA,
        @TotalFactura,
        'Pendiente', -- Estado inicial
        @EmpleadoContableID
    );
    
    SET @FacturaID = SCOPE_IDENTITY();

    -- 3.2. Insertar LíneasFactura: Servicio Base
    INSERT INTO dbo.LineasFactura (FacturaID, DescripcionServicio, Cantidad, PrecioUnitario, Subtotal)
    SELECT @FacturaID, NombreServicio, 1.00, PrecioBase, PrecioBase
    FROM dbo.Servicios WHERE ServicioID = @ServicioID;

    -- 3.3. Insertar LíneasFactura: Mano de Obra
    INSERT INTO dbo.LineasFactura (FacturaID, DescripcionServicio, Cantidad, PrecioUnitario, Subtotal)
    SELECT @FacturaID, 'Mano de Obra (' + S.NombreServicio + ')', @HorasTrabajadas, S.PrecioBase, (@HorasTrabajadas * S.PrecioBase)
    FROM dbo.Servicios AS S WHERE S.ServicioID = @ServicioManoObraID;

    -- 3.4. Insertar LíneasFactura: Materiales Consumidos
    INSERT INTO dbo.LineasFactura (FacturaID, ArticuloID, Cantidad, PrecioUnitario, Subtotal)
    SELECT
        @FacturaID,
        MT.ArticuloID,
        CAST(MT.CantidadConsumida AS DECIMAL(10, 2)),
        A.PrecioVenta,
        MT.CantidadConsumida * A.PrecioVenta
    FROM dbo.MaterialParteTrabajo AS MT
    INNER JOIN dbo.Articulos AS A ON MT.ArticuloID = A.ArticuloID
    WHERE MT.ParteID = @ParteID;
    
    -- 3.5. Actualizar la Cita con el FacturaID
    UPDATE dbo.Citas
    SET FacturaID = @FacturaID
    WHERE CitaID = @CitaID;

    COMMIT TRANSACTION;
    
    SELECT @FacturaID AS FacturaIDGenerada, 'Factura creada y asociada a la Cita con éxito.' AS Mensaje;
    
END
GO
