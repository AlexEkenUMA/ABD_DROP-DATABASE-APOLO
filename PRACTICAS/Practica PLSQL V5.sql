CREATE OR REPLACE PACKAGE PK_GESTION_CLIENTES AS
    PROCEDURE DAR_ALTA (IDE NUMBER, IDENTIFIACION VARCHAR2, TIPO VARCHAR2, ESTADO VARCHAR2,
    FECHA_ALTA DATE, FECHA_BAJA DATE, DIRECCION VARCHAR2, CIUDAD VARCHAR2, 
    CODIGO_POSTAL NUMBER, PAIS VARCHAR2, RAZON_SOCIAL VARCHAR2, NOMBRE VARCHAR2,
    APELLIDO VARCHAR2, FECHA_NAC DATE);
    
    PROCEDURE MODIFICAR_CLIENTE (IDE NUMBER, T VARCHAR2, E VARCHAR2,
    F_A DATE, F_B DATE, D VARCHAR2, C VARCHAR2, 
    C_P NUMBER, PA VARCHAR2, RAZ_SOC VARCHAR2, NOM VARCHAR2,
    APE VARCHAR2, FEC_NA DATE);

    PROCEDURE BAJA_CLIENTE (IDE NUMBER);
    
    PROCEDURE ANADIR_AUTORIZADOS(ID_CLIENTE NUMBER, ID_AUTORIZADO NUMBER, TIPO_AUTORIZACION VARCHAR2,
    IDENTIFICACION VARCHAR2, NOMBRE VARCHAR2, APELLIDOS VARCHAR2, DIRECCION VARCHAR2, FECHA_NAC DATE, 
    ESTADO VARCHAR2, FECHA_INI DATE, FECHA_FIN DATE);
    
    PROCEDURE MODIFICAR_PERSONA_AUTORIZADA (IDE NUMBER, NOM VARCHAR2, AP VARCHAR2,
    DIR VARCHAR2, FEC_NA DATE, E VARCHAR2, F_INI DATE, F_FIN DATE, TIPO_AUTO VARCHAR2);
    
    PROCEDURE ELIMINAR_AUTORIZADO (IDE NUMBER, ID_EMPRESA NUMBER);
    
END PK_GESTION_CLIENTES;
/


