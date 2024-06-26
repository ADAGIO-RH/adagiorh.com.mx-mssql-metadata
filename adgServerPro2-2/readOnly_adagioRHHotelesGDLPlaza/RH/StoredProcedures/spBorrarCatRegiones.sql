USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatRegiones]
(
	@IDRegion int,
	@IDUsuario int
)
AS
BEGIN

	Select 
	   IDRegion
	   ,Codigo
	   ,Descripcion
	   ,CuentaContable
	   ,isnull(IDEmpleado,0) as IDEmpleado
	   ,JefeRegion
	   ,ROW_NUMBER()over(ORDER BY IDRegion)as ROWNUMBER
    FROM RH.tblCatRegiones
    Where IDRegion = @IDRegion

			DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatRegiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDRegion = @IDRegion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatRegiones]','[RH].[spBorrarCatRegiones]','DELETE','',@OldJSON



    BEGIN TRY  
	   Delete RH.tblCatRegiones
	   where IDRegion = @IDRegion
    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


END
GO
