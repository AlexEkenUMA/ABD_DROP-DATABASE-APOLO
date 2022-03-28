-- Generado por Oracle SQL Developer Data Modeler 21.4.2.059.0838
--   en:        2022-03-28 15:01:16 CEST
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE autorización (
    tipo                  VARCHAR2(50) NOT NULL,
    persona_autorizada_id INTEGER NOT NULL,
    empresa_id            INTEGER NOT NULL
);

ALTER TABLE autorización ADD CONSTRAINT autorización_pk PRIMARY KEY ( persona_autorizada_id,
                                                                      empresa_id );

CREATE TABLE cliente (
    id             INTEGER NOT NULL,
    identificacion VARCHAR2(50) NOT NULL,
    tipo_cliente   VARCHAR2(50) NOT NULL,
    estado         VARCHAR2(50) NOT NULL,
    fecha_alta     DATE NOT NULL,
    fecha_baja     DATE,
    direccion      VARCHAR2(100) NOT NULL,
    ciudad         VARCHAR2(50) NOT NULL,
    codigopostal   INTEGER NOT NULL,
    pais           VARCHAR2(50 CHAR) NOT NULL
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id );

ALTER TABLE cliente ADD CONSTRAINT cliente_identificacion_un UNIQUE ( identificacion );

CREATE TABLE cuenta (
    iban  VARCHAR2(34 CHAR) NOT NULL,
    swift VARCHAR2(11 CHAR)
);

ALTER TABLE cuenta ADD CONSTRAINT cuenta_pk PRIMARY KEY ( iban );

CREATE TABLE depositada_en (
    saldo               NUMBER NOT NULL,
    pooled_account_iban VARCHAR2(34 CHAR) NOT NULL,
    referencia_iban     VARCHAR2(34 CHAR) NOT NULL
);

ALTER TABLE depositada_en ADD CONSTRAINT depositada_en_pk PRIMARY KEY ( pooled_account_iban,
                                                                        referencia_iban );

CREATE TABLE divisa (
    abreviatura VARCHAR2(15 CHAR) NOT NULL,
    nombre      VARCHAR2(30 CHAR) NOT NULL,
    simbolo     CHAR(20),
    cambioeuro  NUMBER NOT NULL
);

ALTER TABLE divisa ADD CONSTRAINT divisa_pk PRIMARY KEY ( abreviatura );

CREATE TABLE empresa (
    id           INTEGER NOT NULL,
    razon_social VARCHAR2(50) NOT NULL
);

ALTER TABLE empresa ADD CONSTRAINT empresa_pk PRIMARY KEY ( id );

CREATE TABLE fintech (
    iban           VARCHAR2(34 CHAR) NOT NULL,
    estado         VARCHAR2(20 CHAR) NOT NULL,
    fecha_apertura DATE NOT NULL,
    fecha_cierre   DATE,
    clasificacion  VARCHAR2(50),
    cliente_id     INTEGER NOT NULL
);

ALTER TABLE fintech ADD CONSTRAINT fintech_pk PRIMARY KEY ( iban );

CREATE TABLE individual (
    id               INTEGER NOT NULL,
    nombre           VARCHAR2(30 CHAR) NOT NULL,
    apellido         VARCHAR2(30 CHAR) NOT NULL,
    fecha_nacimiento DATE
);

ALTER TABLE individual ADD CONSTRAINT individual_pk PRIMARY KEY ( id );

CREATE TABLE operacion (
    id                    VARCHAR2(50) NOT NULL,
    fecha_op              DATE NOT NULL,
    concepto              VARCHAR2(100),
    nombre_emisor         VARCHAR2(50),
    tipo_emisor           VARCHAR2(50),
    cantidad              NUMBER NOT NULL,
    modo_operacion        VARCHAR2(50),
    tarjeta_nº_de_tarjeta VARCHAR2(50) NOT NULL
);

ALTER TABLE operacion ADD CONSTRAINT operacion_pk PRIMARY KEY ( id );

CREATE TABLE persona_autorizada (
    id               INTEGER NOT NULL,
    identificacion   VARCHAR2(50) NOT NULL,
    nombre           VARCHAR2(30 CHAR) NOT NULL,
    apellidos        VARCHAR2(30 CHAR) NOT NULL,
    direccion        VARCHAR2(100) NOT NULL,
    fecha_nacimiento DATE,
    estado           VARCHAR2(50 CHAR),
    fechainicio      DATE,
    fechafin         DATE
);

ALTER TABLE persona_autorizada ADD CONSTRAINT persona_autorizada_pk PRIMARY KEY ( id );

ALTER TABLE persona_autorizada ADD CONSTRAINT per_auto_ident_un UNIQUE ( identificacion );

CREATE TABLE pooled_account (
    iban VARCHAR2(34 CHAR) NOT NULL
);

ALTER TABLE pooled_account ADD CONSTRAINT pooled_account_pk PRIMARY KEY ( iban );

