USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-18
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spReporteBasicoUsoRutaDiaExcel](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int

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
    @FechaIni date 
    ,@FechaFin date 
	
    set @FechaIni	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaIni')   ,'1990-01-01')
    set @FechaFin	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaFin')   ,'9999-12-31')
    
    if object_id('tempdb..#tempRutasProgramadasRutaPorDiaExcel') is not null drop table #tempRutasProgramadasRutaPorDiaExcel;

	Create table #tempRutasProgramadasRutaPorDiaExcel   (      
                [IDRutaProgramada] int,                        
                [ClaveRuta] VARCHAR (20),
                [DescripcionRuta] VARCHAR (100),
                [Origen] VARCHAR (100),
                [Destino] VARCHAR (100),
                [HoraSalida] time ,
                [HoraLlegada] time ,
                [Fecha] date ,
                [Fecha_str] varchar(50),
                [StatusDescripcion] VARCHAR (50),                
                [PersonasAbordo]  INT ,                
                [Capacidad]  INT ,
                [Disponibilidad]  INT ,
                [KMRuta] int,
                [KMRecorridos] int,
                [NumeroVehiculos]  int
    );     
	
    declare  @Fechas [App].[dtFechas]       
    insert @Fechas  
    exec app.spListaFechas @FechaIni =@FechaIni, @FechaFin =  @FechaFin


    INSERT #tempRutasProgramadasRutaPorDiaExcel (IDRutaProgramada,ClaveRuta,DescripcionRuta,Origen,Destino,HoraSalida,HoraLlegada,Fecha,Fecha_str,PersonasAbordo,KMRuta)   
        select  
            rp.IDRutaProgramada,
            cr.ClaveRuta ,
            cr.Descripcion ,
            cr.Origen,
            cr.Destino,
            rp.HoraSalida,            
            rp.HoraLlegada,            
            rp.Fecha,    
            upper(Format(rp.Fecha, 'dddd dd  MMM')),
            count(rpd.IDRutaProgramada) as [PersonasAbordo],
            cr.KMRuta
            
        From Transporte.tblRutasProgramadas as rp
        INNER JOIN  Transporte.tblCatRutas  cr on cr.IDRuta = rp.IDRuta   
        INNER JOIN  Transporte.tblRutasProgramadasPersonal  rpd on rpd.IDRutaProgramada=rp.IDRutaProgramada        
        where rp.Fecha between @FechaIni and @FechaFin 
        group by 
        rp.IDRutaProgramada,
        cr.ClaveRuta ,
        cr.Descripcion ,
        cr.Origen,
        cr.Destino,
        rp.HoraSalida,
        rp.HoraLlegada,
        rp.Fecha,        
        cr.KMRuta
        order by rp.Fecha

        
    if(not exists(select top 1 1 from #tempRutasProgramadasRutaPorDiaExcel))
    BEGIN
        select 
            ClaveRuta [Clave Ruta],Origen , Destino , HoraSalida [Hora Salida] , HoraLlegada [Hora LLegada], KMRuta [KM Ruta] 
         From #tempRutasProgramadasRutaPorDiaExcel
        return 
    END

    update t1 set Capacidad=isnull(t.sumPasajero,0),KMRecorridos=isnull(cantidadVehiculos,0)*KMRuta  from #tempRutasProgramadasRutaPorDiaExcel t1
    LEFT join  (
        SELECT  rpv.IDRutaProgramada ,sum(cv.CantidadPasajeros)  sumPasajero,count(rpv.IDVehiculo) cantidadVehiculos
        FROM Transporte.tblRutasProgramadasVehiculos rpv
        left join Transporte.tblCatVehiculos cv on cv.IDVehiculo=rpv.IDVehiculo
        where IDRutaProgramada=IDRutaProgramada
        group by   rpv.IDRutaProgramada                
    ) t on t.IDRutaProgramada=t1.IDRutaProgramada
        
        DECLARE @cols AS VARCHAR(MAX),
            @query1  AS VARCHAR(MAX),
            @query2  AS VARCHAR(MAX),
            @colsAlone AS VARCHAR(MAX);

        SET @cols = STUFF((SELECT ',' +  QUOTENAME(c.Fecha_str) +'AS '+ QUOTENAME(c.Fecha_str)
                    FROM #tempRutasProgramadasRutaPorDiaExcel c
                    GROUP BY c.Fecha, c.Fecha_str
                    ORDER BY c.Fecha
                    FOR XML PATH(''), TYPE
                    ).value('.', 'VARCHAR(MAX)') 
                ,1,1,'');
    --    SELECT @cols

        SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Fecha_str)
                    FROM #tempRutasProgramadasRutaPorDiaExcel c
                    GROUP BY c.Fecha, c.Fecha_str
                    ORDER BY c.Fecha
                    FOR XML PATH(''), TYPE
                    ).value('.', 'VARCHAR(MAX)') 
                ,1,1,'');

        --select @colsAlone
        set @query1 = 'SELECT ClaveRuta [Clave Ruta],Origen , Destino , HoraSalida [Hora Salida] , HoraLlegada [Hora LLegada], KMRuta [KM Ruta] ,' + @cols + ' from 
                    (
                        select                             
                             ClaveRuta
                            , Origen
                            , Destino
                            , HoraSalida
                            , HoraLlegada
                            , Fecha_str
                            , KMRuta
                            , PersonasAbordo
                            
                        from #tempRutasProgramadasRutaPorDiaExcel
                ) x'

        set @query2 = '
                    pivot 
                    (
                        max(PersonasAbordo)
                        for Fecha_str in (' + @colsAlone + ')
                    ) p 
                    order by ClaveRuta
                    '	
        exec( @query1 + @query2) 
    

END
GO
