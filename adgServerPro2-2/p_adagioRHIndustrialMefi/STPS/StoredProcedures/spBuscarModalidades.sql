USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarModalidades]
(
	@IDModalidad int = null
)
AS
BEGIN

		select 
		IDModalidad
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatModalidades]
		where IDModalidad = @IDModalidad or @IDModalidad is null
END
GO