CREATE TABLE referencia (
    iban               VARCHAR2(34 CHAR) NOT NULL,
    nombrebanco        VARCHAR2(50 CHAR) NOT NULL,
    sucursal           VARCHAR2(50 CHAR),
    pais               VARCHAR2(50 CHAR),
    saldo              NUMBER NOT NULL,
    fecha_apertura     DATE,
    estado             VARCHAR2(20 CHAR),
    divisa_abreviatura VARCHAR2(15 CHAR) NOT NULL
);

ALTER TABLE referencia ADD CONSTRAINT referencia_pk PRIMARY KEY ( iban );

CREATE TABLE relation_18 (
    operacion_id       VARCHAR2(50) NOT NULL,
    divisa_abreviatura VARCHAR2(15 CHAR) NOT NULL
);

ALTER TABLE relation_18 ADD CONSTRAINT relation_18_pk PRIMARY KEY ( operacion_id,
                                                                    divisa_abreviatura );

CREATE TABLE segregada (
    iban     VARCHAR2(34 CHAR) NOT NULL,
    comision NUMBER
);

ALTER TABLE segregada ADD CONSTRAINT segregada_pk PRIMARY KEY ( iban );

CREATE TABLE tarjeta (
    nº_de_tarjeta      VARCHAR2(50) NOT NULL,
    nombre_propietario VARCHAR2(50) NOT NULL,
    caducidad          DATE NOT NULL,
    ccv                NUMBER NOT NULL,
    f_activacion       DATE NOT NULL,
    cliente_id         INTEGER NOT NULL,
    modo_por_defecto   VARCHAR2(50),
    fintech_iban       VARCHAR2(34 CHAR) NOT NULL,
    limite_fisicos     NUMBER,
    limite_online      NUMBER,
    limite_cajero      NUMBER
);

ALTER TABLE tarjeta ADD CONSTRAINT tarjeta_pk PRIMARY KEY ( nº_de_tarjeta );

CREATE TABLE transaccion (
    id_único            INTEGER NOT NULL,
    fechainstrucción    DATE NOT NULL,
    cantidad            INTEGER NOT NULL,
    fechaejecución      DATE,
    tipo                VARCHAR2(50) NOT NULL,
    comision            NUMBER,
    internacional       CHAR(1),
    cuenta_iban         VARCHAR2(34 CHAR) NOT NULL,
    cuenta_iban2        VARCHAR2(34 CHAR) NOT NULL,
    divisa_abreviatura2 VARCHAR2(15 CHAR) NOT NULL,
    divisa_abreviatura  VARCHAR2(15 CHAR) NOT NULL
);

ALTER TABLE transaccion ADD CONSTRAINT transaccion_pk PRIMARY KEY ( id_único );

ALTER TABLE autorización
    ADD CONSTRAINT aut_empresa_fk FOREIGN KEY ( empresa_id )
        REFERENCES empresa ( id );

ALTER TABLE autorización
    ADD CONSTRAINT aut_persona_autorizada_fk FOREIGN KEY ( persona_autorizada_id )
        REFERENCES persona_autorizada ( id );

ALTER TABLE depositada_en
    ADD CONSTRAINT dep_en_pooled_account_fk FOREIGN KEY ( pooled_account_iban )
        REFERENCES pooled_account ( iban );

ALTER TABLE depositada_en
    ADD CONSTRAINT dep_en_referencia_fk FOREIGN KEY ( referencia_iban )
        REFERENCES referencia ( iban );

ALTER TABLE empresa
    ADD CONSTRAINT empresa_cliente_fk FOREIGN KEY ( id )
        REFERENCES cliente ( id );

ALTER TABLE fintech
    ADD CONSTRAINT fintech_cliente_fk FOREIGN KEY ( cliente_id )
        REFERENCES cliente ( id );

ALTER TABLE fintech
    ADD CONSTRAINT fintech_cuenta_fk FOREIGN KEY ( iban )
        REFERENCES cuenta ( iban );

ALTER TABLE individual
    ADD CONSTRAINT individual_cliente_fk FOREIGN KEY ( id )
        REFERENCES cliente ( id );

ALTER TABLE operacion
    ADD CONSTRAINT operacion_tarjeta_fk FOREIGN KEY ( tarjeta_nº_de_tarjeta )
        REFERENCES tarjeta ( nº_de_tarjeta );

ALTER TABLE pooled_account
    ADD CONSTRAINT pooled_account_fintech_fk FOREIGN KEY ( iban )
        REFERENCES fintech ( iban );

ALTER TABLE referencia
    ADD CONSTRAINT referencia_cuenta_fk FOREIGN KEY ( iban )
        REFERENCES cuenta ( iban );

ALTER TABLE referencia
    ADD CONSTRAINT referencia_divisa_fk FOREIGN KEY ( divisa_abreviatura )
        REFERENCES divisa ( abreviatura );

ALTER TABLE relation_18
    ADD CONSTRAINT relation_18_divisa_fk FOREIGN KEY ( divisa_abreviatura )
        REFERENCES divisa ( abreviatura );

