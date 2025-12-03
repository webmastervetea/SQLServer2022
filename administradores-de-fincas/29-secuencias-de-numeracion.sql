-- Secuencia para asegurar la numeración secuencial de Actas de Junta
CREATE SEQUENCE Seq_NumeroActa
START WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 99999
CACHE 10;
GO

-- Secuencia para la numeración de facturas internas emitidas por la comunidad
CREATE SEQUENCE Seq_NumeroFacturaComunidad
START WITH 1000
INCREMENT BY 1
MINVALUE 1000
MAXVALUE 999999
CACHE 10;
GO