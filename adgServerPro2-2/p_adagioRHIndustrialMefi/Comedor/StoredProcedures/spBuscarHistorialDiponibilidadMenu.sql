USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Comedor.spBuscarHistorialDiponibilidadMenu(
	@IDHistorialDisponibilidadMenu int = 0,
	@IDMenu int,
	@IDUsuario int,
	@PageNumber	int = 1,
	@PageSize		int = 2147483647,
	@query			varchar(100) = '""',
	@orderByColumn	varchar(50) = 'FechaInicio',
	@orderDirection varchar(4) = 'desc'
) as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int, 
		@IDIdioma varchar(20)
	;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaInicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

	IF OBJECT_ID('tempdb..#TempHistorial') IS NOT NULL DROP TABLE #TempHistorial
  

	select 
		IDHistorialDisponibilidadMenu
		,IDMenu
		,FechaInicio
		,FechaFin
		,HoraInicio
		,HoraFin
		,OpcionesArticulosDisponbibles
		,isnull(Activo, 0) as Activo
	INTO #TempHistorial
	from Comedor.tblHistorialDisponibilidadMenu
	where (IDHistorialDisponibilidadMenu = @IDHistorialDisponibilidadMenu or isnull(@IDHistorialDisponibilidadMenu, 0) = 0)
		and (IDMenu = @IDMenu or isnull(@IDMenu, 0) = 0)
	--order by FechaFin desc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempHistorial

	select @TotalRegistros = cast(COUNT(IDHistorialDisponibilidadMenu) as decimal(18,2)) from #TempHistorial		
	
	select
		 hd.IDHistorialDisponibilidadMenu
		,hd.IDMenu
		,hd.FechaInicio
		,hd.FechaFin
		,hd.HoraInicio
		,hd.HoraFin
		,hd.Activo
		,OpcionesArticulosDisponbibles = 
			case when coalesce(OpcionesArticulosDisponbibles, '') = '' then 
				(
					select 
						a.IDArticulo,
						a.Nombre as Articulo,	
						(
							select 
								op.IDArticulo,
								op.IDOpcionArticulo,
								op.Nombre,
								isnull(op.Disponible, 0) as [Enabled],
								isnull(op.Disponible, 0) as Disponible
							from Comedor.tblOpcionesArticulo op
							where op.IDArticulo = dm.IDArticulo
							for json auto
						) as Opciones
					from Comedor.tblDetalleMenu dm
						join Comedor.tblCatArticulos a on a.IDArticulo = dm.IDArticulo
					where dm.IDMenu = hd.IDMenu
					for json auto
				)
			else (
				select 
					a.IDArticulo,
					a.Nombre as Articulo,	
					(
						select 
							op.IDArticulo,
							op.IDOpcionArticulo,
							op.Nombre,
							op.Disponible as [Enabled],
							case when op.Disponible = 0 then cast(0 as bit) 
							else
								isnull(cOpciones.Disponible, op.Disponible) 
							end as Disponible
						from Comedor.tblOpcionesArticulo op
							left join OPENJSON(hd.OpcionesArticulosDisponbibles, '$') 
								with (
									IDOpcionArticulo int,
									IDArticulo int,
									Disponible bit
								) cOpciones on cOpciones.IDOpcionArticulo = op.IDOpcionArticulo and cOpciones.IDArticulo = dm.IDArticulo
						where op.IDArticulo = dm.IDArticulo
						for json auto
					) as Opciones
				from Comedor.tblDetalleMenu dm
					join Comedor.tblCatArticulos a on a.IDArticulo = dm.IDArticulo
				where dm.IDMenu = hd.IDMenu
				for json auto
			) end
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempHistorial hd
	order by 	
		case when @orderByColumn = 'FechaInicio'	and @orderDirection = 'asc'		then FechaInicio end,			
		case when @orderByColumn = 'FechaInicio'	and @orderDirection = 'desc'	then FechaInicio end desc,		
		FechaInicio asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
