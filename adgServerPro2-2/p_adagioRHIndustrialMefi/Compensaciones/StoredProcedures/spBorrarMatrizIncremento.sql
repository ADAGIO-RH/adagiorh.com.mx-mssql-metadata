USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Compensaciones].[spBorrarMatrizIncremento]
(
	@IDMatrizIncremento int,
	@IDUsuario int
)
AS
BEGIN

 

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [Compensaciones].[tblMatrizIncremento] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDMatrizIncremento = @IDMatrizIncremento

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Compensaciones].[tblMatrizIncremento]','[Compensaciones].[spBorrarMatrizIncremento]','DELETE','',@OldJSON

    BEGIN TRY  
	    DELETE [Compensaciones].[tblMatrizIncremento]
	    WHERE IDMatrizIncremento = @IDMatrizIncremento
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;


		
END
GO
