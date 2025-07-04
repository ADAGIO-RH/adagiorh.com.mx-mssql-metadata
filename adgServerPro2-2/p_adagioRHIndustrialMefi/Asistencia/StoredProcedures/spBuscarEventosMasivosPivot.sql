USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Buscar los eventos del calendario    
** Autor   : Jose Roman    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2018-11-25    
** Paremetros  :  @IDEmpleado int
      ,@Tipo int    
      ,@FechaInicio date    
      ,@FechaFin date    
      ,@IDUsuario int    
          
** Notas: Tipos de eventos:     
    0 - Incidencias    
    1 - Ausentismos    
    2 - Horarios    
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd)	Autor			Comentario    
------------------- ------------------- ------------------------------------------------------------    
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/    
CREATE proc [Asistencia].[spBuscarEventosMasivosPivot]--'20314,20315,20310',1,'D','2018-09-01','2018-11-30',1  
(    
     @Empleados varchar(max)  
	,@Tipo int 
	,@IDIncAus Varchar(5) 
    ,@FechaInicio date    
    ,@FechaFin date    
    ,@IDUsuario int    
) as    
  --  declare     
		--@dtEventos [Asistencia].[dtEventoCalendario];
    
    if object_id('tempdb..#TempIncidencias') is not null drop table #TempIncidencias;    
    if object_id('tempdb..#TempAusentismos') is not null drop table #TempAusentismos;    
    if object_id('tempdb..#tempHorarios') is not null drop table #tempHorarios;    
	if object_id('tempdb..#tempFechas') is not null drop table #tempFechas;   
	if object_id('tempdb..#tempFechasEmpleados') is not null drop table #tempFechasEmpleados;    

	create table #tempFechas(Fecha date);

	WITH DateRange(DateData) AS 
	(
		SELECT @FechaInicio as Date
		UNION ALL
		SELECT DATEADD(d,1,DateData)
		FROM DateRange 
		WHERE DateData < @FechaFin
	)
	insert into #tempFechas(Fecha) 
	SELECT DateData	
	FROM DateRange
	OPTION (MAXRECURSION 0)

	select distinct
		  f.Fecha
		  ,em.IDEmpleado
		  ,em.ClaveEmpleado
		  ,em.NOMBRECOMPLETO as NombreCompleto
		  ,em.Puesto
		  ,em.Departamento
		  ,em.Sucursal
	into #tempFechasEmpleados
	from #tempFechas f
		cross apply app.Split(@Empleados,',') e
		inner join rh.tblEmpleadosMaster em
			on e.item = em.IDEmpleado
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario

    create table #TempIncidencias(    
		IDIncidenciaEmpleado int     
		,IDEmpleado int     
		,IDIncidencia varchar(10)    
		,Incidencia varchar(255)    
		,Fecha date    
		,TiempoSugerido time    
		,TiempoAutorizado time    
		,Comentario nvarchar(max)    
		,CreadoPorIDUsuario int    
		,CreadoPorUsuario varchar(600)    
		,Autorizado bit    
		,AutorizadoPor int    
		,AutorizadoPorUsuario varchar(600)    
		,FechaHoraAutorizacion datetime    
		,FechaHoraCreacion datetime     
		,IDIncapacidadEmpleado int     
		,allDay Bit    
		,Color varchar(20)    
    );    

    create table #TempAusentismos(    
		IDIncidenciaEmpleado int     
		,IDEmpleado int     
		,IDIncidencia varchar(10)    
		,Incidencia varchar(255)    
		,Fecha date    
		,TiempoSugerido time    
		,TiempoAutorizado time    
		,Comentario nvarchar(max)    
		,CreadoPorIDUsuario int    
		,CreadoPorUsuario varchar(600)    
		 ,Autorizado bit    
		,AutorizadoPor int    
		,AutorizadoPorUsuario varchar(600)    
		 ,FechaHoraAutorizacion datetime    
		,FechaHoraCreacion datetime     
		,IDIncapacidadEmpleado int     
		,allDay Bit    
		,Color varchar(20)    
    );   
	 
    create TABLE #tempHorarios(    
		IDHorarioEmpleado int    
		,IDEmpleado int    
		,IDHorario int    
		,CodigoHorario varchar(100)    
		,Horario varchar(255)    
		,HoraEntrada time    
		,HoraSalida time    
		,Fecha datetime    
		,Dia varchar(20)     
		,FechaHoraRegistro datetime    
    );   
	
	Declare @IDEmpleado int
	 
	if(@Tipo = 1)
	BEGIN
		select @IDEmpleado = min(IDEmpleado) from #tempFechasEmpleados

		while(@IDEmpleado <= (select Max(IDEmpleado) from #tempFechasEmpleados))
		BEGIN
			insert into #TempAusentismos    
			exec [Asistencia].[spBuscarIncidenciasAusentismosEmpleadoFecha]    
			@IDEmpleado    
			,@FechaInicio        
			,@FechaFin   
			,@IDUsuario    
			,@Tipo = 1   
			
			set @IDEmpleado = (select min(IDEmpleado) from  #tempFechasEmpleados where IDEmpleado > @IDEmpleado)
		END

		select fe.Fecha,
			   fe.IDEmpleado,
			   fe.ClaveEmpleado,
			   fe.NombreCompleto,
			   fe.Puesto,
			   fe.Departamento,
			   fe.Sucursal,
			   isnull(a.IDIncidenciaEmpleado,0) as IDIncidenciaEmpleado,
			   a.IDIncidencia,
			   a.Incidencia
		from #tempFechasEmpleados fe
			left join #TempAusentismos a
				on fe.IDEmpleado = a.IDEmpleado
					and fe.Fecha = a.Fecha
					and a.IDIncidencia = @IDINCAUS

    END
	if(@Tipo = 0)
	BEGIN
		select @IDEmpleado = min(IDEmpleado) from #tempFechasEmpleados

		while(@IDEmpleado <= (select Max(IDEmpleado) from #tempFechasEmpleados))
		BEGIN
			insert into #TempIncidencias    
			exec [Asistencia].[spBuscarIncidenciasAusentismosEmpleadoFecha]    
			@IDEmpleado    
			,@FechaInicio        
			,@FechaFin    
			,@IDUsuario    
			,@Tipo = 0    

		  set @IDEmpleado = (select min(IDEmpleado) from  #tempFechasEmpleados where IDEmpleado > @IDEmpleado)
		END;

		select fe.Fecha,
			fe.IDEmpleado,
			fe.ClaveEmpleado,
			fe.NombreCompleto,
			fe.Puesto,
			fe.Departamento,
			fe.Sucursal,
			isnull(a.IDIncidenciaEmpleado,0) as IDIncidenciaEmpleado,
			a.IDIncidencia,
			a.Incidencia
		from #tempFechasEmpleados fe
			left join #TempIncidencias a on fe.IDEmpleado = a.IDEmpleado
				and fe.Fecha = a.Fecha
				and a.IDIncidencia = @IDINCAUS
    END

	--IF(@Tipo = 2)
	--BEGIN
	--	INSERT into #tempHorarios    
	--	exec [Asistencia].[spBuscarHorariosEmpleados]    
	--	 @IDEmpleado = @IDEmpleado    
	--	,@FechaInicio   = @FechaInicio    
	--	,@FechaFin  = @FechaFin    
	--	,@IDUsuario = @IDUsuario    
	--END
 
    
 --   insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor)    
 --   select IDIncidenciaEmpleado,2,IDEmpleado,Incidencia,allDay,Fecha,Fecha,null, Color, null, null, null    
 --   from #TempAusentismos    
    
 --   insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor)    
 --   select IDIncidenciaEmpleado,1,IDEmpleado,Incidencia,allDay,Fecha,Fecha,null, Color, null, null, null    
 --   from #TempIncidencias    
    
 --   insert into @dtEventos(id,TipoEvento,IDEmpleado,title,allDay,start,[end],url,color,backgroundColor,borderColor,textColor)    
 --   select IDHorarioEmpleado,3,IDEmpleado,CodigoHorario,0,CAST(Fecha AS DATETIME) + CAST(HoraEntrada AS DATETIME),CAST(Fecha AS DATETIME) + CAST(HoraSalida AS DATETIME),null,'#000e55',null,NULL,null from #tempHorarios    
  
 --   select     
 --   id    
 --   ,TipoEvento    
 --   ,IDEmpleado    
 --   ,title    
 --   ,allDay    
 --   ,start    
 --   ,[end]    
 --   ,url    
 --   ,color    
 --   ,backgroundColor    
 --   ,borderColor    
 --   ,textColor    
 --   from @dtEventos
GO