ALTER TABLE relation_18
    ADD CONSTRAINT relation_18_operacion_fk FOREIGN KEY ( operacion_id )
        REFERENCES operacion ( id );

ALTER TABLE segregada
    ADD CONSTRAINT segregada_fintech_fk FOREIGN KEY ( iban )
        REFERENCES fintech ( iban );

ALTER TABLE tarjeta
    ADD CONSTRAINT tarjeta_cliente_fk FOREIGN KEY ( cliente_id )
        REFERENCES cliente ( id );

ALTER TABLE tarjeta
    ADD CONSTRAINT tarjeta_fintech_fk FOREIGN KEY ( fintech_iban )
        REFERENCES fintech ( iban );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_cuenta_fk FOREIGN KEY ( cuenta_iban )
        REFERENCES cuenta ( iban );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_cuenta_fkv2 FOREIGN KEY ( cuenta_iban2 )
        REFERENCES cuenta ( iban );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_divisa_fk FOREIGN KEY ( divisa_abreviatura )
        REFERENCES divisa ( abreviatura );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_divisa_fkv2 FOREIGN KEY ( divisa_abreviatura2 )
        REFERENCES divisa ( abreviatura );

CREATE OR REPLACE TRIGGER arc_fkarc_3_fintech BEFORE
    INSERT OR UPDATE OF iban ON fintech
    FOR EACH ROW
DECLARE
    d VARCHAR2(34 CHAR);
BEGIN
    SELECT
        a.iban
    INTO d
    FROM
        cuenta a
    WHERE
        a.iban = :new.iban;

    IF ( d IS NULL OR d <> 'IBAN' ) THEN
        raise_application_error(-20223, 'FK FINTECH_CUENTA_FK in Table FINTECH violates Arc constraint on Table CUENTA - discriminator column IBAN doesn''t have value ''IBAN''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_3_referencia BEFORE
    INSERT OR UPDATE OF iban ON referencia
    FOR EACH ROW
DECLARE
    d VARCHAR2(34 CHAR);
BEGIN
    SELECT
        a.iban
    INTO d
    FROM
        cuenta a
    WHERE
        a.iban = :new.iban;

    IF ( d IS NULL OR d <> 'IBAN' ) THEN
        raise_application_error(-20223, 'FK REFERENCIA_CUENTA_FK in Table REFERENCIA violates Arc constraint on Table CUENTA - discriminator column IBAN doesn''t have value ''IBAN''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_2_segregada BEFORE
    INSERT OR UPDATE OF iban ON segregada
    FOR EACH ROW
DECLARE
    d VARCHAR2(34 CHAR);
BEGIN
    SELECT
        a.iban
    INTO d
    FROM
        fintech a
    WHERE
        a.iban = :new.iban;

    IF ( d IS NULL OR d <> 'IBAN' ) THEN
        raise_application_error(-20223, 'FK SEGREGADA_FINTECH_FK in Table SEGREGADA violates Arc constraint on Table FINTECH - discriminator column IBAN doesn''t have value ''IBAN''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_2_pooled_account BEFORE
    INSERT OR UPDATE OF iban ON pooled_account
    FOR EACH ROW
DECLARE
    d VARCHAR2(34 CHAR);
BEGIN
    SELECT
        a.iban
    INTO d
    FROM
        fintech a
    WHERE
        a.iban = :new.iban;

    IF ( d IS NULL OR d <> 'IBAN' ) THEN
        raise_application_error(-20223, 'FK POOLED_ACCOUNT_FINTECH_FK in Table POOLED_ACCOUNT violates Arc constraint on Table FINTECH - discriminator column IBAN doesn''t have value ''IBAN''');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_1_individual BEFORE
    INSERT OR UPDATE OF id ON individual
    FOR EACH ROW
DECLARE
    d INTEGER;
BEGIN
    SELECT
        a.id
    INTO d
    FROM
        cliente a
    WHERE
        a.id = :new.id;

    IF ( d IS NULL OR d <> id ) THEN
        raise_application_error(-20223, 'FK INDIVIDUAL_CLIENTE_FK in Table INDIVIDUAL violates Arc constraint on Table CLIENTE - discriminator column ID doesn''t have value ID');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER arc_fkarc_1_empresa BEFORE
    INSERT OR UPDATE OF id ON empresa
    FOR EACH ROW
DECLARE
    d INTEGER;
BEGIN
    SELECT
        a.id
    INTO d
    FROM
        cliente a
    WHERE
        a.id = :new.id;

    IF ( d IS NULL OR d <> id ) THEN
        raise_application_error(-20223, 'FK EMPRESA_CLIENTE_FK in Table EMPRESA violates Arc constraint on Table CLIENTE - discriminator column ID doesn''t have value ID');
    END IF;

EXCEPTION
    WHEN no_data_found THEN
        NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            16
-- CREATE INDEX                             0
-- ALTER TABLE                             39
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           6
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
