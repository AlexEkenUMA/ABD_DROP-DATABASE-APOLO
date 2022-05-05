--MIEMBROS DEL GRUPO
--ALEJANDRO REQUENA GARCÍA
--MIQUEL MARTÍNEZ LÓPEZ
--JOSE MARÍA PAN ROSADO
--ISMAEL GARCÍA ZAMUDIO
--1. CREACIÓN DEL USUARIO Y TABLESPACE
--CREAMOS TABLESPACE TS_FINTECH
create tablespace TS_FINTECH datafile 'fintech.dbf' size 10M autoextend on;

--CREAMOS TABLESPACE TS_INDICES
create tablespace TS_INDICES datafile 'indices.dbf' size 50M autoextend on;

--CREAR USUARIO FINTECH Y ASIGNAR QUOTA
create user fintech identified by fintech
    default tablespace TS_FINTECH
    quota UNLIMITED on TS_INDICES
    quota UNLIMITED on TS_FINTECH;
    
--DAMOS PERMISOS AL USUARIO FINTECH
grant connect, create table, create view, create materialized view, create procedure, create sequence, create trigger to fintech;

--PARA VER TODOS LOS TABLESPACES CREADOS Y COMPROBAMOS QUE LOS TABLESPACES SE HAN CREADO CORRECTAMENTE
select * from DBA_Tablespaces;

--VER TABLESPACES POR DEFECTO DEL USUARIO fintech
select username, default_tablespace from dba_users where username='FINTECH';

--VER DATAFILES ASOCIADOS A LOS TABLESPACES TS_FINTECH Y TS_INDICES
select * from DBA_data_files where tablespace_name ='TS_FINTECH' or tablespace_name ='TS_INDICES';

--2. CREACIÓN DEL ESQUEMA
--HECHO

--3. IMPORTACIÓN DE DATOS 
--HECHO

--4. TABLAS EXTERNAS
create or replace directory directorio_ext as 'C:\Users\app\alumnos\admin\orcl\dpdump';
grant write, read on directory directorio_ext to fintech;

--5. ÍNDICES
--HECHO EN EL USUARIO FINTECH

--6. VISTA MATERIALIZADA
--HECHO EN EL USUARIO FINTECH

--7. SINÓNIMOS
--HECHO DESDE EL USUARIO FINTECH










