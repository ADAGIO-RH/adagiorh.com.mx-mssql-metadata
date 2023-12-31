USE [p_adagioRHEnimsa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spAutorizarIncidenciaEmpleado]  
(  
 @IDIncidenciaEmpleado int,  
 @IDEmpleado int,  
 @IDIncidencia varchar(20),  
 @TiempoAutorizado Time,  
 @Comentario Varchar(MAX),  
 @Autorizado bit, 
 @IDUsuario int  
)  
  
AS  
BEGIN  

 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max),
	@EsAusentismo bit,
	@AutorizacionAusentismos0001 bit = 0,
	@AutorizacionIncidencias0001 bit = 0
	;

	/*
		,(1575, 'AutorizacionAusentismos0001','Puede autorizar ausentismos.')
			,(1575, 'AutorizacionIncidencias0001','Puede autorizar incidencias.')
	*/

	select @EsAusentismo = isnull(EsAusentismo,0)
	from [Asistencia].[tblCatIncidencias] with (nolock)
	where IDIncidencia = @IDIncidencia


	if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'AutorizacionAusentismos0001')
		begin
			set @AutorizacionAusentismos0001 = 1
		end;

	if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'AutorizacionIncidencias0001')
		begin
			set @AutorizacionIncidencias0001 = 1
		end;

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


		select @OldJSON = a.JSON from [Asistencia].[tblIncidenciaEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDIncidenciaEmpleado = @IDIncidenciaEmpleado  
		and IDIncidencia = @IDIncidencia  
		and IDEmpleado = @IDEmpleado  

	UPDATE Asistencia.tblIncidenciaEmpleado  
	set TiempoAutorizado = @TiempoAutorizado,  
		Autorizado = @Autorizado,  
		AutorizadoPor = case when @Autorizado = 1 then @IDUsuario else Null END,  
		FechaHoraAutorizacion = case when @Autorizado = 1 then getdate() else Null END  ,
		Comentario = @Comentario
	Where IDIncidenciaEmpleado = @IDIncidenciaEmpleado  
		and IDIncidencia = @IDIncidencia  
		and IDEmpleado = @IDEmpleado  
  
  select @NewJSON = a.JSON from [Asistencia].[tblIncidenciaEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDIncidenciaEmpleado = @IDIncidenciaEmpleado  
		and IDIncidencia = @IDIncidencia  
		and IDEmpleado = @IDEmpleado  

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spAutorizarIncidenciaEmpleado]','UPDATE',@NewJSON,@OldJSON
		
	--exec Asistencia.spBuscarIncidenciasEmpleadosAutorizacion @IDIncidenciaEmpleado = @IDIncidenciaEmpleado, @IDUsuario = @IDUsuario   
END
GO