CREATE OR REPLACE PACKAGE BODY PK_GESTION_CLIENTES AS
    PROCEDURE DAR_ALTA (IDE NUMBER, IDENTIFIACION VARCHAR2, TIPO VARCHAR2, ESTADO VARCHAR2,
    FECHA_ALTA DATE, FECHA_BAJA DATE, DIRECCION VARCHAR2, CIUDAD VARCHAR2, 
    CODIGO_POSTAL NUMBER, PAIS VARCHAR2, RAZON_SOCIAL VARCHAR2, NOMBRE VARCHAR2,
    APELLIDO VARCHAR2, FECHA_NAC DATE)
    IS 
        FILA VARCHAR(50);
        CLIENTE_YA_ENCONTRADO EXCEPTION;
        TIPO_NO_VALIDO EXCEPTION;
    BEGIN 
    
    
        SELECT COUNT(*) INTO FILA
        FROM CLIENTE
        WHERE ID = IDE;
        
        IF FILA LIKE '1' THEN
            RAISE CLIENTE_YA_ENCONTRADO;
        ELSE
            INSERT INTO CLIENTE VALUES (IDE, IDENTIFIACION, TIPO, ESTADO, FECHA_ALTA,
            FECHA_BAJA, DIRECCION, CIUDAD, CODIGO_POSTAL, PAIS);
        END IF;
        
        IF TIPO != 'FISICO' AND TIPO != 'JURIDICO' THEN
            RAISE TIPO_NO_VALIDO;
        END IF;
        
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
        FILA VARCHAR(50);
        CLIENTE_NO_ENCONTRADO EXCEPTION;
    
    BEGIN 

    
        SELECT COUNT(*) INTO FILA
        FROM CLIENTE
        WHERE ID = IDE;
        
        IF FILA LIKE '1' THEN
        
            UPDATE CLIENTE 
            SET ESTADO = E, DIRECCION = D, CIUDAD = C, CODIGOPOSTAL = C_P, PAIS = PA
            WHERE ID = IDE;
        ELSE
            RAISE CLIENTE_NO_ENCONTRADO;
        END IF;
        
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
    
    
    PROCEDURE BAJA_CLIENTE (IDE NUMBER)
    IS 
        FILA VARCHAR(50);
        FILA_CUENTA VARCHAR(50);
        CLIENTE_NO_ENCONTRADO EXCEPTION;
        CUENTAS_ABIERTAS EXCEPTION;
    BEGIN
    
        
        SELECT COUNT(*) INTO FILA
        FROM CLIENTE
        WHERE ID = IDE;
        
        SELECT COUNT(*) INTO FILA_CUENTA
        FROM FINTECH
        WHERE CLIENTE_ID = IDE AND ESTADO != 'BAJA';
        
        IF FILA != '1' THEN
            RAISE CLIENTE_NO_ENCONTRADO;
        END IF;
        
        IF FILA_CUENTA != '0' THEN
            RAISE CUENTAS_ABIERTAS;
        END IF;
           
        UPDATE CLIENTE
        SET ESTADO = 'BAJA', FECHA_BAJA = SYSDATE
        WHERE ID = IDE;
    
    END;
    
    PROCEDURE ANADIR_AUTORIZADOS (ID_CLIENTE NUMBER, ID_AUTORIZADO NUMBER, TIPO_AUTORIZACION VARCHAR2,
    IDENTIFICACION VARCHAR2, NOMBRE VARCHAR2, APELLIDOS VARCHAR2, DIRECCION VARCHAR2, FECHA_NAC DATE, 
    ESTADO VARCHAR2, FECHA_INI DATE, FECHA_FIN DATE)
    IS
        FILA VARCHAR(50);
        FILA_AUTORIZADO VARCHAR(50);
        CLIENTE_NO_ENCONTRADO EXCEPTION;
        TIPOAUT_NO_VALIDO EXCEPTION;
    BEGIN
    
        SELECT COUNT(*) INTO FILA
        FROM CLIENTE
        WHERE ID = ID_CLIENTE AND TIPO_CLIENTE = 'JURIDICO';
        
        SELECT COUNT(*) INTO FILA_AUTORIZADO
        FROM PERSONA_AUTORIZADA 
        WHERE ID = ID_AUTORIZADO;
        
        
        IF FILA != '1' THEN
            RAISE CLIENTE_NO_ENCONTRADO;
        END IF;
            
        IF TIPO_AUTORIZACION != 'CONSULTA' AND TIPO_AUTORIZACION != 'OPERACION' THEN
            RAISE TIPOAUT_NO_VALIDO;
        END IF;
            
        IF FILA_AUTORIZADO = '1' THEN
            INSERT INTO AUTORIZACIÓN VALUES (TIPO_AUTORIZACION, ID_AUTORIZADO, ID_CLIENTE);
        ELSE
            INSERT INTO PERSONA_AUTORIZADA VALUES (ID_AUTORIZADO, IDENTIFICACION, NOMBRE, APELLIDOS, DIRECCION, FECHA_NAC, 
            ESTADO, FECHA_INI, FECHA_FIN);
            INSERT INTO AUTORIZACIÓN VALUES (TIPO_AUTORIZACION, ID_AUTORIZADO, ID_CLIENTE);
        END IF;
        
     END;
    
    PROCEDURE MODIFICAR_PERSONA_AUTORIZADA (IDE NUMBER, NOM VARCHAR2, AP VARCHAR2,
    DIR VARCHAR2, FEC_NA DATE, E VARCHAR2, F_INI DATE, F_FIN DATE, TIPO_AUTO VARCHAR2)
    IS
        FILA VARCHAR(50);
        FILA_AUTORIZACION VARCHAR(50);
        PERSONA_AUTORIZADA_NO_ENCONTRADO EXCEPTION;
        AUTORIZACION_NO_ESTA EXCEPTION;
    
    BEGIN 
    
        SELECT COUNT(*) INTO FILA
        FROM PERSONA_AUTORIZADA
        WHERE ID = IDE;

        SELECT COUNT(*) INTO FILA_AUTORIZACION
        FROM AUTORIZACIÓN
        WHERE PERSONA_AUTORIZADA_ID = IDE;
        
        IF FILA LIKE '1' THEN
        
            UPDATE PERSONA_AUTORIZADA 
            SET NOMBRE = NOM, APELLIDOS = AP, DIRECCION = DIR, FECHA_NACIMIENTO = FEC_NA, ESTADO = E
            WHERE ID = IDE;
        ELSE
            RAISE PERSONA_AUTORIZADA_NO_ENCONTRADO;
        END IF;

        IF FILA_AUTORIZACION LIKE '0' THEN
            RAISE AUTORIZACION_NO_ESTA;
        ELSE 
            UPDATE AUTORIZACIÓN
            SET TIPO = TIPO_AUTO
            WHERE PERSONA_AUTORIZADA_ID = IDE;
        END IF;
    
    END;
    
    
    PROCEDURE ELIMINAR_AUTORIZADO (IDE NUMBER, ID_EMPRESA NUMBER)
    IS 
        FILA VARCHAR(50);
        FILA_AMBAS VARCHAR(50);
        FILA_AUTORIZACION VARCHAR(50);
        PERSONA_AUTORIZADA_NO_ENCONTRADO EXCEPTION;
        AUTORIZACION_NO_ENCONTRADA EXCEPTION;
       
    BEGIN
        
        SELECT COUNT(*) INTO FILA
        FROM PERSONA_AUTORIZADA
        WHERE ID = IDE;
        
        IF FILA != '1' THEN
            RAISE PERSONA_AUTORIZADA_NO_ENCONTRADO;
        END IF;
        
        SELECT COUNT(*) INTO FILA_AMBAS
        FROM AUTORIZACIÓN
        WHERE EMPRESA_ID = ID_EMPRESA AND PERSONA_AUTORIZADA_ID = IDE;
        
        IF FILA_AMBAS = '0' THEN
            RAISE AUTORIZACION_NO_ENCONTRADA;
        END IF;
        
        DELETE FROM AUTORIZACIÓN
        WHERE EMPRESA_ID = ID_EMPRESA AND PERSONA_AUTORIZADA_ID = IDE; 
        
        SELECT COUNT(*) INTO FILA_AUTORIZACION
        FROM AUTORIZACIÓN
        WHERE PERSONA_AUTORIZADA_ID = IDE;

        IF FILA_AUTORIZACION = '0' THEN
            UPDATE PERSONA_AUTORIZADA
            SET ESTADO = 'BORRADO', FECHAFIN = SYSDATE
            WHERE ID = IDE;
        END IF;
    
    END;
    
    
END PK_GESTION_CLIENTES;