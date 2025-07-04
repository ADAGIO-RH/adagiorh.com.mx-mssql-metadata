USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [STPS].[spBuscarAgentesCapacitacion_Vue](
	@IDAgenteCapacitacion int = null
	,@PageNumber INT = 1
	,@PageSize INT = 2147483647
	,@query VARCHAR(4000) = '""'
	,@orderByColumn VARCHAR(50) = 'Codigo'
	,@orderDirection VARCHAR(4) = 'asc'
)
as
begin
	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int;

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"' + @query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempAgentesCapacitacion') is not null drop table #tempAgentesCapacitacion;

	SELECT A.IDAgenteCapacitacion,    
		ISNULL(UPPER(A.Codigo),'') as Codigo,    
		ISNULL(A.IDTipoAgente,0) as IDTipoAgente,    
		ISNULL(UPPER(TA.Descripcion),'') as TipoAgente,    
		ISNULL(UPPER(A.Nombre),'') as Nombre,    
		ISNULL(UPPER(A.Apellidos),'') as Apellidos,    
		ISNULL(UPPER(A.RFC),'') as RFC,    
		ISNULL(UPPER(A.RegistroSTPS),'') as RegistroSTPS,    
		ISNULL(UPPER(A.Contacto),'') as Contacto,    
		UPPER(COALESCE(A.RFC,'')+' - '+COALESCE(A.Nombre,'')+' '+COALESCE(A.Apellidos,'')) AS AgenteCapacitacionFull ,    
		ROW_NUMBER()OVER(ORDER BY A.IDAgenteCapacitacion) as ROWNUMBER
	into #tempAgentesCapacitacion
	FROM STPS.tblAgentesCapacitacion A with (nolock)    
		inner join STPS.tblCatTiposAgentes TA with (nolock)   
			on TA.IDTipoAgente = A.IDTipoAgente    
	WHERE ((A.IDAgenteCapacitacion = @IDAgenteCapacitacion) or (isnull(@IDAgenteCapacitacion,0) = 0))
		and (@query = '""' or contains(A.*, @query))
	
	select @TotalPaginas =CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempAgentesCapacitacion

	select @TotalRegistros = count(Codigo) from #tempAgentesCapacitacion

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempAgentesCapacitacion
	order by
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'asc'	then Codigo end,
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
