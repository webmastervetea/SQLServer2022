-- ******************************************************
-- PASO 0: Creación de la Base de Datos
-- ******************************************************
-- Verificar y eliminar la DB si ya existe (opcional, para limpieza)
IF DB_ID('Fontaneria') IS NOT NULL
BEGIN
    ALTER DATABASE Definitivo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Fontaneria;
END

-- Crear la Base de Datos
CREATE DATABASE  Fontaneria;
GO