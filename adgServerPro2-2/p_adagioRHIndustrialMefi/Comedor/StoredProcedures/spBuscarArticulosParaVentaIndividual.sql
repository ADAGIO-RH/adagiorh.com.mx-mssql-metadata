USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spBuscarArticulosParaVentaIndividual](
		@IDRestaurante	int = 0,
		@IDArticulo	int = 0,
		@IDTipoArticulo int = 0,
		@IDUsuario		int,
		@PageNumber	int = 1,
		@PageSize	int = 2147483647
	)
as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempCatArticulos') is not null drop table #tempCatArticulos;

	select 
		[A].[IDArticulo]
		,[A].[IDTipoArticulo]
		,[Cta].[Nombre] as [TipoArticulo]
		,[A].[Nombre]
		,[A].[Descripcion]
		,isnull([A].[PrecioCosto],0.00) as                 [PrecioCosto]
		,isnull([A].[PrecioEmpleado],0.00) as              [PrecioEmpleado]
		,isnull([A].[PrecioPublico],0.00) as               [PrecioPublico]
		,isnull([A].[HoraDisponibilidadInicio],'00:00') as [HoraDisponibilidadInicio]
		,isnull([A].[HoraDisponibilidadFin],'00:00') as    [HoraDisponibilidadFin]
		,isnull([A].[VentaIndividual],0) as                [VentaIndividual]
		,isnull([A].[Disponible],0) as                     [Disponible]
		,isnull([A].[ArticuloPedido],0) as                 [ArticuloPedido]
		,isnull([A].[IDArticuloOriginal],0)                [IDArticuloOriginal]
		,isnull([A].[FechaHora],getdate()) as              [FechaHora]
		,isnull([A].[IDCategoria], 0) as [IDCategoria]
		,isnull([cc].Nombre, '[SIN CATEGORÍA]') as Categoria
		,OpcionesArticulo = (
			select 
				op.IDOpcionArticulo	
				,op.IDArticulo			
				,op.Nombre				
				,isnull(op.PrecioExtra,0) as PrecioExtra
				,isnull(op.Disponible,0) as Disponible		
			from Comedor.tblOpcionesArticulo op
			where op.IDArticulo = [A].IDArticulo AND isnull(op.[Disponible],0) = 1
			for json auto 
		)
	INTO #tempCatArticulos
	from [Comedor].[tblCatArticulos] [A] with(nolock)
		join [Comedor].[tblCatTiposArticulos] [cta] with(nolock) on [cta].[IDTipoArticulo] = [A].[IDTipoArticulo] 
			and isnull([cta].[Disponible],0) = 1
			and ([cta].[IDTipoArticulo] = isnull(@IDTipoArticulo,0) or isnull(@IDTipoArticulo,0) = 0)
		left join [Comedor].[tblCatCategorias] [cc] with(nolock) on [cc].[IDCategoria] = [A].[IDCategoria]
	where isnull(a.VentaIndividual,0) = 1 
		and (A.IDArticulo = @IDArticulo or isnull(@IDArticulo, 0) = 0)
		and (@IDRestaurante in (select cast(item as int) from App.Split([A].IdsRestaurantes, ',')) or isnull(@IDRestaurante, 0) = 0)
		and (cast(getdate() as time) between [A].[HoraDisponibilidadInicio] and [A].[HoraDisponibilidadFin])
		and isnull([A].[Disponible],0) = 1

	select @TotalPaginas = CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempCatArticulos

	select @TotalRegistros = cast(COUNT([IDArticulo]) as decimal(18,2)) from #tempCatArticulos		
	
	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempCatArticulos
		order by [TipoArticulo] asc, Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
