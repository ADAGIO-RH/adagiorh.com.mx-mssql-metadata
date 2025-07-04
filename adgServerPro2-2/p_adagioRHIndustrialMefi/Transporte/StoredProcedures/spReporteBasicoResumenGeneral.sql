USE [p_adagioRHIndustrialMefi]
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
CREATE PROC [Transporte].[spReporteBasicoResumenGeneral] 
(
    @IDUsuario	int = 1 ,  
    @FechaIni date ='2022-01-01',
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
                    [Total]  Varchar(100) default '0',                 
                    [Orden] int      ,
                    [Colums] int      ,
                    [IDReporteMovimientoPadre] VARCHAR (100) default ''                                        
                    
        );        
        declare  @Fechas [App].[dtFechasFull]   

        insert @Fechas  
            exec app.spListaFechas @FechaIni =@FechaIni, @FechaFin = @FechaFin
                    
        insert into @tempResponse (anio,mes,dia,Fecha,IDReporteMovimiento,NameReporteMovimiento,Orden,IDReporteMovimientoPadre,TipoDato)
            select Anio,Mes,Dia,Fecha,s.IDReporteMovimiento,s.NameReporteConcepto,s.Orden,s.IDReporteMovimientoPadre,TipoDato
            from Transporte.tblConceptosReporteGeneral s
            cross join @Fechas
            
        update t1   set t1.Valor=case when t1.IDReporteMovimiento in ('TotalVehiculosTipoDia','TotalVehiculosTipoKM') then isnull(ss.TotalVehiculos,0) 
                        when t1.IDReporteMovimiento in ('CapacidadTipoDia','CapacidadTipoKM') then isnull(ss.Capacidad,0) 
                        when t1.IDReporteMovimiento in ('KMRutaTipoKM','KMRutaTipoDia') then isnull(ss.KMTotales,0) 

                        else -1 end
        from  @tempResponse t1
            join (
                    SELECT        
                        rp.Fecha,                    
                        count(rpv.IDRutaProgramadaVehiculo) [TotalVehiculos],
                        sum(rpv.Capacidad) as [Capacidad],
                        sum(rp.KMRuta) as [KMTotales],
                        rpv.IDTipoCosto                    
                    FROM Transporte.tblRutasProgramadas rp
                        inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada
                        inner join Transporte.tblCatTipoCosto c on c.IDTipoCosto=rpv.IDTipoCosto                
                    group by rpv.IDTipoCosto ,rp.Fecha,c.Descripcion,Fecha
            )  ss on ss.Fecha=t1.Fecha and ss.IDTipoCosto = case  when t1.IDReporteMovimiento  in( 'TotalVehiculosTipoDia','CapacidadTipoDia','KMRutaTipoDia') then 2 else 1 end
        where t1.IDReporteMovimiento in ('TotalVehiculosTipoDia','TotalVehiculosTipoKM','CapacidadTipoDia','CapacidadTipoKM','KMRutaTipoKM','KMRutaTipoDia')


        update t1  set t1.Valor= ss.Pasajeros from @tempResponse t1
        join (             
                select ss.Fecha ,sum(ss.Pasajeros) [Pasajeros],TipoPasajeros From (
                        select rp.Fecha,count(*) [Pasajeros],                         
                            case when (select SUM(PV.Capacidad)   From Transporte.tblRutasProgramadasVehiculos pv where pv.IDRutaProgramada=rp.IDRutaProgramada group BY IDRutaProgramada)  >= count(*)                                    
                                then  'Asignados'  else 'NoAsignados'   end [TipoPasajeros]
                        From Transporte.tblRutasProgramadas rp                                                                                                                                                                    
                            left join Transporte.tblRutasProgramadasPersonal rpp on rpp.IDRutaProgramada=rp.IDRutaProgramada                                    
                        group by rp.Fecha , rp.IDRutaProgramada
                ) ss
                group by ss.Fecha,ss.TipoPasajeros
                        
            ) ss on ss.Fecha = t1.Fecha and ss.TipoPasajeros= case  when t1.IDReporteMovimiento  in( 'PasajerosAsignados') then 'Asignados' else 'NoAsignados' end
        where t1.IDReporteMovimiento in ('PasajerosAsignados','PasajerosNoAsignados')
        

        update t1  set t1.Valor= tt.CostoTotal from @tempResponse t1
        left join (             
                select sum(tabla.CostoTotal) [CostoTotal],Fecha,TipoCosto from (
                        SELECT   v.CostoUnidad  [CostoTotal],Fecha ,2 [TipoCosto]
                                FROM Transporte.tblRutasProgramadas rp
                                inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada and rpv.IDTipoCosto=2
                                inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo                                                              
                        group by v.IDVehiculo,rp.Fecha,v.CostoUnidad,v.IDTipoCosto,rp.KMRuta 
                        union 
                        SELECT  SUM(v.CostoUnidad *rp.KMRuta),Fecha,1 [TipoCosto]                                 
                                FROM Transporte.tblRutasProgramadas rp
                                inner join Transporte.tblRutasProgramadasVehiculos rpv on rpv.IDRutaProgramada=rp.IDRutaProgramada and rpv.IDTipoCosto=1
                                inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo                           
                        group by Fecha                                 
                ) as tabla GROUP by Fecha,TipoCosto 
        ) tt on tt.Fecha=t1.Fecha and tt.TipoCosto =case  when t1.IDReporteMovimiento  in( 'CostoTotalTipoDia') then 2 else 1 end
        where t1.IDReporteMovimiento in ('CostoTotalTipoDia','CostoTotalTipoKM')


        update t1 set t1.Valor=tt.total
        from @tempResponse t1
        join (
            select Fecha, IDReporteMovimientoPadre,sum(isnull(tt.Valor,0)) [total] FROM @tempResponse tt
            group by Fecha,IDReporteMovimientoPadre 
        ) tt on tt.IDReporteMovimientoPadre=t1.IDReporteMovimiento and t1.Fecha=tt.Fecha


        update t1 set t1.Total=(select sum(isnull(tt.Valor,0)) [total] FROM @tempResponse tt  where tt.IDReporteMovimiento=t1.IDReporteMovimiento  group by IDReporteMovimiento )
        from @tempResponse t1        
        where t1.IDReporteMovimiento  not in ('Ocupacion','Disponibilidad')

        
                     
        update t1 set t1.Valor= case when t1.IDReporteMovimiento='Ocupacion' then         
                                                                    case when isnull(t3.Valor,0) =0 or isnull(t2.Valor,0) =0 then 0
                                                                        else (t3.Valor*100)/t2.Valor end                                    
                                     when t1.IDReporteMovimiento ='Disponibilidad' then case when isnull(t3.Valor,0) =0 or isnull(t2.Valor,0) =0 then 0
                                                                        else t2.Valor- t3.Valor   end                                    
                                     else -1 end
        from @tempResponse t1
            left join  @tempResponse  t2 on t2.IDReporteMovimiento= 'Capacidad' AND t2.Fecha=t1.Fecha 
            left join  @tempResponse  t3 on t3.IDReporteMovimiento= 'PasajerosAsignados' AND t3.Fecha=t1.Fecha 
        where t1.IDReporteMovimiento in ('Ocupacion','Disponibilidad')



        update t1 set t1.Valor=    case when isnull(t3.Valor,0) =0 or isnull(t2.Valor,0) =0 then 0
                                        else t3.Valor/t2.Valor  end    
        from @tempResponse t1
            left join  @tempResponse  t2 on t2.IDReporteMovimiento= 'Capacidad' AND t2.Fecha=t1.Fecha 
            left join  @tempResponse  t3 on t3.IDReporteMovimiento= 'CostoTotal' AND t3.Fecha=t1.Fecha 
        where t1.IDReporteMovimiento in ('CostoOptimo')


        update t1 set t1.Valor=    case when isnull(t3.Valor,0) =0 or isnull(t2.Valor,0) =0 then 0
                                        else t3.Valor/t2.Valor  end    
        from @tempResponse t1
            left join  @tempResponse  t2 on t2.IDReporteMovimiento= 'PasajerosAsignados' AND t2.Fecha=t1.Fecha 
            left join  @tempResponse  t3 on t3.IDReporteMovimiento= 'CostoTotal' AND t3.Fecha=t1.Fecha 
        where t1.IDReporteMovimiento in ('CostoPasajero')
        

        update t1 set Total = ( select sum(Valor)/count(*) from @tempResponse where IDReporteMovimiento in ('Ocupacion') and Valor <> 0)
        from @tempResponse t1        
        where t1.IDReporteMovimiento in ('Ocupacion')

        
        update t1 set t1.Total=(select sum(isnull(tt.Valor,0)) [total] FROM @tempResponse tt  where tt.IDReporteMovimiento=t1.IDReporteMovimiento  group by IDReporteMovimiento )
        from @tempResponse t1        
        where t1.IDReporteMovimiento in ('Disponibilidad','CostoTotal')

        update t1 set t1.Total=(select sum(Valor) from @tempResponse where IDReporteMovimiento in ('CostoTotal') and Valor <> 0)
        from @tempResponse t1        
        where t1.IDReporteMovimiento in ('CostoOptimo','CostoPasajero')


        update t1 set t1.Total=t1.Total/(select sum(Valor) from @tempResponse where IDReporteMovimiento in ('PasajerosAsignados') and Valor <> 0)
        from @tempResponse t1        
        where t1.IDReporteMovimiento in ('CostoPasajero')


        update t1 set t1.Total=t1.Total/(select sum(Valor) from @tempResponse where IDReporteMovimiento in ('Capacidad') and Valor <> 0)
        from @tempResponse t1        
        where t1.IDReporteMovimiento in ('CostoOptimo')
        
       
        
         update @tempResponse  set Valor = 0 where  Valor is  null       
        select *, ROW_NUMBER() OVER( PARTITION BY NameReporteMovimiento,    NameReporteMovimiento ORDER BY  [NameReporteMovimiento],fecha  asc) as ROWNUMBER from @tempResponse
        order by Orden ASC
GO
