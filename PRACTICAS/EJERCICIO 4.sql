--EJERCICIO 4

CREATE OR REPLACE PACKAGE PK_OPERATIVA AS

    PROCEDURE INSERTAR_TRANSACCION (ID NUMBER, ORIGEN_IBAN VARCHAR2, DESTINO_IBAN
    VARCHAR2,DIVISA_1 VARCHAR2, DIVISA_2 VARCHAR2, CANTIDAD NUMBER, TIPO VARCHAR, INTERNACIONAL CHAR, 
    COMISION NUMBER, FECHA_INSTRUC DATE);
    
END PK_OPERATIVA;

/


CREATE OR REPLACE PACKAGE BODY PK_OPERATIVA AS
    PROCEDURE INSERTAR_TRANSACCION (ID NUMBER, ORIGEN_IBAN VARCHAR2, DESTINO_IBAN VARCHAR2,
    DIVISA_1 VARCHAR2, DIVISA_2 VARCHAR2, CANTIDAD NUMBER, TIPO VARCHAR, INTERNACIONAL CHAR, 
    COMISION NUMBER, FECHA_INSTRUC DATE)
    IS
    FILA_CUENTA1 VARCHAR2(50);
    FILA_CUENTA2 VARCHAR2(50);
    TIPO_CUENTA1 VARCHAR2(50);
    TIPO_CUENTA2 VARCHAR2(50);
    CUENTA_NO_ENCONTRADA EXCEPTION;
    CANTIDAD_ERRONEA EXCEPTION;
    
    --COMPROBAR EXCEPCION DE SALDO SUFICIENTE
    
    BEGIN
        SELECT COUNT(*) INTO FILA_CUENTA1 FROM FINTECH
        WHERE IBAN = ORIGEN_IBAN AND ESTADO = 'ACTIVA';
        
        SELECT COUNT(*) INTO FILA_CUENTA2 FROM FINTECH
        WHERE IBAN = DESTINO_IBAN AND ESTADO = 'ACTIVA';
    
        IF FILA_CUENTA1 LIKE '0' OR FILA_CUENTA2 LIKE '0' THEN
            RAISE CUENTA_NO_ENCONTRADA;
        END IF;
        
        IF CANTIDAD <= 0 THEN
            RAISE CANTIDAD_ERRONEA;
        END IF;
        
        SELECT CLASIFICACION INTO TIPO_CUENTA1 FROM FINTECH
        WHERE IBAN = ORIGEN_IBAN;
        
        IF TIPO_CUENTA1 LIKE 'SEGREGADA' THEN
            
            UPDATE REFERENCIA
            SET SALDO = SALDO-CANTIDAD --COMISION?????
            WHERE IBAN = (SELECT IBAN_CUENTAREF FROM SEGREGADA WHERE IBAN = ORIGEN_IBAN);
        
        END IF;
        
        IF TIPO_CUENTA1 LIKE 'POOLED' THEN 
        
            UPDATE DEPOSITADA_EN                       --Mira las que coincide con la divisa
            SET SALDO = SALDO-CANTIDAD
            WHERE POOLED_ACCOUNT_IBAN = ORIGEN_IBAN;  --ACTUCALIZAR TAMBIEN CUENTA DE REFERENCIA?????
        
        END IF;
        
        SELECT FINTECH.CLASIFICACION INTO TIPO_CUENTA2 FROM FINTECH
        WHERE IBAN = DESTINO_IBAN;
        
        IF TIPO_CUENTA2 LIKE 'SEGREGADA' THEN
        
            UPDATE REFERENCIA
            SET SALDO = SALDO+CANTIDAD
            WHERE IBAN = (SELECT IBAN_CUENTAREF FROM SEGREGADA WHERE IBAN = DESTINO_IBAN);
        
        END IF;
        
        IF TIPO_CUENTA2 LIKE 'POOLED' THEN
        
            UPDATE DEPOSITADA_EN
            SET SALDO = SALDO+CANTIDAD
            WHERE POOLED_ACCOUNT_IBAN = DESTINO_IBAN; --CUENTA REFERENCIA
        END IF;
        
        IF TIPO_CUENTA2 LIKE 'REFERENCIA' THEN
            
            UPDATE REFERENCIA
            SET SALDO = SALDO+CANTIDAD
            WHERE IBAN = DESTINO_IBAN;         
        END IF;

        INSERT INTO TRANSACCION VALUES (ID, FECHA_INSTRUC, CANTIDAD, SYSDATE, TIPO, COMISION, INTERNACIONAL,
        ORIGEN_IBAN, DESTINO_IBAN, DIVISA_1, DIVISA_2);
    
    END;
    
END PK_OPERATIVA;
/