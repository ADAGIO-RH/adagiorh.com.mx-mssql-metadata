USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [IMSS].[spBorrarCatTiposLesion]
(
 @IDTipoLesion int
 ,@IDUsuario int
)
as
BEGIN

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

		select @OldJSON = a.JSON from [IMSS].[tblCatTiposLesiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoLesion = @IDTipoLesion

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposLesiones]','[RH].[spBorrarCatTiposLesion]','DELETE','',@OldJSON
		

    BEGIN TRY  
	    DELETE [IMSS].tblCatTiposLesiones
	    WHERE IDTipoLesion = @IDTipoLesion
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
