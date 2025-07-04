USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc Evaluacion360.spBorrarIndicador(
	@IDIndicador	int = 0
	,@IDUsuario int
) as
	
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	select @OldJSON = a.JSON 
	from Evaluacion360.tblCatIndicadores b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDIndicador = @IDIndicador

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Evaluacion360].[tblCatIndicadores]','[Evaluacion360].[spBorrarIndicador]','DELETE','',@OldJSON
	
    BEGIN TRY  
		DELETE Evaluacion360.tblCatIndicadores
		WHERE IDIndicador = @IDIndicador
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO
