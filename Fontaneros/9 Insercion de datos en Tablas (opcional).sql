USE Fontaneria;
GO

-- Desactivar temporalmente la comprobación de restricciones para simplificar la inserción de datos en orden
-- (Solo en un entorno de desarrollo/pruebas)
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"
GO

-- ************************************************************
-- 1. TABLAS BASE
-- ************************************************************

-- EMPLEADOS (IDs 1-4)
SET IDENTITY_INSERT Empleados ON;
INSERT INTO Empleados (EmpleadoID, NIF, Nombre, Apellido1, Apellido2, Telefono, Email, Direccion, Cargo, FechaContratacion, Activo) VALUES
(1, '11111111A', 'Juan', 'Pérez', 'Gómez', '600111222', 'juan.perez@fontaneria.com', 'C/ Fontanero Mayor, 5', 'Fontanero Senior', '2015-05-10', 1),
(2, '22222222B', 'María', 'López', 'Ruiz', '600333444', 'maria.lopez@fontaneria.com', 'Av. Tubería, 10', 'Fontanero Junior', '2022-08-15', 1),
(3, '33333333C', 'Carlos', 'Sanz', NULL, '600555666', 'carlos.sanz@fontaneria.com', 'Pza. Central, 2', 'Contable', '2018-01-20', 1),
(4, '44444444D', 'Elena', 'Gil', 'Martín', '600777888', 'elena.gil@fontaneria.com', 'Ronda del Agua, 1', 'Gerente', '2010-03-01', 1);
SET IDENTITY_INSERT Empleados OFF;
GO

-- CLIENTES (IDs 101-103)
SET IDENTITY_INSERT Clientes ON;
INSERT INTO Clientes (ClienteID, TipoCliente, NIF_CIF, NombreRazonSocial, NombreContacto, Telefono, Email, Direccion, CondicionesPago) VALUES
(101, 'P', '55555555E', 'Antonio García', NULL, '650101101', 'antonio.garcia@mail.com', 'C/ Fugas, 15, 3ºA, Distrito Centro', 'Transferencia'),
(102, 'E', 'B12345678', 'Inmobiliaria Sol S.L.', 'Laura Fernández', '918002000', 'sol.inmobiliaria@empresa.com', 'C/ Ladrillo, 8, Zona Norte', '30 días'),
(103, 'P', '66666666F', 'Beatriz Soto', NULL, '650202202', 'beatriz.soto@mail.com', 'Av. Chorros, 30, Distrito Centro', 'Contado');
SET IDENTITY_INSERT Clientes OFF;
GO

-- PROVEEDORES (IDs 201-202)
SET IDENTITY_INSERT Proveedores ON;
INSERT INTO Proveedores (ProveedorID, CIF, NombreComercial, NombreContacto, Telefono, Email, Direccion, CondicionesPago) VALUES
(201, 'A98765432', 'Distribuciones Hidro S.A.', 'Pedro Díaz', '900100100', 'info@hidro.com', 'Pol. Ind. La Válvula, 1', '60 días'),
(202, 'B87654321', 'Grifería Rápida SL', 'Ana Ruiz', '900200200', 'ventas@grifos.es', 'C/ Codo, 4', '30 días');
SET IDENTITY_INSERT Proveedores OFF;
GO

-- ARTICULOS (Inventario)
SET IDENTITY_INSERT Articulos ON;
INSERT INTO Articulos (ArticuloID, CodigoArticulo, Nombre, Descripcion, PrecioVenta, UnidadMedida, StockActual, StockMinimo) VALUES
(301, 'CODO-20MM', 'Codo PVC 20mm', 'Codo 90 grados PVC presión 20mm', 1.50, 'ud', 150, 50),
(302, 'GRIFO-LAV', 'Grifo Lavabo Monomando', 'Grifo monomando cromo para lavabo', 145.90, 'ud', 15, 10),
(303, 'JUNTA-TOR', 'Junta Tórica Estándar', 'Junta de goma 1/2 pulgada', 0.50, 'ud', 300, 100),
(304, 'TERMO-50L', 'Termo Eléctrico 50L', 'Termo eléctrico 50 litros vertical', 180.00, 'ud', 4, 5); -- BAJO STOCK: Activa Alerta
SET IDENTITY_INSERT Articulos OFF;
GO

