USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Salud].[spBuscarSeccionesCuestionarios] --0, 1, 3,1
(
	@IDCuestionario int = 0,
	@IDSeccion int = 0,
	@IDUsuario int
)
AS
BEGIN
	Select 
		IDSeccion
		,IDCuestionario
		,Nombre
		,Descripcion
		,isnull(FechaCreacion,getdate()) as FechaCreacion
	from Salud.tblSecciones with (nolock)
	where ((IDCuestionario = @IDCuestionario) or (@IDCuestionario = 0))
		AND ((IDSeccion = @IDSeccion) or (@IDSeccion = 0))
END
GO
