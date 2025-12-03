-- Se registra que la cuota con ID 1 fue pagada el 10 de Noviembre de 2025
EXEC SP_RegistrarPagoCuota 
    @CuotaDerramaID = 1,
    @FechaPago = '2025-11-10';

SELECT * FROM CuotasDerramas WHERE CuotaDerramaID = 1;
-- El campo EstadoPago ahora debería ser 'Pagado' y FechaPago debería ser '2025-11-10'.