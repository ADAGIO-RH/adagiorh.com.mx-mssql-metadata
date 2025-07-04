USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-03-14
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spReporteBasicoCostoPasajeroPorRuta](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly ,
	@IDUsuario int=null
)
AS
BEGIN
	declare	
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null   
	;
	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u with (nolock)
		Inner join App.tblPreferencias p  with (nolock) 
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp with (nolock)  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp with (nolock)  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas with (nolock)  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish';  
	end  
    
	SET LANGUAGE @IdiomaSQL; 
	SET DATEFIRST 7;  
	SET DATEFORMAT ymd;
    Declare 	
    @FechaIni varchar(max) ,    
	@FechaFin varchar(max);	   	    
    
    SET @FechaIni = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),convert(varchar, getdate(), 23))
    SET @FechaFin = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),convert(varchar, getdate(), 23))    
	
       
    if object_id('tempdb..#tempReporteBasicoCostoPorPasajero') is not null drop table #tempReporteBasicoCostoPorPasajero;
    if object_id('tempdb..#tempFinalReporteCostoPasajero') is not null drop table #tempFinalReporteCostoPasajero;

    create table #tempReporteBasicoCostoPorPasajero(        
        rownumber int,
        IDRuta int,
        ClaveRuta varchar(100),
        IDVehiculo int,
        IDRutaProgramada int ,
        DescripcionRuta VARCHAR(100),
        HoraSalida TIME,
        HoraLlegada time ,
        Fecha date ,
        FechaStr varchar(100) ,
        IDTipoCosto int ,
        TipoCosto VARCHAR(100),
        KMRuta int ,
        TipoVehiculo varchar(50),
        CostoUnidad decimal (10,2),        
        Capacidad int ,
        CapacidadT int ,
        CostoRuta decimal(10,2) ,
        TotalPasajeros int,
        TotalVehiculos int ,
        PasajerosAbordoVehiculo INT,
        PasajerosRestantesVehiculo int,
        CostoOptimoPasajero decimal (10,2),
        CostoTotalVehiculos decimal (10,2) ,
        CostoPasajero decimal(10,2)    
    );

	declare @tempVehiculosPorDia as table (
                [IDVehiculo] INT ,                
                [CostoTotal] decimal, 
                [CostoUni] decimal, 
                [Total] int,                
                [Fecha] date
    );

    insert into #tempReporteBasicoCostoPorPasajero (rownumber , IDRuta,ClaveRuta , IDVehiculo , IDRutaProgramada , DescripcionRuta , HoraSalida ,
                                                    HoraLlegada  , Fecha ,FechaStr , IDTipoCosto , TipoCosto , KMRuta , TipoVehiculo , CostoUnidad  ,        
                                                    Capacidad , CostoRuta  , TotalPasajeros , TotalVehiculos)
    select 
            ROW_NUMBER()over(PARTITION by IDRutaProgramada order by Fecha),
            temp.* ,
            count(temp.IDRutaProgramada)
        from 
            (select 
                    rp.IDRuta,    
                    r.ClaveRuta,
                    case when rpv.IDTipoCosto =1 then 0
                        when rpv.IDTipoCosto =2 then rpv.IDVehiculo end  [IDVehiculo],
                    rp.IDRutaProgramada,
                    r.Descripcion [DescripcionRuta],
                    rp.HoraSalida,
                    rp.HoraLlegada,
                    rp.Fecha,
                    upper(Format(rp.Fecha, 'dddd dd  MMM')) [FechaStr],
                    rpv.IDTipoCosto,
                    tc.Descripcion [TipoCosto],
                    rp.KMRuta,
                    tv.Descripcion [TipoVehiculo],
                    rpv.CostoUnidad,
                    rpv.Capacidad,
                    case when rpv.IDTipoCosto =1 then rpv.CostoUnidad*rp.KMRuta
                        when rpv.IDTipoCosto =2 then 0
                    end [CostoRuta],    
                    count(rpp.[IDRutaProgramadaPersonal]) [TotalPasajeros]            
                from Transporte.tblRutasProgramadas  rp
                    inner join Transporte.tblRutasProgramadasVehiculos rpv on rp.IDRutaProgramada=rpv.IDRutaProgramada
                    inner join Transporte.tblRutasProgramadasPersonal rpp on rpp.IDRutaProgramada=rp.IDRutaProgramada
                    inner join Transporte.tblCatRutas r on r.IDRuta=rp.IDRuta
                    inner join Transporte.tblCatTipoCosto tc on tc.IDTipoCosto=rpv.IDTipoCosto
                    inner join Transporte.tblCatVehiculos v on v.IDVehiculo=rpv.IDVehiculo
                    inner join Transporte.tblCatTipoVehiculo tv on tv.IDTipoVehiculo=v.IDTipoVehiculo
                where rp.Fecha  BETWEEN @FechaIni and @FechaFin                
                    group by   
                    r.ClaveRuta,
                    rp.IDRuta,
                    rpv.IDVehiculo,
                    rp.HoraSalida,
                    rp.HoraLlegada,
                    rp.Fecha,
                    rp.IDRutaProgramada,
                    rpv.IDTipoCosto,
                    rpv.Capacidad,
                    r.Descripcion,
                    tc.Descripcion,
                    rp.KMRuta,
                    tv.Descripcion,
                    RPV.CostoUnidad   
            ) temp             
        group by 
        temp.ClaveRuta,
        temp.IDRuta,    
        temp.HoraSalida,
        temp.HoraLlegada,
        temp.Fecha,
        temp.IDRutaProgramada,
        temp.IDTipoCosto,
        temp.Capacidad,
        temp.TipoVehiculo,
        temp.TipoCosto,
        temp.KMRuta,
        temp.DescripcionRuta,
        temp.CostoUnidad, 
        temp.CostoRuta,
        temp.TotalPasajeros,  
        temp.TipoVehiculo,
        temp.FechaStr,
        temp.IDVehiculo,
        temp.CostoUnidad,
        temp.Capacidad             
        ORDER by temp.Fecha,temp.IDRutaProgramada


    insert @tempVehiculosPorDia(IDVehiculo,Fecha,CostoTotal,CostoUni,Total)
    select IDVehiculo, Fecha ,CostoUnidad,CostoUnidad/count(*),count(*) from  #tempReporteBasicoCostoPorPasajero
    where IDTipoCosto=2
    GROUP by IDVehiculo, Fecha ,CostoUnidad,CostoUnidad
            
    IF(NOT EXISTS(SELECT top 1 1 fROM @tempVehiculosPorDia))
    BEGIN
            SELECT 
                ClaveRuta [Clave Ruta],
                DescripcionRuta [Descripción Ruta],
                HoraSalida [Hora Salida],
                HoraLlegada [Hora Llegada],     
                TipoCosto [Tipo Costo],                                                   
                CostoUnidad [Costo Unidad],
                KMRuta [KMRuta],
                CostoRuta [Costo Ruta],
                Capacidad,
                CostoOptimoPasajero [Costo Optimo Pasajero]
            FROM #tempReporteBasicoCostoPorPasajero        
        return 
    end
    

    update   p set CostoUnidad =vd.CostoUni,CostoRuta =vd.CostoUni    
    from #tempReporteBasicoCostoPorPasajero  p 
    inner join @tempVehiculosPorDia vd on vd.IDVehiculo=p.IDVehiculo
    where IDTipoCosto=2            

    UPDATE #tempReporteBasicoCostoPorPasajero  SET 
                        CostoTotalVehiculos = CostoRuta * TotalVehiculos,
                        CapacidadT =Capacidad*TotalVehiculos

    ;with ROWCTE as (  
      SELECT
		    rownumber
		    ,IDRutaProgramada
		    ,CapacidadT            
		    ,PasajerosAbordoVehiculo = case  
                                        when CapacidadT >isnull(TotalPasajeros,0) then isnull(TotalPasajeros,0) 
                                        else CapacidadT end 	
		    ,PasajerosRestantesVehiculo = case 
                                        when CapacidadT>TotalPasajeros then 0
                                        else TotalPasajeros-CapacidadT  end
		    ,TotalPasajeros = TotalPasajeros
		    ,TotalPasajerosAbordo =  case   
                                        when CapacidadT >isnull(TotalPasajeros,0) then isnull(TotalPasajeros,0) 
                                        else CapacidadT end            															 
	  FROM #tempReporteBasicoCostoPorPasajero
	  WHERE PasajerosAbordoVehiculo IS NULL AND  rownumber = 1
        UNION ALL  
      SELECT
		    t.rownumber
		    ,t.IDRutaProgramada
		    ,t.CapacidadT            
		    ,PasajerosAbordoVehiculo = case 
                                        when t.CapacidadT >  ISNULL( cte.TotalPasajerosAbordo,0)  and t.CapacidadT > ISNULL( t.TotalPasajeros,0)- isnull(cte.TotalPasajerosAbordo,0) 
                                                                                                 then  ISNULL( t.TotalPasajeros,0)- isnull(cte.TotalPasajerosAbordo,0)
                                        when t.CapacidadT >  ISNULL( cte.TotalPasajerosAbordo,0) then  isnull(t.CapacidadT,0)
                                        else t.TotalPasajeros- cte.TotalPasajerosAbordo end 			
		    ,PasajerosRestantesVehiculo = t.TotalPasajeros-(case 
															when t.CapacidadT >t.PasajerosRestantesVehiculo then isnull(t.CapacidadT,0) 
															else t.CapacidadT + cte.TotalPasajerosAbordo end)
		    ,t.TotalPasajeros
		    ,TotalPasajerosAbordo = case 
                                        when t.CapacidadT >t.PasajerosRestantesVehiculo then isnull(t.CapacidadT,0) 
                                        else t.CapacidadT + cte.TotalPasajerosAbordo end 
	  FROM #tempReporteBasicoCostoPorPasajero t
		 JOIN ROWCTE cte ON cte.rownumber = t.rownumber-1 AND cte.IDRutaProgramada=t.IDRutaProgramada
	  WHERE  t.rownumber>1
    )  
   /*SELECT rownumber ,IDRutaProgramada,CapacidadT,PasajerosAbordoVehiculo,
    CASE when PasajerosRestantesVehiculo < 0  then 0 
    else PasajerosRestantesVehiculo end [Pasajeros Restantes],TotalPasajeros,TotalPasajerosAbordo from ROWCTE
    order by IDRutaProgramada,rownumber*/
   

    UPDATE s  SET 
                            s.CostoOptimoPasajero = s.CostoTotalVehiculos / (s.Capacidad*s.TotalVehiculos) ,
                            s.CostoPasajero = CASE WHEN isnull(r.PasajerosAbordoVehiculo,0) = 0 THEN CostoTotalVehiculos ELSE  CostoTotalVehiculos / r.PasajerosAbordoVehiculo End,
                            s.PasajerosAbordoVehiculo =r.PasajerosAbordoVehiculo
    from #tempReporteBasicoCostoPorPasajero s
    LEFT JOIN ROWCTE r on r.IDRutaProgramada=s.IDRutaProgramada and r.rownumber =s.rownumber
                        
    select 

        ClaveRuta,
        DescripcionRuta,
        HoraLlegada,
        HoraSalida,
        Fecha,
        Fechastr,
        sum(KMRuta)/count(*) KMRuta, 
        sum(CostoUnidad)/count(*) as CostoUnidad, 
        sum(Capacidad)/count(*) as Capacidad, 
        sum(CostoRuta)/count(*) as CostoRuta, 
        sum(CostoPasajero)/count(*) as CostoPasajero,
        sum(CostoOptimoPasajero)/count(*) as CostoOptimoPasajero   ,
        TipoCosto          
        into #tempFinalReporteCostoPasajero
    From #tempReporteBasicoCostoPorPasajero
    group by  ClaveRuta, DescripcionRuta, HoraLlegada, HoraSalida, TipoCosto,Fecha, FechaStr--, TipoCosto, TipoVehiculo--,KMRuta,  CostoUnidad, Capacidad, CostoRuta
    order by Fecha

    update p  set p.Capacidad =  s.Capacidad
                    ,P.KMRuta=s.KMRuta
                    ,P.CostoUnidad=s.CostoUnidad                        
                    
                    ,P.CostoRuta=s.CostoRuta
                    ,P.CostoOptimoPasajero=s.CostoOptimoPasajero
            
    from #tempFinalReporteCostoPasajero p
    inner join (
            select  f.ClaveRuta, f.DescripcionRuta, f.HoraLlegada, f.HoraSalida,f.TipoCosto,
            sum(f.Capacidad)/count(*)  [Capacidad] ,
            sum(f.CostoUnidad)/count(*)  [CostoUnidad] ,
            sum(f.KMRuta)/count(*)  [KMRuta] ,
            sum(f.CostoRuta)/count(*)  [CostoRuta] ,
            sum(f.CostoOptimoPasajero)/count(*)  [CostoOptimoPasajero] 
            from  #tempFinalReporteCostoPasajero f 
            group by ClaveRuta, DescripcionRuta, HoraLlegada, HoraSalida,TipoCosto
    ) s on s.ClaveRuta=p.ClaveRuta and s.HoraLlegada =p.HoraLlegada and s.HoraSalida=p.HoraSalida  and s.TipoCosto=p.TipoCosto
              
    DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX);

	SET @cols = STUFF((SELECT ',' +  isnull(QUOTENAME(c.FechaStr), 0) +'AS '+ QUOTENAME(c.FechaStr)
				FROM #tempFinalReporteCostoPasajero c
				GROUP BY  c.Fecha,c.FechaStr
				ORDER BY c.Fecha 
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');
    --SELECT @cols

	SET @colsAlone = STUFF((SELECT ','+ isnull(QUOTENAME(c.FechaStr),0)
				FROM #tempFinalReporteCostoPasajero c
                 GROUP BY  c.Fecha,c.FechaStr
				ORDER BY  c.Fecha desc
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	--select @colsAlone
        
	set @query1 = 'SELECT ClaveRuta [Clave Ruta],
                            DescripcionRuta [Descripción Ruta],
                            HoraSalida [Hora Salida],
                            HoraLlegada [Hora Llegada],     
                            TipoCosto [Tipo Costo],                                                   
                            CostoUnidad [Costo Unidad],
                            KMRuta [KMRuta],
                            CostoRuta [Costo Ruta],
                            Capacidad,
                            CostoOptimoPasajero [Costo Optimo Pasajero],
                            -- CostoOptimoPasajero,
                            -- CostoTotalVehiculos,                            
                            ' + @cols + ' from 
				(
					select 
						ClaveRuta
                        , DescripcionRuta                       
						, CostoPasajero 	
                        , TipoCosto	
                        , HoraSalida                                           
                        , HoraLlegada   
                        , CostoUnidad                        
                        , CostoRuta
                        ,CostoOptimoPasajero
                        , Capacidad
                        , KMRuta                  	 
						, FechaStr                   						
					from #tempFinalReporteCostoPasajero                    
			   ) x'

	set @query2 = '
				pivot 
				(
					 max(CostoPasajero)
					for FechaStr in (' + @colsAlone + ')
				) p 
                order by ClaveRuta,HoraSalida
				'	
	
	exec( @query1 + @query2) 
  
END
GO
