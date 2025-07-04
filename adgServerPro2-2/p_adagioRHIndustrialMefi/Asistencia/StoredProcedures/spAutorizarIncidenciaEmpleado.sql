USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spAutorizarIncidenciaEmpleado](  
	@IDIncidenciaEmpleado int,  
	@IDEmpleado int,  
	@IDIncidencia varchar(20),  
	@TiempoAutorizado Time,  
	@Comentario Varchar(MAX),  
	@Autorizado bit, 
	@IDUsuario int  
) AS  
BEGIN  
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@EsAusentismo bit,
		@AutorizacionAusentismos0001 bit = 0,
		@AutorizacionIncidencias0001 bit = 0
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
		,@FechaIncidencia date
		,@Message varchar(max)
	;

	/*
		,(1575, 'AutorizacionAusentismos0001','Puede autorizar ausentismos.')
			,(1575, 'AutorizacionIncidencias0001','Puede autorizar incidencias.')
	*/

	select @EsAusentismo = isnull(EsAusentismo,0)
	from [Asistencia].[tblCatIncidencias] with (nolock)
	where IDIncidencia = @IDIncidencia

	if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'AutorizacionAusentismos0001')
	begin
		set @AutorizacionAusentismos0001 = 1
	end;

	if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'AutorizacionIncidencias0001')
	begin
		set @AutorizacionIncidencias0001 = 1
	end;

	if exists(select top 1 1 
		from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
			join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO')
	begin
		set @DIAS_MODIFICAR_CALENDARIO = 1

		select @DIAS_MODIFICAR_CALENDARIO_DIAS = CAST(isnull(cpe.[Data], 0) as int)
		from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
			join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO'
	end;

	select 
		@FechaIncidencia = Fecha
	from [Asistencia].[tblIncidenciaEmpleado]
	WHERE IDIncidenciaEmpleado = @IDIncidenciaEmpleado and IDIncidencia = @IDIncidencia  
		and IDEmpleado = @IDEmpleado  

	if (@EsAusentismo = 1 and @AutorizacionAusentismos0001 = 0)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CustomMessage = 'No tiene Permiso para Autorizar Ausentismos'
		return 0;
	END;

	if (@EsAusentismo = 0 and @AutorizacionIncidencias0001 = 0)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CustomMessage = 'No tiene Permiso para Autorizar Incidencias'
		return 0;
	END;

	if (@DIAS_MODIFICAR_CALENDARIO = 1)
	begin
		set @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA = DATEADD(DAY, @DIAS_MODIFICAR_CALENDARIO_DIAS * -1, GETDATE())

		if (@FechaIncidencia < @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA)
		begin
			set @Message = FORMATMESSAGE('No tienes permiso para autorizar ausentismos o incidencias mayores a %d dias previos.', @DIAS_MODIFICAR_CALENDARIO_DIAS)

			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CustomMessage = @Message
			return 0;
		end
	end

	select @OldJSON = a.JSON from [Asistencia].[tblIncidenciaEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDIncidenciaEmpleado = @IDIncidenciaEmpleado  and IDIncidencia = @IDIncidencia and IDEmpleado = @IDEmpleado  

	UPDATE Asistencia.tblIncidenciaEmpleado  
	set TiempoAutorizado = @TiempoAutorizado,  
		Autorizado = @Autorizado,  
		AutorizadoPor = case when @Autorizado = 1 then @IDUsuario else Null END,  
		FechaHoraAutorizacion = case when @Autorizado = 1 then getdate() else Null END  ,
		Comentario = @Comentario
	Where IDIncidenciaEmpleado = @IDIncidenciaEmpleado and IDIncidencia = @IDIncidencia  
		and IDEmpleado = @IDEmpleado  
  
	select @NewJSON = a.JSON from [Asistencia].[tblIncidenciaEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDIncidenciaEmpleado = @IDIncidenciaEmpleado and IDIncidencia = @IDIncidencia  
		and IDEmpleado = @IDEmpleado  

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spAutorizarIncidenciaEmpleado]','UPDATE',@NewJSON,@OldJSON
		
	--exec Asistencia.spBuscarIncidenciasEmpleadosAutorizacion @IDIncidenciaEmpleado = @IDIncidenciaEmpleado, @IDUsuario = @IDUsuario   
END
GO
