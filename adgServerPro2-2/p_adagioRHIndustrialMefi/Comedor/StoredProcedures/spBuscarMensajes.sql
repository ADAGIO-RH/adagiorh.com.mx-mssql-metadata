USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spBuscarMensajes](@IDUsuario     int
										,@PageNumber	int = 1
										,@PageSize		int = 2147483647
										,@query		varchar(max) = ''
										)
as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	declare @tiposMensajes as table (
		[value] varchar(10),
		[text] varchar(100),
		[icon] varchar(100)
	)

	insert @tiposMensajes([value], [text], [icon])
	exec Comedor.spBuscarTiposMensajes

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempMensajes') is not null drop table #tempMensajes;

	select 
		 m.IDMensaje
		,m.Mensaje
		,m.FechaIni
		,m.FechaFin
		,m.IdsRestaurantes
		,m.IDUsuario
		,isnull(m.FechaHoraCreacion,getdate()) as FechaHoraCreacion
		,m.TipoMensaje
		,tm.icon
	INTO #tempMensajes
	from [Comedor].[tblMensajes] [m] with (nolock)
		join @tiposMensajes tm on tm.[value] = [m].TipoMensaje

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempMensajes

	select @TotalRegistros = COUNT(IDMensaje) from #tempMensajes		
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempMensajes
	order by FechaIni desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