-- SERVICIOS (Mano de Obra)
SET IDENTITY_INSERT Servicios ON;
INSERT INTO Servicios (ServicioID, NombreServicio, Descripcion, PrecioBase) VALUES
(401, 'Desatasco Sencillo', 'Desatasco de fregadero o inodoro con herramientas manuales.', 50.00),
(402, 'Reparación de Fuga', 'Localización y reparación de pequeña fuga visible (Tarifa base).', 75.00),
(403, 'Instalación de Termo', 'Instalación completa de termo eléctrico.', 120.00),
(404, 'Mano de Obra (Hora)', 'Tarifa de mano de obra por hora.', 40.00);
SET IDENTITY_INSERT Servicios OFF;
GO

-- ZONAS OPERACION
SET IDENTITY_INSERT ZonasOperacion ON;
INSERT INTO ZonasOperacion (ZonaID, NombreZona, CodigoPostalInicio, CodigoPostalFin) VALUES
(501, 'Distrito Centro', '28001', '28010'),
(502, 'Zona Norte', '28011', '28020');
SET IDENTITY_INSERT ZonasOperacion OFF;
GO

-- ************************************************************
-- 2. TRANSACCIONES Y HORARIOS
-- ************************************************************

-- COMPRAS Y DETALLESCOMPRA (Contable Carlos Sanz hace los pedidos)
SET IDENTITY_INSERT Compras ON;
INSERT INTO Compras (CompraID, ProveedorID, EmpleadoID, FechaCompra, NumeroFacturaProveedor, TotalCompra) VALUES
(601, 201, 3, '2025-11-01', 'COMPRA-HIDRO-001', 500.00),
(602, 202, 3, '2025-11-05', 'COMPRA-GRIFOS-002', 200.00);
SET IDENTITY_INSERT Compras OFF;
GO

SET IDENTITY_INSERT DetallesCompra ON;
INSERT INTO DetallesCompra (DetalleCompraID, CompraID, ArticuloID, Cantidad, PrecioUnitarioCompra) VALUES
(701, 601, 301, 100, 0.80),
(702, 601, 303, 200, 0.25),
(703, 602, 302, 10, 20.00);
SET IDENTITY_INSERT DetallesCompra OFF;
GO

-- HORARIOS LABORALES
INSERT INTO HorariosLaborales (EmpleadoID, DiaSemana, HoraEntrada, HoraSalida) VALUES
(1, 1, '08:00:00', '17:00:00'), (1, 2, '08:00:00', '17:00:00'), (1, 3, '08:00:00', '17:00:00'), (1, 4, '08:00:00', '17:00:00'), (1, 5, '08:00:00', '17:00:00'),
(2, 1, '09:00:00', '18:00:00'), (2, 2, '09:00:00', '18:00:00'), (2, 3, '09:00:00', '18:00:00'), (2, 4, '09:00:00', '18:00:00'), (2, 5, '09:00:00', '18:00:00');
GO

-- AUSENCIAS (Juan de vacaciones)
SET IDENTITY_INSERT Ausencias ON;
INSERT INTO Ausencias (AusenciaID, EmpleadoID, FechaInicio, FechaFin, TipoAusencia, Motivo) VALUES
(801, 1, '2026-01-05', '2026-01-09', 'Vacaciones', 'Descanso anual');
SET IDENTITY_INSERT Ausencias OFF;
GO

-- ************************************************************
-- 3. AGENDA Y FACTURACIÓN
-- ************************************************************

-- CITAS (FacturaID se dejará NULL y se actualizará después)
SET IDENTITY_INSERT Citas ON;
INSERT INTO Citas (CitaID, ClienteID, ServicioID, EmpleadoID, FechaHoraInicio, FechaHoraFin, DireccionServicio, EstadoCita, Comentarios, FacturaID) VALUES
(901, 101, 402, 1, '2025-11-26 10:00:00', '2025-11-26 12:00:00', 'C/ Fugas, 15, 3ºA', 'Completada', 'Fuga en el sifón del lavabo resuelta.', NULL),
(902, 102, 403, 1, '2025-11-27 09:00:00', '2025-11-27 13:00:00', 'C/ Ladrillo, 8, ático', 'Pendiente', 'Instalación de termo. Llevar Termo-50L.', NULL),
(903, 103, 401, 2, '2025-11-26 14:00:00', '2025-11-26 15:30:00', 'Av. Chorros, 30', 'Completada', 'Desatasco rápido en cocina.', NULL),
(904, 102, 404, 2, '2025-12-01 10:00:00', '2025-12-01 11:30:00', 'C/ Ladrillo, 8', 'Confirmada', 'Revisión preventiva de caldera.', NULL);
SET IDENTITY_INSERT Citas OFF;
GO

