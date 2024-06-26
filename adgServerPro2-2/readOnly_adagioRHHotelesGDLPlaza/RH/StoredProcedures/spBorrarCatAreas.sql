USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatAreas]
(
	@IDArea int,
	@IDUsuario int
)
AS
BEGIN

		SELECT 
			IDArea
			,Codigo
			,Descripcion
			,CuentaContable
			,isnull(IDEmpleado,0) as IDEmpleado
			,JefeArea
		FROM [RH].[tblCatArea]
		WHERE IDArea = @IDArea
	
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatArea] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDArea = @IDArea

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatArea]','[RH].[spBorrarCatAreas]','DELETE','',@OldJSON

	
    BEGIN TRY  
	DELETE RH.tblCatArea
	WHERE IDArea = @IDArea
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
