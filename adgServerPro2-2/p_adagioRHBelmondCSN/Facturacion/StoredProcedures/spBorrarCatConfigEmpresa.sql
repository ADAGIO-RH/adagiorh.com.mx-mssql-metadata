USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Facturacion].[spBorrarCatConfigEmpresa]
(
	@IDConfigEmpresa int
)
AS
BEGIN
	Select 
			CE.IDConfigEmpresa
			,isnull(CE.IDEmpresa,0) as IDEmpresa
			,E.NombreComercial as Empresa
			,E.RFC
			,CE.Usuario
			,CE.Password
			,CE.PasswordKey 
			--,CE.CerStringBase64
			--,CE.KeyStringBase64
		
	From Facturacion.tblCatConfigEmpresa CE
		LEFT join RH.tblEmpresa E
			on CE.IDEmpresa = E.IDEmpresa
		
	WHERE (CE.IDConfigEmpresa = @IDConfigEmpresa)
	
	DELETE 	Facturacion.tblCatConfigEmpresa
	WHERE IDConfigEmpresa = @IDConfigEmpresa


END
GO
