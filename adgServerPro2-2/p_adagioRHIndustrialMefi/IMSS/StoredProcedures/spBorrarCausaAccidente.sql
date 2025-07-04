USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [IMSS].[spBorrarCausaAccidente]
(
 @IDCausaAccidente int
 ,@IDUsuario int
)
as
BEGIN

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

		select @OldJSON = a.JSON from [IMSS].[tblCatCausasAccidentes] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCausaAccidente = @IDCausaAccidente

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatCausasAccidentes]','[RH].[spBorrarCausaAccidente]','DELETE','',@OldJSON
		

    BEGIN TRY  
	    DELETE [IMSS].[tblCatCausasAccidentes]
	    WHERE IDCausaAccidente = @IDCausaAccidente
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
