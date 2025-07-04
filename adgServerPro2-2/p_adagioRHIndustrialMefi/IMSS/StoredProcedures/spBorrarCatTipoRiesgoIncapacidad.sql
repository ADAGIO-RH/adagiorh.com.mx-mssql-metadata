USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [IMSS].[spBorrarCatTipoRiesgoIncapacidad]
(
 @IDTipoRiesgoIncapacidad int
 ,@IDUsuario int
)
as
BEGIN

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

		select @OldJSON = a.JSON from [IMSS].[tblCatTipoRiesgoIncapacidad] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoRiesgoIncapacidad = @IDTipoRiesgoIncapacidad

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoRiesgoIncapacidad]','[RH].[spBorrarCatTipoRiesgoIncapacidad]','DELETE','',@OldJSON
		

    BEGIN TRY  
	    DELETE [IMSS].tblCatTipoRiesgoIncapacidad
	    WHERE IDTipoRiesgoIncapacidad = @IDTipoRiesgoIncapacidad
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
END
GO
