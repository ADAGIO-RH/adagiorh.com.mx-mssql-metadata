USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [Asistencia].[spBorrarCatHorario](
	@IDHorario int
	,@IDUsuario int
) as

  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [Asistencia].[tblCatHorarios] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDHorario = @IDHorario

	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblCatHorarios]','[Asistencia].[spBorrarCatHorario]','DELETE','',@OldJSON
		

	BEGIN TRY  
		DELETE Asistencia.tblCatHorarios WHERE IDHorario = @IDHorario
	END TRY  
	BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END CATCH ;
GO
