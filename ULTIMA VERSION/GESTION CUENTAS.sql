CREATE OR REPLACE PACKAGE PK_GESTION_CUENTAS AS 
    PROCEDURE ABRIR_CUENTA (IBAN VARCHAR2, SWIFT VARCHAR2, TIPO_CUENTA VARCHAR2,
    IDE_CLIENTE NUMBER, CLASIFICACION VARCHAR2, IBAN_REFERENCIA VARCHAR2, COMISION NUMBER);
    
    
    PROCEDURE CIERRE_CUENTA (IBANN VARCHAR2, TIPO_CUENTA VARCHAR2, IBAN_REFERENCIA VARCHAR2);
    
    --EXCEPCIONES
    
    CLIENTE_NO_ENCONTRADO EXCEPTION;
    TIPO_NO_VALIDO EXCEPTION;
    CLIENTE_BAJA EXCEPTION;
    REFERENCIA_NO_ENCONTRADA EXCEPTION;
    SALDO_NO_CERO EXCEPTION;
    CUENTA_NO_ENCONTRADA EXCEPTION;
    
    
END PK_GESTION_CUENTAS;
/


CREATE OR REPLACE PACKAGE BODY PK_GESTION_CUENTAS AS
    PROCEDURE ABRIR_CUENTA (IBAN VARCHAR2, SWIFT VARCHAR2, TIPO_CUENTA VARCHAR2,
    IDE_CLIENTE NUMBER, CLASIFICACION VARCHAR2, IBAN_REFERENCIA VARCHAR2,COMISION NUMBER)
    IS
    
    FILA VARCHAR(50);
  
    
    BEGIN 
    
    SELECT COUNT(*) INTO FILA
    FROM CLIENTE
    WHERE ID = IDE_CLIENTE;
    
    IF FILA != '1' THEN
        RAISE CLIENTE_NO_ENCONTRADO;
    END IF;
    
    SELECT COUNT(*) INTO FILA
    FROM CLIENTE 
    WHERE ID = IDE_CLIENTE AND ESTADO = 'BAJA';
    
    IF FILA LIKE '1' THEN
        RAISE CLIENTE_BAJA;
    END IF;
    
    IF TIPO_CUENTA != 'POOLED' AND TIPO_CUENTA != 'SEGREGATED' THEN
        RAISE TIPO_NO_VALIDO;
    END IF;
    
    INSERT INTO CUENTA VALUES (IBAN, SWIFT);
    
    INSERT INTO FINTECH VALUES (IBAN, 'ACTIVA', SYSDATE, NULL, CLASIFICACION,
    IDE_CLIENTE);
    
    IF TIPO_CUENTA LIKE 'POOLED' THEN
        SELECT COUNT(*) INTO FILA
        FROM REFERENCIA
        WHERE IBAN = IBAN_REFERENCIA;
        
        IF FILA !=  '1' THEN
            RAISE REFERENCIA_NO_ENCONTRADA;
        END IF;
        INSERT INTO POOLED_ACCOUNT VALUES (IBAN);
        INSERT INTO DEPOSITADA_EN VALUES (0, IBAN, IBAN_REFERENCIA);
    END IF;
    
    IF TIPO_CUENTA LIKE 'SEGREGADA' THEN
        INSERT INTO SEGREGADA VALUES (IBAN, COMISION, IBAN_REFERENCIA);
    END IF;
    
    COMMIT;
    EXCEPTION
        WHEN CLIENTE_NO_ENCONTRADO THEN
            INSERT INTO LOG_ERRORES VALUES ('CLIENTE_NO_ENCONTRADO', 'EXECEPCION DURANTE LA EJECUCION DE
            ABRIR CUENTA EN PK_CUENTAS: CLIENTE NO ENCONTRADO',
            SYSDATE);
            COMMIT;
            RAISE CLIENTE_NO_ENCONTRADO;
            
        WHEN CLIENTE_BAJA THEN
            INSERT INTO LOG_ERRORES VALUES ('CLIENTE_BAJA', 'EXECEPCION DURANTE LA EJECUCION DE
            ABRIR CUENTA EN PK_CUENTAS: CLIENTE DE BAJA',
            SYSDATE);
            COMMIT;
            RAISE CLIENTE_BAJA;
            
        WHEN TIPO_NO_VALIDO THEN
            INSERT INTO LOG_ERRORES VALUES ('TIPO_NO_VALIDO', 'EXECEPCION DURANTE LA EJECUCION DE
            ABRIR CUENTA EN PK_CUENTAS: TIPO DE CUENTA NO VALIDO',
            SYSDATE);
            COMMIT;
            RAISE TIPO_NO_VALIDO;
            
         WHEN REFERENCIA_NO_ENCONTRADA THEN
            INSERT INTO LOG_ERRORES VALUES ('REFERENCIA_NO_ENCONTRADA', 'EXECEPCION DURANTE LA EJECUCION DE
            ABRIR CUENTA EN PK_CUENTAS: CUENTA DE REFERENCIA NO ENCONTRADA',
            SYSDATE);
            COMMIT;
            RAISE REFERENCIA_NO_ENCONTRADA;
    
    
    END;
    
    PROCEDURE CIERRE_CUENTA (IBANN VARCHAR2, TIPO_CUENTA VARCHAR2, IBAN_REFERENCIA VARCHAR2)
    IS
    
    FILA VARCHAR2(50);
   
    BEGIN
    
    SELECT COUNT(*) INTO FILA
    FROM CUENTA
    WHERE IBAN = IBANN;
    
    IF FILA != '1' THEN
        RAISE CUENTA_NO_ENCONTRADA;
    END IF;
    IF TIPO_CUENTA != 'POOLED' AND TIPO_CUENTA != 'SEGREGADA' THEN
        RAISE TIPO_NO_VALIDO;
    END IF;
    
    IF TIPO_CUENTA LIKE 'SEGREGADA' THEN
        SELECT COUNT(*) INTO FILA
        FROM REFERENCIA
        WHERE IBAN = IBAN_REFERENCIA AND SALDO >0;
        
        IF FILA LIKE '1' THEN
            RAISE SALDO_NO_CERO; 
        END IF;
        
        UPDATE FINTECH
        SET ESTADO = 'BAJA', FECHA_CIERRE = SYSDATE
        WHERE IBAN = IBANN;
    END IF;
    IF TIPO_CUENTA LIKE 'POOLED' THEN
        SELECT COUNT(*) INTO FILA
        FROM DEPOSITADA_EN
        WHERE POOLED_ACCOUNT_IBAN = IBANN AND REFERENCIA_IBAN = IBAN_REFERENCIA AND SALDO >0;
        
        IF FILA LIKE '0' THEN
            UPDATE FINTECH 
            SET ESTADO = 'BAJA', FECHA_CIERRE = SYSDATE
            WHERE IBAN = IBANN;
        ELSE
            RAISE SALDO_NO_CERO;
        END IF;
    END IF;
    
    COMMIT;
    
    EXCEPTION
        WHEN CUENTA_NO_ENCONTRADA THEN
            INSERT INTO LOG_ERRORES VALUES ('CUENTA_NO_ENCONTRADA', 'EXECEPCION DURANTE LA EJECUCION DE
            CERRAR CUENTA EN PK_CUENTAS: CUENTA NO ENCONTRADO',
            SYSDATE);
            COMMIT;
            RAISE CUENTA_NO_ENCONTRADA;
            
         WHEN TIPO_NO_VALIDO THEN
            INSERT INTO LOG_ERRORES VALUES ('TIPO_NO_VALIDO', 'EXECEPCION DURANTE LA EJECUCION DE
            CERRAR CUENTA EN PK_CUENTAS: TIPO DE CUENTA NO VALIDO',
            SYSDATE);
            COMMIT;
            RAISE TIPO_NO_VALIDO;
            
        WHEN SALDO_NO_CERO THEN
            INSERT INTO LOG_ERRORES VALUES ('SALDO_NO_CERO', 'EXECEPCION DURANTE LA EJECUCION DE
            CERRAR CUENTA EN PK_CUENTAS: EL SALDO DE LA CUENTA DEBE SER CERO',
            SYSDATE);
            COMMIT;
            RAISE SALDO_NO_CERO;
    
    END;
    
    
END PK_GESTION_CUENTAS;