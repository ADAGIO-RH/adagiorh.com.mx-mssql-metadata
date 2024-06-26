USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatCentroCosto]
(
	@CentroCosto Varchar(50) = null
)
AS
BEGIN
	SELECT 
	IDCentroCosto
	,Codigo
	,Descripcion
	,CuentaContable
	FROM RH.[tblCatCentroCosto]
	WHERE (Codigo LIKE @CentroCosto+'%') OR(Descripcion LIKE @CentroCosto+'%') OR (@CentroCosto IS NULL)
	ORDER BY Descripcion ASC
END
GO
