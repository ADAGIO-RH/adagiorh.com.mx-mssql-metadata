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
CREATE PROCEDURE [Transporte].[spReporteBasicoRutasProgramadasExcel](
    @dtFiltros [Nomina].[dtFiltrosRH] Readonly,
	@IDUsuario int

)
AS
BEGIN
 Declare 	
	@FechaIni DATE = null,
	@FechaFin DATE= null;
	

    
	declare @tempResponse as table (      
                [IDRutaProgramada] int,                        
                [ClaveRuta] VARCHAR (20),
                [DescripcionRuta] VARCHAR (100),
                [Origen] VARCHAR (100),
                [Destino] VARCHAR (100),
                [HoraSalida] time ,
                [HoraLlegada] time ,
                [Fecha] date ,
                [StatusDescripcion] VARCHAR (50),                
                [PersonasAbordo]  INT ,                
                [Capacidad]  INT ,
                [Disponibilidad]  INT ,
                [KMRuta] int,
                [KMRecorridos] int,
                [NumeroVehiculos]  int
    );     

    set @FechaIni	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaIni'			)   ,'1990-01-01')
    set @FechaFin	 = isnull((SELECT top 1 cast( value as date) from @dtFiltros where Catalogo = 'FechaFin'			)   ,'9999-12-31')   

	

    INSERT @tempResponse (IDRutaProgramada,ClaveRuta,DescripcionRuta,Origen,Destino,HoraSalida,HoraLlegada,Fecha,PersonasAbordo,KMRuta)   
        select  
            rp.IDRutaProgramada,
            cr.ClaveRuta ,
            cr.Descripcion ,
            cr.Origen,
            cr.Destino,
            rp.HoraSalida,            
            rp.HoraLlegada,            
            rp.Fecha,    
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
        rp.HoraLlegada,
        rp.HoraSalida,        
        rp.Fecha,        
        cr.KMRuta
        order by rp.Fecha

    update t1 set Capacidad=isnull(t.sumPasajero,0),KMRecorridos=isnull(cantidadVehiculos,0)*KMRuta  from @tempResponse t1
    LEFT join  (
        SELECT  rpv.IDRutaProgramada ,sum(cv.CantidadPasajeros)  sumPasajero,count(rpv.IDVehiculo) cantidadVehiculos
        FROM Transporte.tblRutasProgramadasVehiculos rpv
        left join Transporte.tblCatVehiculos cv on cv.IDVehiculo=rpv.IDVehiculo
        where IDRutaProgramada=IDRutaProgramada
        group by   rpv.IDRutaProgramada                
    ) t on t.IDRutaProgramada=t1.IDRutaProgramada


    UPDATE t1 set 
            Capacidad= ISNULL(Capacidad,0)
        ,Disponibilidad= case when Capacidad is null  then 0 when Capacidad>0 then Capacidad-PersonasAbordo end 
        , NumeroVehiculos =(SELECT COUNT(IDRutaProgramadaVehiculo)  from Transporte.tblRutasProgramadasVehiculos v where v.IDRutaProgramada=t1.IDRutaProgramada)
        ,[StatusDescripcion] = case when (Capacidad-PersonasAbordo)  < 0 or Capacidad is null then 'Pendiente por asignar vehículos' when (Capacidad-PersonasAbordo) >= 0 then 'Vehículo asignado.'  end         
    from @tempResponse t1


    
    SELECT ClaveRuta [Clave Ruta],Origen,Destino,HoraSalida [Hora Salida],HoraLlegada [Hora Llegada],
        convert(varchar,Fecha, 103) [Fecha],
        KMRuta [KILOMETROS DE LA RUTA],StatusDescripcion [Status],PersonasAbordo [Pasajeros],
        case when Capacidad is null then 0 when Capacidad is not null then  cast(Capacidad as int) end [Capacidad] ,
        case when Disponibilidad is null then 0 when Disponibilidad is not null then  cast(Disponibilidad as int) end [Disponibilidad],      
        case when KMRecorridos = 0  then 0 when KMRecorridos >0 then  cast(KMRecorridos as int) end [KILOMETROS RECORRIDOS],
        NumeroVehiculos [Numero Vehiculos]
    FROM @tempResponse 
    order by Capacidad desc ,Fecha asc

    
    

END
GO
