USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spBuscarCatTiposArticulosConArticulosParaVentaIndividual](
		@IDRestaurante	int,
		@IDUsuario		int
	)
as
	
	select distinct
		[cta].IDTipoArticulo
		,[cta].Nombre
		,[cta].Descripcion
		,[cta].Disponible
		,[cta].FechaHora
	from [Comedor].[tblCatArticulos] [A] with(nolock)
		join [Comedor].[tblCatTiposArticulos] [cta] with(nolock) on [cta].[IDTipoArticulo] = [A].[IDTipoArticulo] 
			and isnull([cta].[Disponible],0) = 1
	where isnull(a.VentaIndividual,0) = 1 
		and (@IDRestaurante in (select cast(item as int) from App.Split([A].IdsRestaurantes, ',')))
		and (cast(getdate() as time) between [A].[HoraDisponibilidadInicio] and [A].[HoraDisponibilidadFin])
		and isnull([A].[Disponible],0) = 1
	order by cta.Nombre asc
GO
