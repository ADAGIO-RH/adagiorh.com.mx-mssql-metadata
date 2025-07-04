USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Transporte].[spReporteBasicoRutasProgramadasPorEmpleado] (
	@FechaIni date 
	,@FechaFin date	
	,@IDUsuario int
    ,@Detalle bit
) as

/*
    exec [Transporte].[spReporteBasicoRutasProgramadasPorEmpleado]
            @FechaIni	= '2019-08-01'
            ,@FechaFin	= '2019-08-15'
            ,@Detalle	= 0
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
                [Nombres] VARCHAR (500),
                [Apellidos] VARCHAR (500),
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
    insert into @tempResponse (IDRutaProgramada,Fecha,ClaveRuta,Destino,Origen,DescripcionRuta,HoraSalida,HoraLlegada,KMRuta,PersonasAbordo)
    select  rp.IDRutaProgramada,rp.Fecha  , cr.ClaveRuta,cr.Destino,cr.Origen,cr.Descripcion,
        rp.HoraSalida,rp.HoraLlegada ,cr.KMRuta, count(rpp.IDRutaProgramadaPersonal)
    from Transporte.tblRutasProgramadas  rp        
        inner join Transporte.tblCatRutas cr on cr.IDRuta=rp.IDRuta     
        inner join Transporte.tblRutasProgramadasPersonal rpp on rpp.IDRutaProgramada=rp.IDRutaProgramada
    where rp.Fecha BETWEEN @FechaIni and @FechaFin 
        group by rp.IDRutaProgramada,rp.Fecha  , cr.ClaveRuta,cr.Destino,cr.Origen,cr.Descripcion,
            rp.HoraSalida,rp.HoraLlegada ,cr.KMRuta
        order by rp.IDRutaProgramada
        

    --update t1 SET PersonasAbordo=(select count(*) from Transporte.tblRutasProgramadasPersonal where IDRutaProgramada=t1.IDRutaProgramada) 
    --from  @tempResponse t1


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
    


    if(@Detalle =1 )
        begin
            
            /*insert into @tempResponse (  [IDRutaProgramada] , 
                            [ClaveEmpleado] , 
                            [ClaveRuta] ,
                            [Nombres] ,
                            [Apellidos] ,
                            [Fecha] ,
                            [Destino] ,
                            [Origen] ,
                            [DescripcionRuta] , 
                            [HoraSalida] ,
                            [HoraLlegada]  ,
                            [StatusDescripcion]  ,
                            [PersonasAbordo]  ,
                            [Capacidad] ,
                            [Disponibilidad] ,
                            [KMRuta] ,
                            [KMRecorridos] ,
                            [NumeroVehiculos] )
                            */
            select  
            ROW_NUMBER()over(PARTITION by t.ClaveRuta,t.Fecha,T.HoraLlegada order by m.ClaveEmpleado ) as row
            ,t.[IDRutaProgramada] , 
                            case when m.IDEmpleado is null then 'EXTERNO' else m.ClaveEmpleado end  [ClaveEmpleado], 
                            [ClaveRuta] ,
                            case when m.IDEmpleado is null then rp.Nombres else isnull(m.Nombre,'')+' ' + isnull(m.SegundoNombre,'') end  [Nombres],  
                            case when m.IDEmpleado is null then rp.Apellidos else isnull(m.Paterno,'')+' ' + isnull(m.Materno,'') end  [Apellidos], 
                            [Fecha] ,
                            [Destino] ,
                            [Origen] ,
                            [DescripcionRuta] , 
                            [HoraSalida] ,
                            [HoraLlegada]  ,
                            [StatusDescripcion]  ,
                            [PersonasAbordo]  ,
                            [Capacidad] ,
                            isnull(Disponibilidad,0) as [Disponibilidad] ,
                            [KMRuta] ,
                            [KMRecorridos] ,
                            [NumeroVehiculos]  from Transporte.tblRutasProgramadasPersonal  p
                            inner join @tempResponse t on t.IDRutaProgramada=p.IDRutaProgramada
                            inner join Transporte.tblRutasPersonal rp on rp.IDRutaPersonal=p.IDRutaPersonal
                            left join rh.tblEmpleadosMaster m on m.IDEmpleado=rp.IDEmpleado
                            order by ClaveRuta,t.HoraLlegada
                          
            
        end
    else 
    begin
        update @tempResponse set ClaveEmpleado='',Nombres='',Apellidos=''
        select 
            [IDRutaProgramada],
            [ClaveEmpleado],
            [ClaveRuta],
            [Nombres],
            [Apellidos],
            [Fecha],
            [Destino],
            [Origen],
            [DescripcionRuta],
            [HoraSalida],
            [HoraLlegada],
            [StatusDescripcion],
            [PersonasAbordo],
            [Capacidad],
            isnull(Disponibilidad,0) as [Disponibilidad] ,
            [KMRuta],
            [KMRecorridos],
            [NumeroVehiculos] 
        From @tempResponse
    end
GO
