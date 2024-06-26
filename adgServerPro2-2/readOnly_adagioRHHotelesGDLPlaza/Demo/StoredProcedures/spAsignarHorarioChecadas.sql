USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Demo].[spAsignarHorarioChecadas] (
	@FechaIni date
	,@FechaFin date
)as
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
		IDEmpleado int null,    
		Fecha Date null,    
		Vigente bit null		
	); 

	insert into @Fechas
	exec [App].[spListaFechas]@FechaIni,@FechaFin

	insert @dtEmpleados
	exec RH.spBuscarEmpleados @FechaIni = @FechaIni
							 ,@Fechafin = @FechaFin
							 ,@IDUsuario = @IDUsuarioAdmin
						 
	insert @tempVigenciaEmpleados
	exec [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleados= @dtEmpleados
													,@Fechas= @Fechas
													,@IDUsuario = @IDUsuarioAdmin
	
	-- Se eliminan los colaboradores NO VIGENTES
	delete @tempVigenciaEmpleados where Vigente = 0														

	select e.*
	INTO #tempFinalColaboradoresHorarios
	from @tempVigenciaEmpleados e
		left join Asistencia.tblHorariosEmpleados he on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
	where he.IDHorario is null		
	
	select @IDEmpleado = min(distinct(IDEmpleado)) from #tempFinalColaboradoresHorarios									
	
	while exists (select top 1 1 from #tempFinalColaboradoresHorarios where IDEmpleado >= @IDEmpleado)
	begin
		-- Getting random IDHorario
		select top 1 @IDHorario = IDHorario
		from Asistencia.tblCatHorarios
		order by NEWID()

		begin try
			insert into Asistencia.tblHorariosEmpleados(IDEmpleado,IDHorario,Fecha)
			select IDEmpleado,@IDHorario,Fecha
			from #tempFinalColaboradoresHorarios
			where IDEmpleado = @IDEmpleado
		end try
		begin catch
			exec Demo.spGetErrorInfo 
		end catch
	
		select @IDEmpleado = min(distinct(IDEmpleado)) from #tempFinalColaboradoresHorarios where IDEmpleado > @IDEmpleado; 									
	end;									

	--Se eliminan todos los Miércoles para que se generen faltas estos días
	delete from @tempVigenciaEmpleados where DATEPART(DW,Fecha) = 4

	-- Checadas de Entradas al Trabajo (ET)
	select e.*
		,h.HoraEntrada
		,h.HoraSalida
		,ROW_NUMBER()over(ORDER BY e.IDEmpleado, e.Fecha asc) as [Row]
	INTO #tempFinalColaboradoresChecadasET
	from @tempVigenciaEmpleados e
		left join Asistencia.tblChecadas c on c.IDEmpleado = e.IDEmpleado and c.FechaOrigen = e.Fecha and c.IDTipoChecada = 'ET'
		left join Asistencia.tblHorariosEmpleados he on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
		left join Asistencia.tblCatHorarios h on he.IDHorario = h.IDHorario
	where c.IDChecada is null

	select @Row = min([Row]) from #tempFinalColaboradoresChecadasET	

	while exists (select top 1 1 from #tempFinalColaboradoresChecadasET where [Row] >= @Row)
	begin
		select @RandomMinutes = cast(rand(cast(newid() as varbinary))  * 16 as int)
			 ,@LessPlus =  cast(rand(cast(newid() as varbinary))  * 2 as int)
				 
		select 
			@IDEmpleado = IDEmpleado
			,@Fecha = Fecha
			,@HoraEntrada = HoraEntrada
		from #tempFinalColaboradoresChecadasET	where [Row] = @Row

		set @FechaHoraChecada = dateadd(minute,case when @LessPlus = 1 then @RandomMinutes else @RandomMinutes * -1 end,cast(@Fecha as datetime) + cast(@HoraEntrada as datetime))   

		
		begin try
			insert @tempChecadaResult
			exec [Asistencia].[spUIChecada]
				 @IDChecada = 0    
				 ,@Fecha = @FechaHoraChecada
				 ,@IDEmpleado = @IDEmpleado    
				 ,@IDTipoChecada = 'ET'
				 ,@IDUsuario = @IDUsuarioAdmin    
				 ,@Comentario = 'Checada Generada por el Servicio adagioRHDemo'
		end try
		begin catch
			exec Demo.spGetErrorInfo 
		end catch


		select @Row = min([Row]) from #tempFinalColaboradoresChecadasET	where [Row] > @Row
	end;

	-- Checadas de Salidas al Trabajo (ST)
	select e.*
		,h.HoraEntrada
		,h.HoraSalida
		,ROW_NUMBER()over(ORDER BY e.IDEmpleado, e.Fecha asc) as [Row]
	INTO #tempFinalColaboradoresChecadasST
	from @tempVigenciaEmpleados e
		left join Asistencia.tblChecadas c on c.IDEmpleado = e.IDEmpleado and c.FechaOrigen = e.Fecha and c.IDTipoChecada = 'ST'
		left join Asistencia.tblHorariosEmpleados he on he.IDEmpleado = e.IDEmpleado and he.Fecha = e.Fecha
		left join Asistencia.tblCatHorarios h on he.IDHorario = h.IDHorario
	where c.IDChecada is null	  

	select @Row = min([Row]) from #tempFinalColaboradoresChecadasST	

	while exists (select top 1 1 from #tempFinalColaboradoresChecadasST where [Row] >= @Row)
	begin
		select @RandomMinutes = cast(rand(cast(newid() as varbinary))  * 16 as int)
				 
		select 
			@IDEmpleado = IDEmpleado
			,@Fecha = Fecha
			,@HoraSalida = HoraSalida
		from #tempFinalColaboradoresChecadasST	where [Row] = @Row

		set @FechaHoraChecada = dateadd(minute, @RandomMinutes,cast(@Fecha as datetime) + cast(@HoraSalida as datetime)) 

		begin try
			insert @tempChecadaResult
			exec [Asistencia].[spUIChecada]
				 @IDChecada = 0    
				 ,@Fecha = @FechaHoraChecada
				 ,@IDEmpleado = @IDEmpleado    
				 ,@IDTipoChecada = 'ET'
				 ,@IDUsuario = @IDUsuarioAdmin    
				 ,@Comentario = 'Checada Generada por el Servicio adagioRHDemo'
		end try
		begin catch
			exec Demo.spGetErrorInfo 
		end catch

		select @Row = min([Row]) from #tempFinalColaboradoresChecadasST	where [Row] > @Row
	end;
GO
