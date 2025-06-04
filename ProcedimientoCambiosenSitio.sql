-- ANP con protección por debajo de los 800 m de profundidad hasta el fondo marino. El hábitat del ejemplar puede no extenderse hasta esa profundidad. El ejemplar se encuentra a 19,548 m. del municipio registrado.
-- actualizar el campo idregionoriginal y seguir este procedimineto (si hay cambios en la tabla regionoriginal)

/* Creamos la tabla con los ejemplares a actualizar */

DROP TABLE IF EXISTS snibdtap.po_ejemplarsitio;
DROP TABLE IF EXISTS snibdtap.po_agrupadollavesitiosnib;

create table snibdtap.po_ejemplarsitio
SELECT e.llaveejemplar,s.* FROM snibdtap.GeozeaperennisENTREGA p inner join snib.ejemplar_curatorial e on p.llaveejemplar=e.llaveejemplar
inner join snib.geografiaoriginal s on e.llavesitio=s.llavesitio;

ALTER TABLE `snibdtap`.`po_ejemplarsitio` ADD COLUMN ejemplares int,
ADD COLUMN `llavesitio_new` VARCHAR(32) AFTER `ejemplares`,
ADD INDEX `Index_1`(`llaveejemplar`),
ADD INDEX `Index_2`(`llavesitio_new`);
 
 /*Actualizamos los campos necesarios, esta consulta cambia cada que se requiere un cambio, porque siempre son campos
 diferentes los que se actualizan. La tabla que tiene la informacion a actualizar debe de contar con el campo ultimafechaactualizacion ya actualizado,
para este ejemplo la tabla es po_ejemplarregionsitio */
 
update snibdtap.po_ejemplarsitio p inner join snibdtap.GeozeaperennisENTREGA m on p.llaveejemplar=m.llaveejemplar
set p.idregionoriginal=m.idregionoriginal,
p.ultimafechaactualizacion="2021-08-27",
p.fechaactualizacion=current_timestamp;

update snibdtap.po_ejemplarsitio
set llavesitio_new = MD5(concat(
ifnull(idregionoriginal,'n'),
ifnull(latitudgrados,'n'), 
ifnull(latitudminutos,'n'), 
ifnull(latitudsegundos,'n'),
ifnull(longitudgrados,'n'),
ifnull(longitudminutos,'n'),
ifnull(longitudsegundos,'n'),
ifnull(latitudgradosfinal,'n'),
ifnull(latitudminutosfinal,'n'),
ifnull(latitudsegundosfinal,'n'),
ifnull(longitudgradosfinal,'n'),
ifnull(longitudminutosfinal,'n'),
ifnull(longitudsegundosfinal,'n'),
fuentemapagacetlitetiq, geoposmapagacetlitetiq, precisionoescala,
ifnull(radio,'n'), 
ifnull(altitudinicialdelsitio,'n'),
ifnull(altitudfinaldelsitio,'n'),
datum,tipositio,nortesur,esteoeste,ifnull(coordenadaoriginal,'n'),utm_longitud,utm_latitud,utm_zona));

/*Verificar que lo que vamos a agregar no existe enla tabla sitio*/

select  count(1) from snibdtap.po_ejemplarsitio p inner join snib.geografiaoriginal s
on p.llavesitio_new=s.llavesitio;

update snibdtap.po_ejemplarsitio p inner join snib.geografiaoriginal s
on p.llavesitio_new=s.llavesitio
set p.ejemplares=1;


/* Agregamos los nuevos registros de sitio, ojo con el valor de ultimafechaactualizacion, igual y se
tiene que ingresar el dato a mano en el qry. */
insert into snib.geografiaoriginal(llavesitio,idregionoriginal,latitudgrados,latitudminutos,latitudsegundos,longitudgrados,longitudminutos,longitudsegundos,
latitudgradosfinal,latitudminutosfinal,latitudsegundosfinal,longitudgradosfinal,longitudminutosfinal,longitudsegundosfinal,
fuentemapagacetlitetiq,geoposmapagacetlitetiq,precisionoescala,radio,altitudinicialdelsitio,altitudfinaldelsitio,
datum,tipositio,nortesur,esteoeste,coordenadaoriginal,utm_longitud,utm_latitud,utm_zona,ultimafechaactualizacion,version,fechaactualizacion)
select llavesitio_new,idregionoriginal,latitudgrados,latitudminutos,latitudsegundos,longitudgrados,longitudminutos,longitudsegundos,
latitudgradosfinal,latitudminutosfinal,latitudsegundosfinal,longitudgradosfinal,longitudminutosfinal,longitudsegundosfinal,
fuentemapagacetlitetiq,geoposmapagacetlitetiq,precisionoescala,radio,altitudinicialdelsitio,altitudfinaldelsitio,
datum,tipositio,nortesur,esteoeste,coordenadaoriginal,utm_longitud,utm_latitud,utm_zona,max(ultimafechaactualizacion),max(version),max(fechaactualizacion) from snibdtap.po_ejemplarsitio
where ejemplares is null group by llavesitio_new;

update snib.ejemplar_curatorial e inner join snibdtap.po_ejemplarsitio p on p.llaveejemplar=e.llaveejemplar
set e.llavesitio=p.llavesitio_new;

/* Para eliminar los sitios que quedan huerfanos*/

use snib;

create table snibdtap.po_agrupadollavesitiosnib
select distinct llavesitio from snib.ejemplar_curatorial;

alter table snibdtap.po_agrupadollavesitiosnib ADD INDEX Index_1(llavesitio);

DELETE s.* FROM snib.geografiaoriginal s left join snibdtap.po_agrupadollavesitiosnib e on s.llavesitio=e.llavesitio
where e.llavesitio is null;