USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Demo].[spAsignarHorarioChecadas] (
	@FechaIni date
	,@FechaFin date
)as
BEGIN
declare 
	--@FechaIni date = '2019-08-01'
	--,@FechaFin date = '2019-08-31'
	@dtEmpleados [RH].[dtEmpleados]
	,@Fechas [App].[dtFechas]
	,@IDHorario int
	,@IDEmpleado int
	,@Fecha date
	,@FechaHoraChecada datetime
	,@HoraEntrada time 
	,@HoraSalida  time
	,@Row int = 0
	,@RandomMinutes int
	,@LessPlus bit = 0
	,@IDUsuarioAdmin int
;

	SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;

	select @IDUsuarioAdmin = cast(Valor as int)
	from  App.tblConfiguracionesGenerales
	where [IDConfiguracion] ='IDUsuarioAdmin'

	if object_id('tempdb..#tempFinalColaboradoresHorarios') is not null drop table #tempFinalColaboradoresHorarios;
	if object_id('tempdb..#tempFinalColaboradoresChecadasET') is not null drop table #tempFinalColaboradoresChecadasET;
	if object_id('tempdb..#tempFinalColaboradoresChecadasST') is not null drop table #tempFinalColaboradoresChecadasST;
    if object_id('tempdb..#tempDataDescansoFestivo') is not null drop table #tempDataDescansoFestivo;
    if object_id('tempdb..#tempDataDescansoMensual') is not null drop table #tempDataDescansoMensual;

	declare @tempChecadaResult table(
		IDChecada int,
		Fecha datetime,
		FechaOrigen date,
		IDLector int,
		Lector varchar(255),
		IDEmpleado int,
		IDTipoChecada varchar(10),
		TipoChecada varchar(255),
		IDUsuario int,
		Cuenta varchar(255),
		Comentario varchar(max),
		IDZonaHoraria int,
		ZonaHoraria varchar(255),
		Automatica bit,
		FechaReg datetime
	)

	if not exists (select top 1 1 from Asistencia.tblCatHorarios)
	begin
		raiserror('No existen horarios en la catálogo.',16,1);
		return;
	end;

	declare @tempVigenciaEmpleados table(    
		IDVigenciaEmpleados int IDENTITY (1,1),
        IDEmpleado int null,    
		Fecha Date null,    
		Vigente bit null		
	); 

	insert into @Fechas
	exec [App].[spListaFechas]@FechaIni,@FechaFin

	insert @dtEmpleados
	exec RH.spBuscarEmpleados @FechaIni = @FechaIni
							 ,@Fechafin = @FechaFin
                            --  ,@EmpleadoIni = '023659'
	                        --  ,@EmpleadoFin  = '023668'
							 ,@IDUsuario = @IDUsuarioAdmin
	print('Termine con los empleados')
						 
	insert @tempVigenciaEmpleados
	exec [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleados= @dtEmpleados
													,@Fechas= @Fechas
													,@IDUsuario = @IDUsuarioAdmin
	
	print('Termine con la lista de vigencias')
	-- Se eliminan los colaboradores NO VIGENTES
	delete @tempVigenciaEmpleados where Vigente = 0														
	print('Elimine las fechas que no estaban vigentes')
    

    select 
    E.IDEmpleado AS IDEmpleado,
    (
        select top 1 IDHorario
		from Asistencia.tblCatHorarios
		where HoraEntrada BETWEEN '09:00:00' and '11:00:00'
        order by ABS(CHECKSUM(NEWID(), E.IDEmpleado))
    ) AS IDHorario    
    INTO #tempDataDescansoMensual
    from @dtEmpleados E
    



    print('Calculando los horarios a los que no lo tienen')
	select e.*,descanso.IDHorario
	INTO #tempFinalColaboradoresHorarios
	from @tempVigenciaEmpleados e
		inner join #tempDataDescansoMensual descanso on descanso.IDEmpleado=e.IDEmpleado
        left join Asistencia.tblHorariosEmpleados he on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
	where he.IDHorario is null		


    print('Insertando horarios')
    insert into Asistencia.tblHorariosEmpleados(IDEmpleado,IDHorario,Fecha)
    select IDEmpleado
    ,IDHorario
    ,Fecha
	from #tempFinalColaboradoresHorarios
	

    print('Termine de poner horarios a los que no tienen horarios')

    DELETE 
    FROM @tempVigenciaEmpleados 
    WHERE IDVigenciaEmpleados IN(
        SELECT TOP 15 IDVigenciaEmpleados 
        FROM @tempVigenciaEmpleados ORDER BY NEWID()
    )
    
	print('Elimine fechas de colaboradores al azar')

	-- Checadas de Entradas al Trabajo (ET)
	select e.*
		,h.HoraEntrada
		,h.HoraSalida
        ,CASE WHEN DF.IDDiaFestivo IS NOT NULL OR IE.IDIncidencia IS NOT NULL 
              THEN CASE WHEN ((ABS(CHECKSUM(NEWID(), E.IDEmpleado)) % 30) + 1)>1 THEN 0 ELSE 1 END
              ELSE NULL
              END AS TrabajaDiaFestivoDescanso		
        -- ,ROW_NUMBER()over(ORDER BY e.IDEmpleado, e.Fecha asc) as [Row]
        -- ,((ABS(CHECKSUM(NEWID(), E.IDEmpleado)) % 31) - 15) AS RandomMinutes
        ,dateadd(minute, ((ABS(CHECKSUM(NEWID(), E.IDEmpleado)) % 31) - 15) ,cast(e.Fecha as datetime) + cast(H.HoraEntrada as datetime)) AS FechaChecada
	INTO #tempFinalColaboradoresChecadasET
	from @tempVigenciaEmpleados e
		INNER JOIN @dtEmpleados DTE
            ON DTE.IDEmpleado=E.IDEmpleado
        LEFT JOIN Asistencia.tblChecadas c 
            on c.IDEmpleado = e.IDEmpleado 
            and c.FechaOrigen = e.Fecha 
            and c.IDTipoChecada = 'ET'
		LEFT JOIN Asistencia.tblHorariosEmpleados he 
            on he.IDEmpleado = e.IDEmpleado 
            and he.Fecha = e.Fecha
		LEFT JOIN Asistencia.tblCatHorarios h 
            on he.IDHorario = h.IDHorario
        LEFT JOIN Asistencia.tblIncidenciaEmpleado IE
            ON IE.IDEmpleado = E.IDEmpleado 
            AND IE.Fecha = E.Fecha
            AND IE.IDIncidencia='D'
        LEFT JOIN Nomina.tblCatTipoNomina CTN
            ON CTN.IDTipoNomina=dte.IDTipoNomina
        LEFT JOIN Asistencia.TblCatDiasFestivos DF
            ON DF.Fecha=E.Fecha 
            AND DF.IDPais=CTN.IDPais
            AND DF.Autorizado=1        
	where c.IDChecada is null 

    print('Termine de armar la tabla de checadas de entrada')

    Delete #tempFinalColaboradoresChecadasET where TrabajaDiaFestivoDescanso=0


    insert into Asistencia.tblChecadas
    SELECT 
     FechaChecada AS Fecha----Fecha de Lista
    ,Fecha as FechaOrigen----Fecha de Lista
    ,1 as IDLector
    ,IDEmpleado as IDEmpleado---IDEmpleado
    ,'ET' as IDTipoChecada----ET O ST
    ,@IDUsuarioAdmin AS IDUsuario---1
    ,'Checada Generada por el Servicio adagioRHDemo' as Comentario----Comentario generico
    ,Null as IDZonaHoraria---Null
    ,1 as Automatica---1
    ,GETDATE() as FechaReg-----GETDATE()
    ,FechaChecada as FechaOriginal---Fecha Lista
    ,NULL as Latitud---NULL
    ,NULL as [Longitud]---NULL
    FROM #tempFinalColaboradoresChecadasET


	print('Termine de insertar checadas de entrada')


	-- Checadas de Salidas al Trabajo (ST)
	select e.*
		,h.HoraEntrada
		,h.HoraSalida
		--,ROW_NUMBER()over(ORDER BY e.IDEmpleado, e.Fecha asc) as [Row]
        ,dateadd(minute, ((ABS(CHECKSUM(NEWID(), E.IDEmpleado)) % 31) - 15) ,cast(e.Fecha as datetime) + cast(H.HoraSalida as datetime)) AS FechaChecada
	INTO #tempFinalColaboradoresChecadasST
	from @tempVigenciaEmpleados e
		inner join #tempFinalColaboradoresChecadasET ET on ET.IDEmpleado=E.IDEmpleado and et.fecha=e.Fecha
        left join Asistencia.tblChecadas c on c.IDEmpleado = e.IDEmpleado and c.FechaOrigen = e.Fecha and c.IDTipoChecada = 'ST'
		left join Asistencia.tblHorariosEmpleados he on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
		left join Asistencia.tblCatHorarios h on he.IDHorario = h.IDHorario
	where c.IDChecada is null	  

	print('Termine de armar la tabla de checadas de salida y comienza el ciclo ')




    
    insert into Asistencia.tblChecadas
    SELECT 
     FechaChecada AS Fecha----Fecha de Lista
    ,Fecha as FechaOrigen----Fecha de Lista
    ,1 as IDLector
    ,IDEmpleado as IDEmpleado---IDEmpleado
    ,'ST' as IDTipoChecada----ET O ST
    ,@IDUsuarioAdmin AS IDUsuario---1
    ,'Checada Generada por el Servicio adagioRHDemo' as Comentario----Comentario generico
    ,Null as IDZonaHoraria---Null
    ,1 as Automatica---1
    ,GETDATE() as FechaReg-----GETDATE()
    ,FechaChecada as FechaOriginal---Fecha Lista
    ,NULL as Latitud---NULL
    ,NULL as [Longitud]---NULL
    FROM #tempFinalColaboradoresChecadasST

	print('Termine de armar la tabla de checadas de salida')
END
GO
