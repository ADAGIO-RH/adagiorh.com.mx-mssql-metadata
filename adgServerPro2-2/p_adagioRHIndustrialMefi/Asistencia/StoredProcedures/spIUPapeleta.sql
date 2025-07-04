USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Asistencia].[spIUPapeleta](
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
	,@IDIncidenciaEmpleado		int = 0
) as
     DECLARE 
        @OldJSON Varchar(Max),
    	@CALENDARIO0007 bit=0,
        @Message varchar(max),
        @NewJSON Varchar(Max),
		@SPCustomPostInsertPapeleta Varchar(max)
	;

	SELECT top 1 @SPCustomPostInsertPapeleta = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'SPCustomPostInsertPapeleta'

    if exists(select top 1 1 
	from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
		join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
	where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0007')
	begin
		set @CALENDARIO0007 = 1
    end;

    if (@CALENDARIO0007 = 0)
	begin
		if (@IDEmpleado = (isnull((SELECT IDEmpleado from Seguridad.tblUsuarios where IDUsuario = @IDUsuario),0)))
		begin
			
            set @Message = FORMATMESSAGE('No tienes permiso para modificar su propio calendario.')
			raiserror(@Message,16,1)
			return;			
		end
	end

	if (@IDPapeleta = 0 
	--and @IDIncidenciaEmpleado != (
	--	select IDIncidenciaEmpleado from Asistencia.tblIncidenciaEmpleado where IDIncidenciaEmpleado = 159195 )		 
	) 
	begin
		insert into Asistencia.tblPapeletas(IDEmpleado,IDIncidencia,FechaFin,FechaInicio,TiempoAutorizado,TiempoSugerido,Dias,Duracion,IDClasificacionIncapacidad,IDTipoIncapacidad
											,IDTipoLesion,IDTipoRiesgoIncapacidad,Numero,PagoSubsidioEmpresa,Permanente,DiasDescanso,Fecha,Comentario,ComentarioTextoPlano
											,Autorizado,PapeletaAutorizada,FechaHora,IDUsuario,IDIncidenciaEmpleado)
		select @IDEmpleado,@IDIncidencia,@FechaFin ,@FechaInicio,@TiempoAutorizado,@TiempoSugerido,@Dias,@Duracion,@IDClasificacionIncapacidad,@IDTipoIncapacidad
				,@IDTipoLesion,@IDTipoRiesgoIncapacidad,@Numero,@PagoSubsidioEmpresa,@Permanente,@DiasDescanso,@Fecha,@Comentario,@ComentarioTextoPlano
				,@Autorizado,@PapeletaAutorizada,GETDATE(),@IDUsuario, @IDIncidenciaEmpleado
	
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
		and IDIncidenciaEmpleado = @IDIncidenciaEmpleado

		select @NewJSON = a.JSON from [Asistencia].[tblPapeletas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPapeleta = @IDPapeleta

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblPapeletas]','[Asistencia].[spIUPapeleta]','UPDATE',@NewJSON,@OldJSON
		

	end;

	IF(ISNULL(@SPCustomPostInsertPapeleta,'') <> '')
	BEGIN
		exec sp_executesql N'exec @miSP @IDPapeleta , @IDUsuario'                   
			,N' @IDPapeleta int        
			,@IDUsuario int      
			,@miSP varchar(MAX)',                          
				@IDPapeleta = @IDPapeleta      
			,@IDUsuario = @IDUsuario             
			,@miSP = @SPCustomPostInsertPapeleta ; 
	END

	exec [Asistencia].[spBuscarPapeletas] @IDPapeleta=@IDPapeleta,@IDEmpleado=@IDEmpleado,@IDUsuario=@IDUsuario
GO
