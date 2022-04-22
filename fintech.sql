create table cotizacion_ext (Nombre NVARCHAR2(50), Fecha NVARCHAR2(50), Valor1Euro NVARCHAR2(50), VariacionPorc NVARCHAR2(50), VariacionMes NVARCHAR2(50), VariacionAño NVARCHAR2(50), ValorenEuros NVARCHAR2(50))
    organization external
    ( default directory directorio_ext access parameters
         ( records delimited by newline  
          skip 1 
          characterset WE8ISO8859P1 
           fields terminated by ';' 
         )
         location ('cotizacion.csv')   
     );

--leer 
select * from cotizacion_ext;

--modificar
update cotizacion_ext set VALOR1EURO='69.00' where nombre='Kwachas zambianos';

--insertar datos
insert into cotizacion_ext values ('PESETA','21/04/2022', '166', '0,69%', '1,23%', '2,71%', '0,006');

--NO podemos insertar ni modificar, estas operaciones no es permitida en tablas externas.

--Apartado 4-8
select d.abreviatura, d.nombre, d.simbolo, to_number( c.valoreneuros), to_date 
(fecha,'dd/mm/yyyy') from cotizacion_ext c join divisa d on c.nombre = 
d.nombre; 
create view v_cotizaciones as select d.abreviatura, d.nombre, d.simbolo, 
to_number( c.valoreneuros) cambioeuro, to_date (fecha,'dd/mm/yyyy') fecha 
from cotizacion_ext c join divisa d on c.nombre = d.nombre 
where (d.nombre,to_date (fecha,'dd/mm/yyyy')) in (select nombre, max ( to_date 
(fecha,'dd/mm/yyyy')) from cotizacion_ext group by nombre);

--6. ÍNDICES

select * from user_indexes;

create index estado_idx on cliente (ESTADO)
    tablespace TS_INDICES;
    
    create index tipo_cliente_idx on cliente (TIPO_CLIENTE)
    tablespace TS_INDICES;
    
create index upper_identificacion_idx on cliente (upper(IDENTIFICACION))
    tablespace TS_INDICES;

--La clave primaria de cliente es ID

--Cliente se almacena en la tablespace TS_FINTECH y los índices en TS_INDICES
SELECT TABLE_NAME, TABLESPACE_NAME FROM USER_TABLES WHERE TABLE_NAME='CLIENTE';
SELECT TABLE_NAME, TABLESPACE_NAME FROM USER_INDEXES;
SELECT TABLE_NAME, TABLESPACE_NAME FROM USER_INDEXES WHERE TABLE_NAME='CLIENTE';

create bitmap index divisa_abreviatura_idx on referencia (divisa_abreviatura)
    tablespace TS_INDICES;
    
SELECT INDEX_NAME,INDEX_TYPE,TABLESPACE_NAME FROM USER_INDEXES where INDEX_TYPE='BITMAP';

--6. VISTA MATERIALIZADA

create materialized view VM_COTIZA 
refresh force on demand start with (sysdate) next (sysdate + 1) as 
select nombre, valor1euro, valoreneuros from cotizacion_ext;

select * from VM_COTIZA;

--7. SINÓNIMOS

--CRAR SINONIMO PUBLICO
create public synonym cotizacion for VM_COTIZA;


     
