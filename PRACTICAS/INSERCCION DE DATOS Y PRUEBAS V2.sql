
insert into cliente values (6, '123456789N', 'FISICO', 'ACTIVO', 
    SYSDATE, NULL, 'ETSI', 'MALAGA', 29640, 'ESPA�A');

INSERT INTO INDIVIDUAL VALUES (6, 'JOSE', 'PAN',SYSDATE);

COMMIT;



--CUENTAS


INSERT INTO CUENTA VALUES ('1', NULL);

INSERT INTO FINTECH VALUES ('1', 'ACTIVA', SYSDATE, NULL, 'SEGREGADA', 6);


INSERT INTO REFERENCIA VALUES ('123ES', 'EBURY', 'MALAGA', 'ESPA�A', 100, SYSDATE,
    'ACTIVA', 'EUR');
    
COMMIT;

INSERT INTO SEGREGADA VALUES ('1', 5, '123ES');

COMMIT;

--PRUEBA PAQUETE CLIENTES

--DAR_ALTA


--PRUEBA OKAY DAR _ALTA
EXEC PK_GESTION_CLIENTES.DAR_ALTA (10, '79056080C', 'FISICO', 'ACTIVO', SYSDATE, NULL, 
    'CALLE','MALAGA', 29649, 'ESPA�A', NULL, 'ALE', 'REQUE', SYSDATE);
    
--PRUEBA FALLA POR TIPO --> DAR_ALTA
EXEC PK_GESTION_CLIENTES.DAR_ALTA (15, '7905608C', 'NEPE', 'ACTIVO', SYSDATE, NULL, 'CALLE','MALAGA', 29649, 'ESPA�A', NULL, 'ALE', 'REQUE', SYSDATE); 

--PRUEBA CLIENYE YA ESTA --> DAR_ALATA

EXEC PK_GESTION_CLIENTES.DAR_ALTA (10, '79056080C', 'FISICO', 'ACTIVO', SYSDATE, NULL,  'CALLE','MALAGA', 29649, 'ESPA�A', NULL, 'ALE', 'REQUE', SYSDATE);

--MODIFICAR_CLIENTE

--PRUEBA CLIENTE MODIFICADO OKAY 

EXEC PK_GESTION_CLIENTES.MODIFICAR_CLIENTE (10, 'FISICO', 'ACTIVO', NULL, NULL, 'PASTEUR', 'MALAGA', 29640, 'ESPA�A', NULL, 'ALEJANDRO', 'REQUENA', SYSDATE);


--PRUEBA CLIENTE NO EXISTENTE

EXEC PK_GESTION_CLIENTES.MODIFICAR_CLIENTE (100, 'FISICO', 'ACTIVO', NULL, NULL, 'PASTEUR', 'MALAGA', 29640, 'ESPA�A', NULL, 'ALEJANDRO', 'REQUENA', SYSDATE);


--BAJA CLIENTE

--PRUEBA CLIENTE NO ENCONTRADO

EXEC PK_GESTION_CLIENTES.BAJA_CLIENTE (100);

--PRUEBA CUENTAS ABIERTAS

EXEC PK_GESTION_CLIENTES.BAJA_CLIENTE (6);

--PRUEBA OKAY

EXEC PK_GESTION_CLIENTES.BAJA_CLIENTE (10);




--ANADIR AUTORIZADOS 

--PRUEBA CLIENTE_NO_ENCONTRADO
EXEC PK_GESTION_CLIENTES.ANADIR_AUTORIZADOS(2, 1, 'CONSULTA', '123456789A', 'JOSE', 'PAN', 'AVND ING', SYSDATE, 'ACTIVO', SYSDATE, NULL);

--PRUEBA TIPO_AUTORIZACION NO VALIDA

EXEC PK_GESTION_CLIENTES.ANADIR_AUTORIZADOS(3, 2, 'ROBAR', '123456789A', 'JOSE', 'PAN', 'AVND ING', SYSDATE, 'ACTIVO', SYSDATE, NULL);

