USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [STPS].[spBorrarProgramasCapacitacionDC2]
(
	@IDProgramaCapacitacion int,
	@IDUsuario int
)
AS
BEGIN


		DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [STPS].[tblProgramasCapacitacionDC2] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDProgramaCapacitacion = @IDProgramaCapacitacion

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[STPS].[tblProgramasCapacitacionDC2]','[STPS].[spBorrarProgramasCapacitacionDC2]','DELETE','',@OldJSON

    BEGIN TRY  
	    DELETE [STPS].[tblProgramasCapacitacionDC2] 
	    WHERE IDProgramaCapacitacion = @IDProgramaCapacitacion
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;


		
END
GO
