CREATE OR REPLACE PACKAGE PK_GESTION_CLIENTES AS
    PROCEDURE DAR_ALTA (IDE NUMBER, IDENTIFIACION VARCHAR2, TIPO VARCHAR2, ESTADO VARCHAR2,
    FECHA_ALTA DATE, FECHA_BAJA DATE, DIRECCION VARCHAR2, CIUDAD VARCHAR2, 
    CODIGO_POSTAL NUMBER, PAIS VARCHAR2, RAZON_SOCIAL VARCHAR2, NOMBRE VARCHAR2,
    APELLIDO VARCHAR2, FECHA_NAC DATE);
    
    PROCEDURE MODIFICAR_CLIENTE (IDE NUMBER, T VARCHAR2, E VARCHAR2,
    F_A DATE, F_B DATE, D VARCHAR2, C VARCHAR2, 
    C_P NUMBER, PA VARCHAR2, RAZ_SOC VARCHAR2, NOM VARCHAR2,
    APE VARCHAR2, FEC_NA DATE);

    
END PK_GESTION_CLIENTES;
/


CREATE OR REPLACE PACKAGE BODY PK_GESTION_CLIENTES AS
    PROCEDURE DAR_ALTA (IDE NUMBER, IDENTIFIACION VARCHAR2, TIPO VARCHAR2, ESTADO VARCHAR2,
    FECHA_ALTA DATE, FECHA_BAJA DATE, DIRECCION VARCHAR2, CIUDAD VARCHAR2, 
    CODIGO_POSTAL NUMBER, PAIS VARCHAR2, RAZON_SOCIAL VARCHAR2, NOMBRE VARCHAR2,
    APELLIDO VARCHAR2, FECHA_NAC DATE)
    IS 
    BEGIN 
    
    --HABR�A QUE MIRAR EL TRATAMIENTO DE EXCEPCIONES
    --MIRAR SI EL CLIENTE YA ESTA
    --TIPO NO VALIDO?�
        INSERT INTO CLIENTE VALUES (IDE, IDENTIFIACION, TIPO, ESTADO, FECHA_ALTA,
        FECHA_BAJA, DIRECCION, CIUDAD, CODIGO_POSTAL, PAIS);
        
        IF TIPO = 'FISICO' THEN
            INSERT INTO INDIVIDUAL VALUES (IDE, NOMBRE, APELLIDO, FECHA_NAC);
        END IF;
        
        IF TIPO = 'JURIDICO' THEN
            INSERT INTO EMPRESA VALUES (IDE, RAZON_SOCIAL);
        END IF;
    END;

    
    PROCEDURE MODIFICAR_CLIENTE (IDE NUMBER, T VARCHAR2, E VARCHAR2,
    F_A DATE, F_B DATE, D VARCHAR2, C VARCHAR2, 
    C_P NUMBER, PA VARCHAR2, RAZ_SOC VARCHAR2, NOM VARCHAR2,
    APE VARCHAR2, FEC_NA DATE)
    IS
    BEGIN 
    
    --TRATAMIENTO DE EXCEPCIONES
    --COMPROBAR SI EL CLIENTE ESTA EN LA BD 
    
        UPDATE CLIENTE 
        SET ESTADO = E, DIRECCION = D, CIUDAD = C, CODIGOPOSTAL = C_P, PAIS = PA
        WHERE ID = IDE;
        
        IF T = 'FISICO' THEN
            UPDATE INDIVIDUAL
            SET NOMBRE = NOM, APELLIDO = APE, FECHA_NACIMIENTO = FEC_NA
            WHERE ID = IDE;
        END IF;
        
        IF T = 'JURIDICO' THEN
            UPDATE EMPRESA
            SET RAZON_SOCIAL = RAZ_SOC
            WHERE ID = IDE;
        END IF;
    
    END;
    
END PK_GESTION_CLIENTES;