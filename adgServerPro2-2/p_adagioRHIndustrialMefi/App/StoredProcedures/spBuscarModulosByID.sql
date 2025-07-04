USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spBuscarModulosByID]
(
	@IDModulo int = 0
)
AS
BEGIN
	Select M.IDArea,A.Descripcion as Area,M.IDModulo,M.Descripcion as Modulo
	from App.tblCatModulos M
		Inner join App.tblCatAreas A
			on M.IDArea = A.IDArea
	Where (M.IDModulo = @IDModulo) OR (@IDModulo = 0)
END
GO
