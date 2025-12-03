-- Creamos los esquemas para la organización y permisos
CREATE SCHEMA Admin;
GO
CREATE SCHEMA Contabilidad;
GO
CREATE SCHEMA Operaciones;
GO
-- Añadir campos necesarios para la generación de remesas SEPA
ALTER TABLE Propietarios
ADD IBAN VARCHAR(34),
    BIC VARCHAR(11);
GO