-- PARTES DE TRABAJO (Para servicios completados: Cita 901 y 903)
SET IDENTITY_INSERT PartesDeTrabajo ON;
INSERT INTO PartesDeTrabajo (ParteID, CitaID, FechaHoraLlegada, FechaHoraSalida, Diagnostico, SolucionAplicada, EstadoFinal, HorasTrabajadas) VALUES
(1001, 901, '2025-11-26 10:05:00', '2025-11-26 11:45:00', 'Sifón con fuga por junta dañada.', 'Sustitución de junta y limpieza de tubería.', 'Resuelto', 1.67), -- 1h 40min
(1002, 903, '2025-11-26 14:10:00', '2025-11-26 14:40:00', 'Obstrucción ligera por grasa.', 'Uso de serpentín manual.', 'Resuelto', 0.50); -- 30min
SET IDENTITY_INSERT PartesDeTrabajo OFF;
GO

-- MATERIAL CONSUMIDO EN PARTES DE TRABAJO (Parte 1001)
SET IDENTITY_INSERT MaterialParteTrabajo ON;
INSERT INTO MaterialParteTrabajo (MaterialParteID, ParteID, ArticuloID, CantidadConsumida) VALUES
(1101, 1001, 303, 2); -- 2 Juntas Tórica
SET IDENTITY_INSERT MaterialParteTrabajo OFF;
GO

-- FACTURAS
SET IDENTITY_INSERT Facturas ON;
INSERT INTO Facturas (FacturaID, NumeroFactura, ClienteID, CitaID, FechaEmision, FechaVencimiento, TotalNeto, IVA, TotalFactura, EstadoFactura, EmpleadoID) VALUES
-- Factura para Cita 901 (Pagada)
(1201, 'F2025-0001', 101, 901, '2025-11-26', '2025-12-26', 149.50, 31.40, 180.90, 'Pagada', 3), -- Calculado: 75(Servicio) + 1.67*40(M.O. Adicional) + 2*0.5(Material) = 149.80 (ajuste decimal para el ejemplo)
-- Factura para Cita 903 (Pendiente)
(1202, 'F2025-0002', 103, 903, '2025-11-27', '2025-12-27', 50.00, 10.50, 60.50, 'Pendiente', 3);
SET IDENTITY_INSERT Facturas OFF;
GO

-- LINEASFACTURA
SET IDENTITY_INSERT LineasFactura ON;
INSERT INTO LineasFactura (LineaFacturaID, FacturaID, ArticuloID, ServicioID, DescripcionServicio, Cantidad, PrecioUnitario, Subtotal) VALUES
-- Líneas Factura 1201 (Cita 901)
(1301, 1201, NULL, 402, NULL, 1.00, 75.00, 75.00), -- Servicio Base
(1302, 1201, NULL, 404, NULL, 1.67, 40.00, 66.80), -- Mano de Obra (Horas Trabajadas del Parte)
(1303, 1201, 303, NULL, NULL, 2.00, 0.50, 1.00),   -- Material (Juntas Tórica)
-- Líneas Factura 1202 (Cita 903)
(1304, 1202, NULL, 401, NULL, 1.00, 50.00, 50.00); -- Servicio Desatasco
SET IDENTITY_INSERT LineasFactura OFF;
GO

-- ************************************************************
-- 4. ACTUALIZACIÓN FINAL DE RELACIONES (FKs)
-- ************************************************************

-- Mapear FacturaID de nuevo a las Citas
UPDATE Citas SET FacturaID = 1201 WHERE CitaID = 901;
UPDATE Citas SET FacturaID = 1202 WHERE CitaID = 903;
GO

-- Reactivar la comprobación de restricciones
EXEC sp_MSforeachtable "ALTER TABLE ? CHECK CONSTRAINT all"
GO

PRINT '¡Todos los datos de ejemplo han sido insertados correctamente en la base de datos Fontaneria!';
