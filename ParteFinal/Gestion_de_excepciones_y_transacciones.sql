
CREATE OR ALTER PROCEDURE SP_INGRESA_LOCACION
    @COD_LOCACION INT,
    @DIRECCION NVARCHAR(255),
    @COD_POSTAL NVARCHAR(20),
    @CIUDAD NVARCHAR(50),
    @ESTADO NVARCHAR(50),
    @COD_PAIS CHAR(2),
    @RESULTADO INT OUTPUT,
    @MENSAJE VARCHAR(200) OUTPUT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @EXISTE INT;
---validacion de campos obligatorios
        IF @DIRECCION IS NULL OR @COD_POSTAL IS NULL OR @CIUDAD IS NULL OR @ESTADO IS NULL
        BEGIN
            SET @RESULTADO = 2;
            SET @MENSAJE = 'DIRECCION, CODIGO POSTAL, CIUDAD Y ESTADO NO PUEDEN SER NULOS';
            ROLLBACK TRANSACTION;
            RETURN;
        END
---validacion de existencias del pais 
        SELECT @EXISTE = COUNT(*) FROM COUNTRIES WHERE COUNTRY_ID = @COD_PAIS;
        IF @EXISTE = 0
        BEGIN
            SET @RESULTADO = 3;
            SET @MENSAJE = 'EL CODIGO DE PAIS NO EXISTE';
            ROLLBACK TRANSACTION;
            RETURN;
        END
---validacion de las locaciones 
        SELECT @EXISTE = COUNT(*) FROM LOCATIONS WHERE LOCATION_ID = @COD_LOCACION;
        IF @EXISTE > 0
        BEGIN
            SET @RESULTADO = 4;
            SET @MENSAJE = 'EL CODIGO DE LOCACION YA EXISTE';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        INSERT INTO LOCATIONS (LOCATION_ID, ADDRESS, POSTAL_CODE, CITY, STATE, COUNTRY_ID)
        VALUES (@COD_LOCACION, @DIRECCION, @COD_POSTAL, @CIUDAD, @ESTADO, @COD_PAIS);

        COMMIT TRANSACTION;
        SET @RESULTADO = 1;
        SET @MENSAJE = 'LOCACION GUARDADA CORRECTAMENTE';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SET @RESULTADO = 0;
        SET @MENSAJE = 'ERROR ' + CAST(ERROR_NUMBER() AS VARCHAR(10)) + ': ' + ERROR_MESSAGE();
    END CATCH
END;
GO
-- PRUEBAS 

-- Declaración de variables para atrapar los mensajes de salida del SP
DECLARE @RES INT;
DECLARE @MSJ VARCHAR(200);

PRINT 'PRUEBAS DE INSERCIÓN EXITOSAS (COMMIT)';

-- Prueba 1: Inserción válida 1
EXEC SP_INGRESA_LOCACION 9001, '123 Calle Principal', '11111', 'Tegucigalpa', 'Francisco Morazan', 'US', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 1: ' + @MSJ;

-- Prueba 2: Inserción válida 2
EXEC SP_INGRESA_LOCACION 9002, '456 Avenida Central', '22222', 'San Pedro Sula', 'Cortes', 'UK', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 2: ' + @MSJ;

-- Prueba 3: Inserción válida 3
EXEC SP_INGRESA_LOCACION 9003, '789 Bulevar Morazan', '33333', 'Comayagua', 'Comayagua', 'CA', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 3: ' + @MSJ;

-- Prueba 4: Inserción válida 4
EXEC SP_INGRESA_LOCACION 9004, '10 Colonia Kennedy', '44444', 'La Ceiba', 'Atlantida', 'DE', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 4: ' + @MSJ;

-- Prueba 5: Inserción válida 5
EXEC SP_INGRESA_LOCACION 9005, 'Residencial Plaza', '55555', 'Choluteca', 'Choluteca', 'JP', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 5: ' + @MSJ;

-- Prueba 6: Inserción válida 6
EXEC SP_INGRESA_LOCACION 9006, 'Barrio El Centro', '66666', 'Santa Rosa', 'Copan', 'IT', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 6: ' + @MSJ;

PRINT '';
PRINT 'PRUEBAS DE ERRORES (Hace ROLLBACK) ';

-- Prueba 7: Error provocado - El país 'ZZ' no existe
EXEC SP_INGRESA_LOCACION 9007, 'Direccion X', '77777', 'Ciudad X', 'Estado X', 'ZZ', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 7 (País no existe): ' + @MSJ;

-- Prueba 8: Error provocado - Dirección es NULA
EXEC SP_INGRESA_LOCACION 9008, NULL, '88888', 'Ciudad Y', 'Estado Y', 'US', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 8 (Dirección Nula): ' + @MSJ;

-- Prueba 9: Error provocado - Estado es NULO
EXEC SP_INGRESA_LOCACION 9009, 'Direccion Z', '99999', 'Ciudad Z', NULL, 'US', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 9 (Estado Nulo): ' + @MSJ;

-- Prueba 10: Error provocado - Locación duplicada (Repetimos el ID 9001 de la Prueba 1)
EXEC SP_INGRESA_LOCACION 9001, 'Otra Direccion', '00000', 'Otra Ciudad', 'Otro Estado', 'US', @RES OUTPUT, @MSJ OUTPUT;
PRINT 'Prueba 10 (ID Duplicado): ' + @MSJ;