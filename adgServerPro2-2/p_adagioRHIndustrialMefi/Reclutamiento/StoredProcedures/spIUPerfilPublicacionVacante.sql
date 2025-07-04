USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Reclutamiento].[spIUPerfilPublicacionVacante](
	 @IDPerfilPublicacionVacante	int = 0
	,@IDPlaza	int
	,@IDModalidadTrabajo	int
	,@IDTipoTrabajo	int
	,@IDTipoContrato	int
	,@OcultarSalario	bit = 0
	,@DescripcionVacante Varchar(max) = null
	,@LinkVideo	varchar(max) = null
	,@Beneficios	varchar(max) = null
	,@Tags	varchar(max) = null
	,@VacantePCD	bit = 0
	,@EdadMinima	int = null
	,@EdadMaxima	int = null
	,@IDGenero	char = null
	,@AniosExperiencia	int = null
	,@IDEstudio	int = null
	,@FormacionComplementarioa	varchar(max) = null
	,@Idiomas	varchar(max) = null
	,@Habilidades	varchar(max) = null
	,@LicenciaConducir	bit = 0
	,@DisponibilidadViajar	bit = 0
	,@VehiculoPropio	bit = 0
	,@DisponibilidadCambioVivienda	bit = 0
	,@IncluirPreguntasFiltro	bit = 0
	,@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
	IF(@IDPerfilPublicacionVacante = 0 OR @IDPerfilPublicacionVacante Is null)
	BEGIN

	   INSERT INTO [Reclutamiento].[tblPerfilPublicacionVacante]
				   (
						 IDPlaza
						,IDModalidadTrabajo
						,IDTipoTrabajo
						,IDTipoContrato
						,OcultarSalario
						,DescripcionVacante
						,LinkVideo
						,Beneficios
						,Tags
						,VacantePCD
						,EdadMinima
						,EdadMaxima
						,IDGenero
						,AniosExperiencia
						,IDEstudio
						,FormacionComplementarioa
						,Idiomas
						,Habilidades
						,LicenciaConducir
						,DisponibilidadViajar
						,VehiculoPropio
						,DisponibilidadCambioVivienda
						,IncluirPreguntasFiltro
						,UUID
				   )
			 VALUES
				   (
				         @IDPlaza
						,@IDModalidadTrabajo
						,@IDTipoTrabajo
						,@IDTipoContrato
						,isnull(@OcultarSalario,0)
						,@DescripcionVacante
						,@LinkVideo
						,@Beneficios
						,@Tags
						,isnull(@VacantePCD,0)
						,@EdadMinima
						,@EdadMaxima
						,@IDGenero
						,@AniosExperiencia
						,@IDEstudio
						,@FormacionComplementarioa
						,@Idiomas
						,@Habilidades
						,isnull(@LicenciaConducir,0)
						,isnull(@DisponibilidadViajar,0)
						,isnull(@VehiculoPropio,0)
						,isnull(@DisponibilidadCambioVivienda,0)
						,isnull(@IncluirPreguntasFiltro,0)
						,NEWID()
				   )

		Set @IDPerfilPublicacionVacante = @@IDENTITY
		

		select @NewJSON = a.JSON from [Reclutamiento].[tblPerfilPublicacionVacante] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPerfilPublicacionVacante = @IDPerfilPublicacionVacante

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[spIUPerfilPublicacionVacante]','[Reclutamiento].[spIUPerfilPublicacionVacante]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
	

		select @OldJSON = a.JSON from [Reclutamiento].[tblPerfilPublicacionVacante] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPerfilPublicacionVacante = @IDPerfilPublicacionVacante

		UPDATE [Reclutamiento].[tblPerfilPublicacionVacante]
		   SET			 IDPlaza						= @IDPlaza									
						,IDModalidadTrabajo				= @IDModalidadTrabajo
						,IDTipoTrabajo					= @IDTipoTrabajo
						,IDTipoContrato					= @IDTipoContrato
						,OcultarSalario					= isnull(@OcultarSalario,0)
						,DescripcionVacante				= @DescripcionVacante
						,LinkVideo						= @LinkVideo
						,Beneficios						= @Beneficios
						,Tags							= @Tags
						,VacantePCD						= isnull(@VacantePCD,0)
						,EdadMinima						= @EdadMinima
						,EdadMaxima						= @EdadMaxima
						,IDGenero						= @IDGenero
						,AniosExperiencia				= @AniosExperiencia
						,IDEstudio						= @IDEstudio
						,FormacionComplementarioa		= @FormacionComplementarioa
						,Idiomas						= @Idiomas
						,Habilidades					= @Habilidades
						,LicenciaConducir				= isnull(@LicenciaConducir,0)
						,DisponibilidadViajar			= isnull(@DisponibilidadViajar,0)
						,VehiculoPropio					= isnull(@VehiculoPropio,0)
						,DisponibilidadCambioVivienda	= isnull(@DisponibilidadCambioVivienda,0)
						,IncluirPreguntasFiltro			= isnull(@IncluirPreguntasFiltro,0)
		 WHERE IDPerfilPublicacionVacante = @IDPerfilPublicacionVacante  



		select @NewJSON = a.JSON from [Reclutamiento].[tblPerfilPublicacionVacante] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPerfilPublicacionVacante = @IDPerfilPublicacionVacante

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[spIUPerfilPublicacionVacante]','[Reclutamiento].[spIUPerfilPublicacionVacante]','UPDATE',@NewJSON,@OldJSON
	END

END
GO
