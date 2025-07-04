USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Eliminar Cuestionario
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2020-06-02
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE proc [Salud].[spBorrarCuestionario](
	@IDCuestionario int
	,@IDUsuario int
) as
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Salud].[spBorrarCuestionario]',
		@Tabla		varchar(max) = '[Salud].[tblCuestionarios]',
		@Accion		varchar(20)	= 'DELETE',
		@Mensaje	varchar(max),
		@InformacionExtra	varchar(max)
	;

	BEGIN TRY  
		select @OldJSON = a.JSON 
		from [Salud].[tblCuestionarios] b with (nolock)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDCuestionario = @IDCuestionario

		delete [Salud].[tblPosiblesRespuestasPreguntas]
		where IDPregunta in (
			select IDPregunta
			from [Salud].[tblPreguntas] with (nolock)
			WHERE IDSeccion in (select IDSeccion 
								from [Salud].[tblSecciones] with (nolock) 
								where IDCuestionario = @IDCuestionario)
		)

		DELETE [Salud].[tblPreguntas] 
		WHERE IDSeccion in (select IDSeccion 
							from [Salud].[tblSecciones] with (nolock) 
							where IDCuestionario = @IDCuestionario)

		DELETE [Salud].[tblSecciones] WHERE IDCuestionario = @IDCuestionario
		DELETE [Salud].[tblCuestionarios] WHERE IDCuestionario = @IDCuestionario

		EXEC [Auditoria].[spIAuditoria]
			@IDUsuario		= @IDUsuario
			,@Tabla			= @Tabla
			,@Procedimiento	= @NombreSP
			,@Accion		= @Accion
			,@NewData		= @NewJSON
			,@OldData		= @OldJSON
			,@Mensaje		= @Mensaje
			,@InformacionExtra		= @InformacionExtra
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
