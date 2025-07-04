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
CREATE PROCEDURE [Transporte].[spReporteBasicoCostoPasajeroPorRutaImpreso](
    --@dtFiltros [Nomina].[dtFiltrosRH] Readonly ,
    @FechaIni date,
    @FechaFin date,
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
    
	/*set @FechaIni  = '2022-03-14';
	set @FechaFin  = '2022-03-18';	   	    
      */ 
    
    
    declare @tempReporteBasicoCostoPorPasajeroImpreso as table(        
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
        TotalVehiculos int default 0,
        PasajerosAbordoVehiculo int default null,
        PasajerosRestantesVehiculo int default null,
        CostoOptimoPasajero decimal (10,2) default null,
        CostoTotalVehiculos decimal (10,2) default null,
        CostoPasajero decimal(10,2) default null
    );

	declare @tempVehiculosPorDia as table (
                [IDVehiculo] INT ,                
                [CostoTotal] decimal, 
                [CostoUni] decimal, 
                [Total] int,                
                [Fecha] date
    );

    insert into @tempReporteBasicoCostoPorPasajeroImpreso (rownumber , IDRuta,ClaveRuta , IDVehiculo , IDRutaProgramada , DescripcionRuta , HoraSalida ,
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
    select IDVehiculo, Fecha ,CostoUnidad,CostoUnidad/count(*),count(*) from  @tempReporteBasicoCostoPorPasajeroImpreso
    where IDTipoCosto=2
    GROUP by IDVehiculo, Fecha ,CostoUnidad,CostoUnidad
            
    update   p set CostoUnidad =vd.CostoUni,CostoRuta =vd.CostoUni    
    from @tempReporteBasicoCostoPorPasajeroImpreso  p 
    inner join @tempVehiculosPorDia vd on vd.IDVehiculo=p.IDVehiculo
    where IDTipoCosto=2            
         
    UPDATE @tempReporteBasicoCostoPorPasajeroImpreso  SET 
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
	  FROM @tempReporteBasicoCostoPorPasajeroImpreso
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
	  FROM @tempReporteBasicoCostoPorPasajeroImpreso t
		 JOIN ROWCTE cte ON cte.rownumber = t.rownumber-1 AND cte.IDRutaProgramada=t.IDRutaProgramada
	  WHERE  t.rownumber>1
    )  
    /*   SELECT rownumber ,IDRutaProgramada,CapacidadT,PasajerosAbordoVehiculo,
            CASE when PasajerosRestantesVehiculo < 0  then 0 
        else PasajerosRestantesVehiculo end [Pasajeros Restantes],TotalPasajeros,TotalPasajerosAbordo from ROWCTE
        order by IDRutaProgramada,rownumber
        */   
    UPDATE s  SET 
                            s.CostoOptimoPasajero = s.CostoTotalVehiculos / (s.Capacidad*s.TotalVehiculos) ,
                            s.CostoPasajero = CASE WHEN isnull(r.PasajerosAbordoVehiculo,0) = 0 THEN CostoTotalVehiculos ELSE  CostoTotalVehiculos / r.PasajerosAbordoVehiculo End,
                            s.PasajerosAbordoVehiculo =r.PasajerosAbordoVehiculo
    from @tempReporteBasicoCostoPorPasajeroImpreso s
    LEFT JOIN ROWCTE r on r.IDRutaProgramada=s.IDRutaProgramada and r.rownumber =s.rownumber
        
    select  *  from @tempReporteBasicoCostoPorPasajeroImpreso           
END
GO
