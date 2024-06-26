USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarCatPerfiles]
(
	@IDPerfil int = 0
	
)
AS
BEGIN
	Select 
		IDPerfil
		,Descripcion
		,Activo 
		,ROW_NUMBER()over(ORDER BY IDPerfil) as ROWNUMBER
	From Seguridad.tblCatPerfiles
	Where (IDPerfil = @IDPerfil) or (@IDPerfil = 0)
END
GO
