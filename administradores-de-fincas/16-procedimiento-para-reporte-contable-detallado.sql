INSERT INTO Comunidades (Nombre, CIF, Direccion, Poblacion, Provincia, CodigoPostal, CuentaBancaria, FechaConstitucion)
VALUES (
    'Comunidad Edificio del Sol',
    'A12345678',
    'Calle Mayor, 15',
    'Madrid',
    'Madrid',
    '28001',
    'ES123456789012345678901234',
    '2005-09-01'
);
-- Asumimos que ComunidadID = 1
INSERT INTO Propietarios (NIF_NIE, NombreCompleto, Telefono, Email, DireccionNotificacion, EsPresidente, FechaAlta)
VALUES 
    ('45111222X', 'Laura García Pérez', '600111222', 'laura.gp@mail.com', 'Calle Mayor, 15, 1A', 1, '2020-05-10'),
    ('50333444Y', 'Inversiones Sigma S.L.', '915556667', 'sigma@inversiones.com', 'Av. Central, 5', 0, '2022-01-20');
-- Asumimos PropietarioID 1 (Laura García) y 2 (Sigma S.L.)
GO
INSERT INTO Unidades (ComunidadID, ReferenciaCatastral, Numero, CoeficienteParticipacion, TipoUnidad)
VALUES 
    (1, '0001010101010101A', '1A', 35.00, 'Vivienda'), -- Coeficiente 35%
    (1, '0001010101010102B', '2B', 45.00, 'Vivienda'), -- Coeficiente 45%
    (1, '0001010101010103G', 'G01', 20.00, 'Garaje');   -- Coeficiente 20%
-- Asumimos UnidadID 1, 2 y 3
-- Laura García (ID 1) es dueña de 1A (ID 1) y G01 (ID 3)
GO
INSERT INTO PropiedadUnidad (UnidadID, PropietarioID, FechaInicioPropiedad, FechaFinPropiedad)
VALUES 
    (1, 1, '2020-05-10', NULL), 
    (3, 1, '2020-05-10', NULL);

-- Sigma S.L. (ID 2) es dueña de 2B (ID 2)
GO
INSERT INTO PropiedadUnidad (UnidadID, PropietarioID, FechaInicioPropiedad, FechaFinPropiedad)
VALUES 
    (2, 2, '2022-01-20', NULL);
GO
INSERT INTO Cuentas (ComunidadID, CodigoCuenta, Descripcion, TipoCuenta)
VALUES 
    (1, '700', 'Cuotas Ordinarias', 'Ingreso'),
    (1, '622', 'Gastos de Limpieza', 'Gasto'),
    (1, '624', 'Mantenimiento Ascensor', 'Gasto'),
    (1, '572', 'Banco Principal', 'Banco'),
    (1, '555', 'Remanente Ejercicio', 'Deuda'); -- Cuenta de cierre contable
-- Asumimos CuentaID 1, 2, 3, 4, 5
GO
INSERT INTO Proveedores (NIF_CIF, RazonSocial, Contacto, Telefono, Email)
VALUES 
    ('B87654321', 'Limpiezas Brillo S.L.', 'Ana Robles', '910001112', 'brillo@limpieza.com'),
    ('A99887766', 'Mantenimiento Vertical S.A.', 'Pedro Sánchez', '919998887', 'vertical@mantenimiento.es');
-- Asumimos ProveedorID 1 y 2
-- Gasto de Limpieza (Proveedor 1)
GO
INSERT INTO Movimientos (ComunidadID, FechaMovimiento, TipoMovimiento, Concepto, Monto, CuentaContableID, ProveedorID, NumeroFactura)
VALUES 
    (1, '2025-01-15', 'Gasto', 'Factura Mensual Limpieza Enero', 120.00, 2, 1, 'FCL-2501');

-- Gasto de Mantenimiento Ascensor (Proveedor 2)
GO
INSERT INTO Movimientos (ComunidadID, FechaMovimiento, TipoMovimiento, Concepto, Monto, CuentaContableID, ProveedorID, NumeroFactura)
VALUES 
    (1, '2025-01-20', 'Gasto', 'Revisión trimestral Ascensor', 300.00, 3, 2, 'FMA-0125');
-- Cuotas de Enero 2025 (total 420.00 EUR)
GO
INSERT INTO CuotasDerramas (ComunidadID, UnidadID, Mes, MontoCuota, EstadoPago, FechaVencimiento)
VALUES 
    (1, 1, '2025-01-01', 147.00, 'Pagado', '2025-01-10'),     -- 1A (Laura) - Pagado
    (1, 2, '2025-01-01', 189.00, 'Pendiente', '2025-01-10'),  -- 2B (Sigma) - Pendiente (Moroso)
    (1, 3, '2025-01-01', 84.00, 'Pagado', '2025-01-10');      -- G01 (Laura) - Pagado

GO
INSERT INTO Juntas (ComunidadID, FechaJunta, TipoJunta, AsuntoPrincipal, ActaRutaArchivo)
VALUES 
    (1, '2025-02-10 18:00:00', 'Ordinaria', 'Aprobación de cuentas del ejercicio anterior y presupuesto 2025.', '/documentos/com1/actas/acta_ord_20250210.pdf'),
    (1, '2025-05-25 19:30:00', 'Extraordinaria', 'Estudio y aprobación de obra para reparación de fachada.', '/documentos/com1/actas/acta_ext_20250525.pdf');
-- Asumimos JuntaID 1 y 2
-- Acuerdo 1: Aprobación del Presupuesto 2025
GO
INSERT INTO Acuerdos (JuntaID, DescripcionAcuerdo, VotosFavor, VotosContra, VotosAbstencion, AcuerdoAprobado)
VALUES 
    (1, 
    'Se aprueba el presupuesto de ingresos y gastos para el ejercicio 2025 por un total de 5.000 EUR.', 
    80, -- Votos a favor (representando 80% del coeficiente)
    20, 
    0, 
    1); -- 1 (TRUE) porque el 80% de los coeficientes votó a favor.

-- Acuerdo 2: Nombramiento de Presidente
GO
INSERT INTO Acuerdos (JuntaID, DescripcionAcuerdo, VotosFavor, VotosContra, VotosAbstencion, AcuerdoAprobado)
VALUES 
    (1, 
    'Se renueva el nombramiento de la propietaria Dña. Laura García Pérez como Presidenta de la comunidad por un año más.', 
    100, -- Todos a favor
    0, 
    0, 
    1);
GO
INSERT INTO Documentos (ComunidadID, NombreDocumento, TipoDocumento, RutaArchivo)
VALUES 
    (1, 'Estatutos Constitucionales', 'Estatutos', '/documentos/com1/estatutos_originales.pdf'),
    (1, 'Póliza de Seguro 2025-2026', 'Póliza Seguro', '/documentos/com1/polizas/poliza_seguro_2025.pdf'),
    (1, 'Póliza de Seguro 2024-2025', 'Póliza Seguro', '/documentos/com1/polizas/poliza_seguro_2024.pdf'), -- Documento anterior
    (1, 'Contrato de Mantenimiento Ascensor', 'Contrato Mantenimiento', '/documentos/com1/contratos/contrato_ascensor_vertical.pdf');



