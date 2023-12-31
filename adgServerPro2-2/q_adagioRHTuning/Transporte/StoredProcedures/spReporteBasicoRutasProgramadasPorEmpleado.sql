USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Transporte].[spReporteBasicoRutasProgramadasPorEmpleado] (
	@FechaIni date 
	,@FechaFin date	
	,@IDUsuario int
) as

    /*
    exec [Reportes].[spReporteBasicoRutasProgramadasPorEmpleado]
            @FechaIni	= '2019-08-01'
            ,@FechaFin	= '2019-08-15'
            ,@Clientes	= '1' 
            ,@IDUsuario = 1 

    */
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END
     
	declare @tempResponse as table (      
                [IDRutaProgramada] int,    
                [ClaveEmpleado] VARCHAR (20),                    
                [ClaveRuta] VARCHAR (20),
                [Nombres] VARCHAR (20),
                [Apellidos] VARCHAR (20),
                [Fecha] date ,
                [Destino] VARCHAR (100),
                [Origen] VARCHAR (100),
                [DescripcionRuta] VARCHAR (100),                                
                [HoraSalida] time ,
                [HoraLlegada] time ,                
                [StatusDescripcion] VARCHAR (50),                
                [PersonasAbordo]  INT ,                
                [Capacidad]  INT ,
                [Disponibilidad]  INT ,
                [KMRuta] int,
                [KMRecorridos] int,
                [NumeroVehiculos] int
    );     
    insert into @tempResponse (IDRutaProgramada,ClaveEmpleado,Nombres,Apellidos,Fecha,ClaveRuta,Destino,Origen,DescripcionRuta,HoraLlegada,HoraSalida,KMRuta)
    select  rp.IDRutaProgramada,isnull(m.ClaveEmpleado,'Externo') [ClaveEmpleado], rpp.Nombres,rpp.Apellidos ,rp.Fecha  , cr.ClaveRuta,cr.Destino,cr.Origen,cr.Descripcion,
    rp.HoraSalida,rp.HoraLlegada ,cr.KMRuta
     from Transporte.tblRutasProgramadas  rp
    inner join Transporte.tblRutasProgramadasPersonal  rpd on rp.IDRutaProgramada=rpd.IDRutaProgramada
    inner join Transporte.tblRutasPersonal rpp on rpp.IDRutaPersonal=rpd.IDRutaPersonal 
    inner join Transporte.tblCatRutas cr on cr.IDRuta=rp.IDRuta 
    left join rh.tblEmpleadosMaster m on m.IDEmpleado=rpp.IDEmpleado 
    where rp.Fecha BETWEEN @FechaIni and @FechaFin
    order by rp.IDRutaProgramada

    update t1 SET PersonasAbordo=(select count(*) from Transporte.tblRutasProgramadasPersonal where IDRutaProgramada=t1.IDRutaProgramada) 
    from  @tempResponse t1


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
        , NumeroVehiculos =(SELECT COUNT(IDRutaProgramadaVehiculo)  from Transporte.tblRutasProgramadasVehiculos v where v.IDRutaProgramada=t1.IDRutaProgramada)
        ,Disponibilidad= case when Capacidad is null  then 0 when Capacidad>0 then Capacidad-PersonasAbordo end 
        ,[StatusDescripcion] = case when (Capacidad-PersonasAbordo)  < 0 or Capacidad is null then 'Pendiente por asignar vehículos' when (Capacidad-PersonasAbordo) > 0 then 'Vehículo Asignado'  end         
    from @tempResponse t1

    SELECT IDRutaProgramada,ClaveRuta,KMRuta,StatusDescripcion,ClaveEmpleado,DescripcionRuta,Nombres,Apellidos,Destino,Origen,HoraSalida,HoraLlegada,Fecha,StatusDescripcion [Status],PersonasAbordo,NumeroVehiculos,
     case when Capacidad is null or Capacidad=0 then '---' when Capacidad is not null then  cast(Capacidad as varchar) end [Capacidad] ,
     case when Disponibilidad is null then '---' when Disponibilidad is not null then  cast(Disponibilidad as varchar) end [Disponibilidad],      
     case when KMRecorridos = 0  then '---' when KMRecorridos >0 then  cast(KMRecorridos as varchar) end [KMRecorridos]    
    FROM @tempResponse 
    order by Capacidad desc ,Fecha ASC
GO
