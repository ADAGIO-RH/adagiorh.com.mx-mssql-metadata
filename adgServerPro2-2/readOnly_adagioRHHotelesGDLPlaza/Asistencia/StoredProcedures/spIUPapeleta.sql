USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spIUPapeleta](
	 @IDPapeleta			int = 0
	,@IDEmpleado			int 
	,@IDIncidencia		varchar(10) 
	,@FechaInicio		date 
	,@FechaFin			date 
	,@TiempoAutorizado	time
	,@TiempoSugerido	time
	,@Dias				varchar(20)
	,@Duracion			int 
 
	,@IDClasificacionIncapacidad int
	,@IDTipoIncapacidad			int
	,@IDTipoLesion				int
	,@IDTipoRiesgoIncapacidad	int
	,@Numero					varchar(100)
	,@PagoSubsidioEmpresa		bit
	,@Permanente				bit
	,@DiasDescanso				varchar(20)
	,@Fecha						date
	,@Comentario				nvarchar(max)
	,@ComentarioTextoPlano		nvarchar(max)
	,@Autorizado				bit
	,@PapeletaAutorizada		bit
	,@IDUsuario					int 
) as

 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);
	if (@IDPapeleta = 0) 
	begin
		insert into Asistencia.tblPapeletas(IDEmpleado,IDIncidencia,FechaFin,FechaInicio,TiempoAutorizado,TiempoSugerido,Dias,Duracion,IDClasificacionIncapacidad,IDTipoIncapacidad
											,IDTipoLesion,IDTipoRiesgoIncapacidad,Numero,PagoSubsidioEmpresa,Permanente,DiasDescanso,Fecha,Comentario,ComentarioTextoPlano
											,Autorizado,PapeletaAutorizada,FechaHora,IDUsuario)
		select @IDEmpleado,@IDIncidencia,@FechaFin ,@FechaInicio,@TiempoAutorizado,@TiempoSugerido,@Dias,@Duracion,@IDClasificacionIncapacidad,@IDTipoIncapacidad
				,@IDTipoLesion,@IDTipoRiesgoIncapacidad,@Numero,@PagoSubsidioEmpresa,@Permanente,@DiasDescanso,@Fecha,@Comentario,@ComentarioTextoPlano
				,@Autorizado,@PapeletaAutorizada,GETDATE(),@IDUsuario
	
		set @IDPapeleta = @@IDENTITY

		select @NewJSON = a.JSON from [Asistencia].[tblPapeletas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPapeleta = @IDPapeleta

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblPapeletas]','[Asistencia].[spIUPapeleta]','INSERT',@NewJSON,''
		
	end else
	begin
		
		select @OldJSON = a.JSON from [Asistencia].[tblPapeletas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPapeleta = @IDPapeleta

		update Asistencia.tblPapeletas 
			set  FechaFin					= @FechaFin
				,FechaInicio				= @FechaInicio
				,TiempoAutorizado			= @TiempoAutorizado
				,TiempoSugerido				= @TiempoSugerido
				,Dias						= @Dias
				,Duracion					= @Duracion
				,IDClasificacionIncapacidad	= @IDClasificacionIncapacidad
				,IDTipoIncapacidad			= @IDTipoIncapacidad
				,IDTipoLesion				= @IDTipoLesion
				,IDTipoRiesgoIncapacidad	= @IDTipoRiesgoIncapacidad
				,Numero						= @Numero
				,PagoSubsidioEmpresa		= @PagoSubsidioEmpresa
				,Permanente					= @Permanente
				,DiasDescanso				= @DiasDescanso
				,Fecha						= @Fecha
				,Comentario					= @Comentario
				,ComentarioTextoPlano		= @ComentarioTextoPlano
				,Autorizado					= @Autorizado
		where IDPapeleta = @IDPapeleta

		select @NewJSON = a.JSON from [Asistencia].[tblPapeletas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPapeleta = @IDPapeleta

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblPapeletas]','[Asistencia].[spIUPapeleta]','UPDATE',@NewJSON,@OldJSON
		

	end;

	exec [Asistencia].[spBuscarPapeletas] @IDPapeleta=@IDPapeleta,@IDEmpleado=@IDEmpleado,@IDUsuario=@IDUsuario
GO
