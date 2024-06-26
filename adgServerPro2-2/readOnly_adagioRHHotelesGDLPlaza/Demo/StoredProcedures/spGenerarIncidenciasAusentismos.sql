USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Demo].[spGenerarIncidenciasAusentismos] (
	@FechaIni date
	,@FechaFin date

)as
declare 
	 @dtEmpleados [RH].[dtEmpleados]
	,@Fechas [App].[dtFechas]
	,@IDEmpleado int
	,@IDUsuarioAdmin int
;

	SET DATEFIRST 7;  
	SET LANGUAGE Spanish;
	SET DATEFORMAT ymd;

	select @IDUsuarioAdmin = cast(Valor as int)
	from  App.tblConfiguracionesGenerales
	where [IDConfiguracion] ='IDUsuarioAdmin'

	if not exists (select top 1 1 from Asistencia.tblCatIncidencias)
	begin
		raiserror('No existen incidencias en la catálogo.',16,1);
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
	
	-- Se eliminan los colaboradores NO VIGENTES y Fechas que no son Sábado o Domingo
	delete @tempVigenciaEmpleados where (Vigente = 0) or (DATEPART(DW,Fecha) not in (7,1))
	
	-- Se eliminan los colaboradores que ya tienen descanso en las fechas seleccionadas
	delete from e 
	from @tempVigenciaEmpleados e
		left join Asistencia.tblIncidenciaEmpleado ie
			on ie.IDEmpleado = e.IDEmpleado and ie.Fecha = e.Fecha and ie.IDIncidencia = 'D'
	where ie.IDIncidenciaEmpleado is not null

	select @IDEmpleado = min(distinct(IDEmpleado)) from @tempVigenciaEmpleados									
	
	while exists (select top 1 1 from @tempVigenciaEmpleados where IDEmpleado >= @IDEmpleado)
	begin
		begin try
			exec [Asistencia].[spIUIncidenciaEmpleado]
				@IDIncidenciaEmpleado		= 0
				,@IDEmpleado				= @IDEmpleado
				,@IDIncidencia				= 'D'
				,@FechaIni					= @FechaIni
				,@FechaFin					= @FechaFin
				,@Dias						= '7,1'
				,@TiempoSugerido			= null
				,@TiempoAutorizado			= null
				,@Comentario				= 'Descando genererado por Servicio Demo'
				,@ComentarioTextoPlano		= 'Descando genererado por Servicio Demo'
				,@CreadoPorIDUsuario		= @IDUsuarioAdmin
				,@Autorizado				= 1
				,@ConfirmarActualizar		= 1
		end try
		begin catch
			exec Demo.spGetErrorInfo 
		end catch

		select @IDEmpleado = min(distinct(IDEmpleado)) from @tempVigenciaEmpleados where IDEmpleado > @IDEmpleado; 									
	end;
GO
