USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [App].[spBuscarUnidadesDeTiempo](
	@IDUnidadDeTiempo int = 0
) as
	select 
		IDUnidadDeTiempo
		,Nombre
		,Descripcion
		,TiempoEnSegundos
	from App.[tblCatUnidadesDeTiempo]
	where IDUnidadDeTiempo = @IDUnidadDeTiempo or (@IDUnidadDeTiempo = 0)
GO
