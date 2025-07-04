USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Demo.spEjecutarProcesosDemo as

	declare 
		@FechaIni date  
		,@FechaFin date  
		,@IDUsuarioAdmin int
	;

	SELECT @FechaIni = DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)
		  ,@FechaFin = DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0))

	select @IDUsuarioAdmin = cast(Valor as int)
	from  App.tblConfiguracionesGenerales
	where [IDConfiguracion] ='IDUsuarioAdmin'

	insert Demo.tblLogActividades(Error,Mensaje)
	select 0,'Inicia Proceso DEMO '+cast(getdate() as varchar)

	begin try
		insert Demo.tblLogActividades(Error,Mensaje)
		select 0,'Ejecuta [Demo].[spAsignarHorarioChecadas] '+cast(getdate() as varchar)
		exec [Demo].[spAsignarHorarioChecadas] @Fechaini = @Fechaini, @FechaFin = @FechaFin
	end try
	begin catch
		exec Demo.spGetErrorInfo 
	end catch

	begin try
		insert Demo.tblLogActividades(Error,Mensaje)
		select 0,'Ejecuta [Demo].[spGenerarIncidenciasAusentismos] '+cast(getdate() as varchar)
		exec [Demo].[spGenerarIncidenciasAusentismos] @Fechaini = @Fechaini, @FechaFin = @FechaFin
	end try
	begin catch
		exec Demo.spGetErrorInfo 
	end catch

	begin try
		insert Demo.tblLogActividades(Error,Mensaje)
		select 0,'Ejecuta [Demo].[spGenerarPeriodos] '+cast(getdate() as varchar)

		exec [Demo].[spGenerarPeriodos]
	end try
	begin catch
		exec Demo.spGetErrorInfo 
	end catch

	begin try

		insert Demo.tblLogActividades(Error,Mensaje)
		select 0,'Ejecuta [Demo].[spGenerarIncidencias] '+cast(getdate() as varchar)

		exec Asistencia.spGenerarIncidencias @FechaIni = @FechaIni
											,@FechaFin = @FechaFin
											,@EmpleadoIni = '0'
											,@EmpleadoFin = 'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz'
											,@IDUsuario = @IDUsuarioAdmin
	end try
	begin catch
		exec Demo.spGetErrorInfo 
	end catch

	begin try
		insert Demo.tblLogActividades(Error,Mensaje)
		select 0,'Ejecuta [Demo].[spCerrarPeriodosAnteriores] '+cast(getdate() as varchar)

		exec [Demo].[spCerrarPeriodosAnteriores]
	end try
	begin catch
		exec Demo.spGetErrorInfo 
	end catch


	insert Demo.tblLogActividades(Error,Mensaje)
	select 0,'Termina el Proceso DEMO '+cast(getdate() as varchar)


	--select *
	----delete
	--from Asistencia.tblIncidenciaEmpleado
	--where IDIncidencia = 'D' and Fecha between @FechaIni and @FechaFin
GO
