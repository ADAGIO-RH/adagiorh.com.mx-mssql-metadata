USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatDivisiones]
(
	@IDDivision int,
	@IDUsuario int
)
AS
BEGIN

	Select 
	   IDDivision
	   ,Codigo
	   ,Descripcion
	   ,CuentaContable
	   ,isnull(IDEmpleado,0) as IDEmpleado
	   ,JefeDivision
	   ,ROW_NUMBER()over(ORDER BY IDDivision)as ROWNUMBER
    FROM RH.tblCatDivisiones
    Where IDDivision = @IDDivision

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatDivisiones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDivision = @IDDivision

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatDivisiones]','[RH].[spBorrarCatDivisiones]','DELETE','',@OldJSON



    BEGIN TRY  
	Delete RH.tblCatDivisiones
	where IDDivision = @IDDivision

	 EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
		 @IDFiltrosUsuarios  = 0  
		 ,@IDUsuario  = @IDUsuario   
		 ,@Filtro = 'Divisiones'  
		 ,@ID = @IDDivision   
		 ,@Descripcion = ''
		 ,@IDUsuarioLogin = @IDUsuario 
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO
