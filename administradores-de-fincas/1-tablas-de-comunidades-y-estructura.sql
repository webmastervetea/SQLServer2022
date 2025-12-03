-- 1. Comunidades de Propietarios
CREATE TABLE Comunidades (
    ComunidadID INT PRIMARY KEY IDENTITY(1,1),
    Nombre VARCHAR(100) NOT NULL,
    CIF VARCHAR(20) UNIQUE,
    Direccion VARCHAR(255),
    Poblacion VARCHAR(100),
    Provincia VARCHAR(100),
    CodigoPostal VARCHAR(10),
    CuentaBancaria VARCHAR(34), -- IBAN
    FechaConstitucion DATE
);

-- 2. Unidades Privativas (Pisos, Locales, Garajes, etc.)
CREATE TABLE Unidades (
    UnidadID INT PRIMARY KEY IDENTITY(1,1),
    ComunidadID INT NOT NULL,
    ReferenciaCatastral VARCHAR(50) UNIQUE,
    Numero VARCHAR(10) NOT NULL, -- Ej: '1A', 'Local 3', 'Garaje 15'
    CoeficienteParticipacion DECIMAL(5, 2) NOT NULL, -- Porcentaje de participación
    TipoUnidad VARCHAR(50), -- Ej: 'Vivienda', 'Local', 'Garaje'
    FOREIGN KEY (ComunidadID) REFERENCES Comunidades(ComunidadID)
);

-- 3. Propietarios (Datos de contacto de los dueños)
CREATE TABLE Propietarios (
    PropietarioID INT PRIMARY KEY IDENTITY(1,1),
    NIF_NIE VARCHAR(20) UNIQUE,
    NombreCompleto VARCHAR(150) NOT NULL,
    Telefono VARCHAR(20),
    Email VARCHAR(100),
    DireccionNotificacion VARCHAR(255),
    EsPresidente BIT DEFAULT 0,
    FechaAlta DATE NOT NULL
);

-- 4. Relación Propietario-Unidad (Quién es dueño de qué unidad, permite múltiples dueños y cambios de propiedad)
CREATE TABLE PropiedadUnidad (
    PropiedadUnidadID INT PRIMARY KEY IDENTITY(1,1),
    UnidadID INT NOT NULL,
    PropietarioID INT NOT NULL,
    FechaInicioPropiedad DATE NOT NULL,
    FechaFinPropiedad DATE, -- NULL si es el propietario actual
    FOREIGN KEY (UnidadID) REFERENCES Unidades(UnidadID),
    FOREIGN KEY (PropietarioID) REFERENCES Propietarios(PropietarioID),
    UNIQUE (UnidadID, PropietarioID, FechaFinPropiedad) -- Asegura que una unidad solo tenga un propietario activo a la vez.
);