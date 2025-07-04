USE [p_adagioRHIndustrialMefi]
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

		select @OldJSON = (SELECT IDDivision
                                ,Codigo
                                ,CuentaContable
                                ,JefeDivision
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatDivisiones]
                            WHERE IDDivision = @IDDivision FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


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
