USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatParentesco]
(
	 @IDParentesco int,
	@IDUsuario int
)
AS
BEGIN

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[TblCatParentescos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDParentesco = @IDParentesco

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblCatParentescos]','[RH].[spBorrarCatParentesco]','DELETE','',@OldJSON



	EXEC [RH].[spBuscarCatParentesco] @IDParentesco = @IDParentesco

    BEGIN TRY  
	Delete RH.TblCatParentescos
	where IDParentesco = @IDParentesco
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