--PRUEBA CORRECTA AUTORIZADO NO EN TABLA

EXEC PK_GESTION_CLIENTES.ANADIR_AUTORIZADOS(3, 2, 'OPERACION', '123456789B', 'JOSE', 'PAN', 'AVND ING', SYSDATE, 'ACTIVO', SYSDATE, NULL);

--PRUBEA CORRECTA AUTORIZADO EN TABLA

EXEC PK_GESTION_CLIENTES.ANADIR_AUTORIZADOS(15, 1, 'OPERACION', '123456789B', 'JOSE', 'PAN', 'AVND ING', SYSDATE, 'ACTIVO', SYSDATE, NULL);


--MODIFICAR PERSONA_AUTORIZADA

--AUTORIZADO_NO_ENCONTRADO

EXEC PK_GESTION_CLIENTES.MODIFICAR_PERSONA_AUTORIZADA(10, 'ALEJANDRO', 'REQUENA', 'LARIOS', SYSDATE, 'ACTIVO', SYSDATE, NULL, 'OPERACION');


--PRUEBA OKAY
EXEC PK_GESTION_CLIENTES.MODIFICAR_PERSONA_AUTORIZADA(2, 'ALE', 'REQUENA', 'LARIOS', SYSDATE, 'ACTIVO', SYSDATE, NULL, 'OPERACION');


--ELIMINAR AUTORIZADOS


--PRUEBA AUTORIZADO NO ENCONTRADO

EXEC  PK_GESTION_CLIENTES.ELIMINAR_AUTORIZADO(3,3);

--PRUEBA OKAY
EXEC  PK_GESTION_CLIENTES.ELIMINAR_AUTORIZADO(1,3);

--PRUEBA BORRADO DE PERSONA AUT
EXEC  PK_GESTION_CLIENTES.ELIMINAR_AUTORIZADO(2,3);





--PAQUETE CUENTAS


--PRUEBA TIPO NO VALIDO

EXEC PK_GESTION_CUENTAS.ABRIR_CUENTA ('PRUEBA1ES', NULL, 'XD', 1, 'XD', '123ES', 5);

--PRUEBA CLIENTE BAJA

EXEC PK_GESTION_CUENTAS.ABRIR_CUENTA ('PRUEBA1ES', NULL, 'SEGREGADA', 10, 'SEGREGADA', '123ES', 5);

--PRUEBA REFERENCIA NO VALIDA

EXEC PK_GESTION_CUENTAS.ABRIR_CUENTA ('PRUEBA1ES', NULL, 'SEGREGADA', 10, 'SEGREGADA', '1234ES', 5);

--PRUEBA SEGREGADA OKAY

EXEC PK_GESTION_CUENTAS.ABRIR_CUENTA ('PRUEBA1ES', NULL, 'SEGREGADA', 1, 'SEGREGADA', '123ES', 5);


--PRUEBA POOLED OKAY

EXEC PK_GESTION_CUENTAS.ABRIR_CUENTA ('PRUEBA2ES', NULL, 'POOLED', 1, 'POOLED', '123ES', NULL);


--CIERRE CUENTA

--PRUEBA CUENTA NO ENCONTRADA

EXEC PK_GESTION_CUENTAS.CIERRE_CUENTA('1E', 'POOLED', '123ES');

--PRUEBA SALDO NO CERO

EXEC PK_GESTION_CUENTAS.CIERRE_CUENTA('PRUEBA1ES', 'SEGREGADA', '123ES');

--PRUEBA OKAY SEGREGADA

EXEC PK_GESTION_CUENTAS.CIERRE_CUENTA('PRUEBACERO', 'SEGREGADA', '1ES');

--PRUEBA OKAY POOLED

EXEC PK_GESTION_CUENTAS.CIERRE_CUENTA('PRUEBA2ES', 'POOLED', '123ES');





