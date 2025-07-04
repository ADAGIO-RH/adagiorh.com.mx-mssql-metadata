USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Resguardo].[spBuscarCatTiposArticulos](
	@IDTipoArticulo int = 0
	,@IDUsuario int
) as
	select 
		IDTipoArticulo
		,Nombre 
		,Descripcion 
	from [Resguardo].[tblCatTiposArticulos] with (nolock)
	where IDTipoArticulo = @IDTipoArticulo or @IDTipoArticulo = 0
GO
