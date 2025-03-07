USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Asistencia].[spValidacionChecadaCalendarioCustom](
	@IDChecada int    
	,@Fecha Datetime    
	,@FechaOrigen Date =null  
	,@IDEmpleado int    
	,@IDTipoChecada varchar(20)    
	,@IDUsuario int    
	,@Comentario varchar(500)    
	,@IDLector int = 0
) as

	declare
		@MAXIMO_CHECADAS_PERMITIDAS int = 3,
		@ID_PERFIL_ADMIN int = 1,
		@ID_PERFIL_ADMINISTRADOR int = 4,
		@Total int,
		@IDPerfilUsuario int,
		@IDPeriodo int,
		@NombreCompleto varchar(max),
		@FechaInicio date,
		@FechaFin date,
		@MensajeError varchar(200)
	;

	select @IDPerfilUsuario = IDPerfil
	from Seguridad.tblUsuarios
	where IDUsuario = @IDUsuario

	if (@IDPerfilUsuario in (@ID_PERFIL_ADMINISTRADOR, @ID_PERFIL_ADMIN)) 
		return 

	if (@Comentario = 'Importación Checadas') 
		return 

	select 
		@FechaInicio = p.FechaInicioIncidencia,
		@FechaFin = p.FechaFinIncidencia,
		@NombreCompleto = e.ClaveEmpleado+ ' - '+e.NOMBRECOMPLETO
	from RH.tblEmpleadosMaster e
		join Nomina.tblCatPeriodos p on p.IDTipoNomina = e.IDTipoNomina
	where e.IDEmpleado = @IDEmpleado and @FechaOrigen between p.FechaInicioIncidencia and p.FechaFinIncidencia
		and p.General = 1

	select @Total =  COUNT(IDChecada)
	from Asistencia.tblChecadas
	where IDEmpleado = @IDEmpleado 
		and IDUsuario = @IDUsuario
		and FechaOrigen between @FechaInicio and @FechaFin

	if (@Total >= @MAXIMO_CHECADAS_PERMITIDAS)
	begin
		set @MensajeError = FORMATMESSAGE('Ya excediste el máximo(%d) de checadas(%d) creadas/modificadas para el colaborador %s en este periodo.',@MAXIMO_CHECADAS_PERMITIDAS, @Total, @NombreCompleto)

	    EXEC [log].[spILogHistory]
			@LogLevel = 'error'
			,@Mensaje = @MensajeError
			,@IDSource	   = 'Calendario'
			,@IDCategory   = 'Checadas'
			,@IDAplicacion = 'Asistencia'
			,@IDUsuario = @IDUsuario
		
		raiserror(@MensajeError, 16, 1)
		return
	end

GO
