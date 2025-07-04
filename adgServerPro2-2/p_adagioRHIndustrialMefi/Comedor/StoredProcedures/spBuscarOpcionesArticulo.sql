USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spBuscarOpcionesArticulo](
	@IDArticulo int,
	@SoloDisponibles bit = 0
) as
	select
		IDOpcionArticulo	
		,IDArticulo			
		,Nombre				
		,isnull(PrecioExtra,0) as PrecioExtra
		,isnull(Disponible,0) as Disponible			
	from [Comedor].[tblOpcionesArticulo] with (nolock)
	where IDArticulo = @IDArticulo and
		(isnull([Disponible],0) = case when isnull(@SoloDisponibles,0) = 1 then 1 else isnull([Disponible],0) end)
GO
