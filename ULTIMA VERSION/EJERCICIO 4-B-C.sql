
--4 B

CREATE OR REPLACE PROCEDURE P_REEMPLAZO IS
    
    BEGIN
    
    UPDATE DIVISA D SET D.CAMBIOEURO = (SELECT VALORENEUROS FROM VM_COTIZA V
                                        WHERE V.NOMBRE = D.NOMBRE);
   
    END;
/



BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
    job_name            =>  'J_CAMBIO_EURO',
    job_type            =>  'PLSQL_BLOCK', --procedimiento
    job_action          =>  'BEGIN EXECUTE P_REEMPLAZO; END; ',
    start_date          =>  sysdate,
    repeat_interval     =>  'FREQ=DAILY; BYHOUR=00; BYMINUTE=5',
    enabled             =>  TRUE,
    comments            =>  'ACTUALIZA LA COLUMNA DE CAMBIOEURO DE DIVISAS USANDO COMO REFERENCIA EL DE LA VISTA DE COTIZACIONES');
END;
/


--4C



CREATE OR REPLACE PROCEDURE P_COBRO_APALZADO 
IS 
    CURSOR COBRO IS 
    SELECT  O.TARJETA_N_DE_TARJETA, O.MODO_OPERACION, O.ESTADO, O.ID, O.DIVISA_ABREVIATURA, O.CANTIDAD
    FROM OPERACION O;
    COBRO_REC COBRO%ROWTYPE;
    
    CUENTA VARCHAR2 (50);
    POOLED VARCHAR2(50);
    SEGREGADA VARCHAR2(50);
    REFERENCIA VARCHAR2(50);
    DEPOSITO VARCHAR2(50);
    
    BEGIN 
    FOR COBRO_REC IN COBRO 
    LOOP
    BEGIN
        IF ((COBRO_REC.MODO_OPERACION LIKE 'CREDITO' OR COBRO_REC.MODO_OPERACION LIKE 'APLAZADO') AND COBRO_REC.ESTADO LIKE 'PENDIENTE') THEN
            
            UPDATE OPERACION
            SET ESTADO = 'COBRADO'
            WHERE ID = COBRO_REC.ID;
            
            SELECT FINTECH_IBAN INTO CUENTA FROM TARJETA
            WHERE N_DE_TARJETA = COBRO_REC.TARJETA_N_DE_TARJETA;
            
            SELECT COUNT(*) INTO SEGREGADA FROM FINTECH 
            WHERE IBAN = CUENTA AND CLASIFICACION = 'SEGREGADA';
            
            IF SEGREGADA LIKE '1' THEN
                SELECT IBAN_CUENTAREF INTO REFERENCIA FROM SEGREGADA
                WHERE IBAN = CUENTA;
                
                UPDATE REFERENCIA 
                SET SALDO = SALDO - COBRO_REC.CANTIDAD
                WHERE IBAN = REFERENCIA;
            END IF;
            
            SELECT COUNT(*) INTO POOLED FROM FINTECH 
            WHERE IBAN = CUENTA AND CLASIFICACION = 'POOLED';
            
            IF POOLED LIKE '1' THEN
               
                SELECT R.IBAN INTO REFERENCIA FROM DEPOSITADA_EN D, REFERENCIA R
                WHERE D.POOLED_ACCOUNT_IBAN = CUENTA AND D.REFERENCIA_IBAN = R.IBAN  AND R.DIVISA_ABREVIATURA = COBRO_REC.DIVISA_ABREVIATURA;
                
                UPDATE DEPOSITADA_EN D
                SET SALDO = SALDO - COBRO_REC.CANTIDAD
                WHERE D.POOLED_ACCOUNT_IBAN = CUENTA AND D.REFERENCIA_IBAN = REFERENCIA;
                
                UPDATE REFERENCIA R 
                SET SALDO = SALDO - COBRO_REC.CANTIDAD
                WHERE R.IBAN = REFERENCIA;
            END IF;
        END IF;
        COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                INSERT INTO LOG_ERRORES VALUES ('OTHERS', 'EXECEPCION DURANTE LA EJECUCIÓN DE
                P_COBRO',
                SYSDATE);
                COMMIT;          
    END;
    END LOOP; 
    END;

/
