USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-27
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROC [Transporte].[spReporteBasicoResumenGeneralV2] 
(
    @IDUsuario	int = 1 ,  
    @FechaIni date ='2022-01-03',
    @FechaFin date ='2022-01-10'
          
) as

	SET FMTONLY OFF;


      
        declare @Count int
        declare @tempResponse as table (
                    [anio] INT ,
                    [mes] int,                
                    [dia] int ,
                    [Fecha]       date,
                    [IDReporteMovimiento]  VARCHAR (100),
                    [NameReporteMovimiento]  VARCHAR (100),
                    [Valor]      decimal(10,2)        ,
                    [TipoDato] VARCHAR (100) default '' ,                  
                    [Total]  Varchar(100) default '$10.00',                 
                    [Orden] int      ,
                    [Colums] int      ,
                    [IDReporteMovimientoPadre] VARCHAR (100) default ''                                        
                    
        );

        
        declare  @Fechas [App].[dtFechas]   
        insert @Fechas  
        exec app.spListaFechas @FechaIni =@FechaIni, @FechaFin = @FechaFin

                 
        insert into @tempResponse (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre)
        select Anio,Mes,Dia,Fecha,s.IDReporteMovimiento,s.DescripcionConcepto,s.Orden,s.IDReporteMovimientoPadre
        from Transporte.tblConceptosReporteGeneral s
        cross join @Fechas
    
        
        update t1  
        set t1.Valor=case when t1.IDReporteMovimiento in ('TotalVehiculosTipoDia','TotalVehiculosTipoKM') then isnull(ss.TotalVehiculos,0) 
                      else 2 end
        from  @tempResponse t1
        join (
                SELECT        
                    rp.Fecha,                    
                    count(rpv.IDRutaProgramadaVehiculo) [TotalVehiculos],
                    rpv.IDTipoCosto
                    
                FROM Transporte.tblRutasProgramadas rp
                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada
                    inner join Transporte.tblCatTipoCosto c on c.IDTipoCosto=rpv.IDTipoCosto
                group by rpv.IDTipoCosto ,rp.Fecha,c.Descripcion,Fecha
        )  ss on ss.Fecha=t1.Fecha and ss.IDTipoCosto = case  when t1.IDReporteMovimiento = 'TotalVehiculosTipoDia' then 2 else 1 end
         where t1.IDReporteMovimiento in ('TotalVehiculosTipoDia','TotalVehiculosTipoKM')

        update t1 set t1.Valor=tt.total
        from @tempResponse t1
        join (
            select Fecha, IDReporteMovimientoPadre,sum(isnull(tt.Valor,0)) [total] FROM @tempResponse tt
            group by Fecha,IDReporteMovimientoPadre 
        ) tt on tt.IDReporteMovimientoPadre=t1.IDReporteMovimiento and t1.Fecha=tt.Fecha
          
        select * From  @tempResponse
       /*
        
        update t1  set t1.Valor=1
        from  @tempResponse
        join (
                SELECT 
                    c.Descripcion,
                    count(rpv.IDRutaProgramadaVehiculo)  ,
                    sum(rpv.Capacidad) ,
                    Fecha       
                FROM Transporte.tblRutasProgramadas rp
                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada
                    inner join Transporte.tblCatTipoCosto c on c.IDTipoCosto=rpv.IDTipoCosto
                group by rpv.IDTipoCosto ,rp.Fecha,c.Descripcion,Fecha
        ) ON 
       */
        
        

        /*
        update t1  set t1.Valor =( SELECT count(rpv.IDRutaProgramadaVehiculo)        
                                    FROM Transporte.tblRutasProgramadas rp
                                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada WHERE rp.Fecha=t1.Fecha
                                    )
        FROM @tempResponse t1
        where t1.IDReporteMovimiento in ('TotalVehiculos')

        

        insert into @tempResponse  (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato,Valor)
        select anio,mes,dia,Fecha,'1','Vehículos (KM)',Orden,IDReporteMovimiento,'NumeroEntero',
                            ( SELECT count(rpv.IDRutaProgramadaVehiculo)        
                                    FROM Transporte.tblRutasProgramadas rp
                                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada
                                    inner join Transporte.tblCatVehiculos v on rpv.IDVehiculo=v.IDVehiculo 
                                     WHERE rp.Fecha=t1.Fecha and v.IDTipoCosto=1
                                )
        from @tempResponse t1
        where t1.IDReporteMovimiento in ('TotalVehiculos')

        insert into @tempResponse  (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato,Valor)
        select anio,mes,dia,Fecha,'2','Vehículos (Días)',Orden,IDReporteMovimiento,'NumeroEntero',
                            ( SELECT count(rpv.IDRutaProgramadaVehiculo)        
                                    FROM Transporte.tblRutasProgramadas rp
                                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada
                                    inner join Transporte.tblCatVehiculos v on rpv.IDVehiculo=v.IDVehiculo 
                                     WHERE rp.Fecha=t1.Fecha and v.IDTipoCosto=2
                                )
        from @tempResponse t1
        where t1.IDReporteMovimiento in ('TotalVehiculos')
        
        

        update t1  set t1.Valor =( SELECT isnull(sum(v.CantidadPasajeros),0)
                                    FROM Transporte.tblRutasProgramadas rp
                                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada 
                                    inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo
                                    WHERE rp.Fecha=t1.Fecha
                                    )
        FROM @tempResponse t1
        where t1.IDReporteMovimiento IN ('Capacidad' ,'Disponibilidad','Ocupacion')

    
        update t1  set t1.Valor =   ( SELECT count(ppd.IDRutaProgramadaPersonal)
                                                                                    FROM Transporte.tblRutasProgramadas rp                                    
                                                                                    left join Transporte.tblRutasProgramadasPersonal ppd on ppd.IDRutaProgramada=rp.IDRutaProgramada
                                                                                    WHERE rp.Fecha=t1.Fecha )
                                                                                
        FROM @tempResponse t1
        where t1.IDReporteMovimiento in ('Pasajeros')


        insert into @tempResponse  (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato,Valor)
        select anio,mes,dia,Fecha,'3','Sin Asignar',Orden,IDReporteMovimiento,'NumeroEntero',
                            (SELECT count(ppd.IDRutaProgramadaPersonal)
                                FROM Transporte.tblRutasProgramadas rp                                    
                                left join Transporte.tblRutasProgramadasPersonal ppd on ppd.IDRutaProgramada=rp.IDRutaProgramada                                
                                WHERE rp.Fecha=t1.Fecha  AND (SELECT count(s.IDRutaProgramadaVehiculo) from Transporte.tblRutasProgramadasVehiculos s where s.IDRutaProgramada=rp.IDRutaProgramada)=0
                            )
        from @tempResponse t1
        where t1.IDReporteMovimiento in ('Pasajeros')

        

        update t1  set t1.Valor =t1.Valor-(SELECT count(ppd.IDRutaProgramadaPersonal)
                                    FROM Transporte.tblRutasProgramadas rp                                    
                                    left join Transporte.tblRutasProgramadasPersonal ppd on ppd.IDRutaProgramada=rp.IDRutaProgramada                                
                                    WHERE rp.Fecha=t1.Fecha  AND (SELECT count(s.IDRutaProgramadaVehiculo) from Transporte.tblRutasProgramadasVehiculos s where s.IDRutaProgramada=rp.IDRutaProgramada)>0
                                )
        FROM @tempResponse t1
        where t1.IDReporteMovimiento IN ( 'Disponibilidad')

        

        insert into @tempResponse  (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato,Valor)
        select anio,mes,dia,Fecha,'4','Asignados',Orden,IDReporteMovimiento,'NumeroEntero',
                            (SELECT count(ppd.IDRutaProgramadaPersonal)
                                FROM Transporte.tblRutasProgramadas rp                                    
                                left join Transporte.tblRutasProgramadasPersonal ppd on ppd.IDRutaProgramada=rp.IDRutaProgramada                                
                                WHERE rp.Fecha=t1.Fecha  AND (SELECT count(s.IDRutaProgramadaVehiculo) from Transporte.tblRutasProgramadasVehiculos s where s.IDRutaProgramada=rp.IDRutaProgramada)>0
                            )
        from @tempResponse t1
        where t1.IDReporteMovimiento in ('Pasajeros')
        
        update t1  set t1.Valor =   (SELECT count(ppd.IDRutaProgramadaPersonal)
                                FROM Transporte.tblRutasProgramadas rp                                    
                                left join Transporte.tblRutasProgramadasPersonal ppd on ppd.IDRutaProgramada=rp.IDRutaProgramada                                
                                WHERE rp.Fecha=t1.Fecha  AND (SELECT count(s.IDRutaProgramadaVehiculo) from Transporte.tblRutasProgramadasVehiculos s where s.IDRutaProgramada=rp.IDRutaProgramada)>0
                            )
        FROM @tempResponse t1
        where t1.IDReporteMovimiento IN ( 'CostoPasajero')



        update t1  set t1.Valor = cast((SELECt case when (valor * 100) >0 then ((valor * 100) / t1.Valor)  else  0 end
                                        FROM @tempResponse t2 where t2.NameReporteMovimiento IN ( 'Asignados') and t2.Fecha=t1.Fecha) as decimal(10,2))                                                                    
                            ,Colums= (select  count(*) from @tempResponse where cast(Valor as decimal(10,2))>0 and IDReporteMovimiento='Ocupacion')
        FROM @tempResponse t1
        where t1.IDReporteMovimiento IN ( 'Ocupacion')

        

        


       update t1  set t1.Valor =( SELECT isnull(sum(r.KMRuta),0)
                                    FROM Transporte.tblRutasProgramadas rp
                                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada 
                                    inner join Transporte.tblCatRutas r on r.IDRuta=rp.IDRuta
                                    inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo
                                    WHERE rp.Fecha=t1.Fecha
                                    )
        FROM @tempResponse t1
        where t1.IDReporteMovimiento in('KMRecorridos')

        insert into @tempResponse  (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato,Valor)
        select anio,mes,dia,Fecha,'5','Vehículos (KM)',Orden,IDReporteMovimiento,'NumeroEntero',
                           ( SELECT isnull(sum(r.KMRuta),0)
                                    FROM Transporte.tblRutasProgramadas rp
                                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada 
                                    inner join Transporte.tblCatRutas r on r.IDRuta=rp.IDRuta
                                    inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo and v.IDTipoCosto=1
                                    WHERE rp.Fecha=t1.Fecha
                                    )
        from @tempResponse t1
        where t1.IDReporteMovimiento in ('KMRecorridos')

        insert into @tempResponse  (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato,Valor)
        select anio,mes,dia,Fecha,'6','Vehículos (Días)',Orden,IDReporteMovimiento,'NumeroEntero',
                          ( SELECT isnull(sum(r.KMRuta),0)
                                    FROM Transporte.tblRutasProgramadas rp
                                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada 
                                    inner join Transporte.tblCatRutas r on r.IDRuta=rp.IDRuta
                                    inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo and v.IDTipoCosto=2
                                    WHERE rp.Fecha=t1.Fecha
                            )
        from @tempResponse t1
        where t1.IDReporteMovimiento in ('KMRecorridos')
        

    

        update t1  set t1.Valor =isnull((  SELECT sum(v.CostoUnidad)
                                    FROM Transporte.tblRutasProgramadas rp
                                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada                                     
                                    inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo   and v.IDTipoCosto=2
                                    where rp.Fecha=t1.Fecha
                            ),0)+
                            isnull( (
                                SELECT sum(v.CostoUnidad)*max(r.KMRuta)
                                FROM Transporte.tblRutasProgramadas rp
                                inner join Transporte.tblCatRutas r on r.IDRuta=rp.IDRuta
                                inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada                                     
                                inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo   and v.IDTipoCosto=1
                                where rp.Fecha=t1.Fecha
                                
                            ),0)
        FROM @tempResponse t1
        where t1.IDReporteMovimiento ='CostoTotal'
        
          update t1  set t1.Valor = case when t1.Valor=0 then 0 else 

                                            (isnull((  SELECT sum(v.CostoUnidad)
                                                        FROM Transporte.tblRutasProgramadas rp
                                                        inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada                                     
                                                        inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo   and v.IDTipoCosto=2
                                                        where rp.Fecha=t1.Fecha
                                                    ),0)+
                                                    isnull( (
                                                        SELECT sum(v.CostoUnidad)*max(r.KMRuta)
                                                        FROM Transporte.tblRutasProgramadas rp
                                                        inner join Transporte.tblCatRutas r on r.IDRuta=rp.IDRuta
                                                        inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada                                     
                                                        inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo   and v.IDTipoCosto=1
                                                        where rp.Fecha=t1.Fecha
                                                        
                                                    ),0))/t1.Valor
                                        end 
                                ,Colums= (select  count(*) from @tempResponse where cast(Valor as decimal(10,2))>0 and IDReporteMovimiento='Ocupacion')
        FROM @tempResponse t1
        where t1.IDReporteMovimiento ='CostoPasajero'

        
    
        insert into @tempResponse  (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato,Valor)
        select anio,mes,dia,Fecha,'7','Total Costo KM ($)',Orden,IDReporteMovimiento,'Moneda',
                            isnull( (
                                SELECT sum(v.CostoUnidad*r.KMRuta)
                                FROM Transporte.tblRutasProgramadas rp
                                inner join Transporte.tblCatRutas r on r.IDRuta=rp.IDRuta
                                inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada                                     
                                inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo   and v.IDTipoCosto=1                                
                                where rp.Fecha=t1.Fecha
                                
                            ),0)
        from @tempResponse t1
        where t1.IDReporteMovimiento in ('CostoTotal')

        



        insert into @tempResponse  (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato,Valor)
        select anio,mes,dia,Fecha,'8','Total Costo Días ($)',Orden,IDReporteMovimiento,'Moneda',
                            isnull( (
                                SELECT sum(v.CostoUnidad)
                                FROM Transporte.tblRutasProgramadas rp
                                inner join Transporte.tblCatRutas r on r.IDRuta=rp.IDRuta
                                inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada                                     
                                inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo   and v.IDTipoCosto=2
                                where rp.Fecha=t1.Fecha
                            ),0)
        from @tempResponse t1
        where t1.IDReporteMovimiento in ('CostoTotal')


       
      

        */
        
        
        
        select *, ROW_NUMBER() OVER( PARTITION BY NameReporteMovimiento,    NameReporteMovimiento ORDER BY  [NameReporteMovimiento],fecha  asc) as ROWNUMBER from @tempResponse
        order by Orden ASC
GO
