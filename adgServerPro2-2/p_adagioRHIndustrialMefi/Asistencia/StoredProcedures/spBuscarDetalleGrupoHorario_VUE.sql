USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Asistencia].[spBuscarDetalleGrupoHorario_VUE](
    @IDGrupoHorario int =  null
    ,@IDUsuario int
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
)as
begin
    SET FMTONLY OFF;  
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
        if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else @query  end

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	-- IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	-- select ID   
	-- Into #TempFiltros  
	-- from Seguridad.tblFiltrosUsuarios  with(nolock) 
	-- where IDUsuario = @IDUsuario and Filtro = 'DetalleGrupoHorario'  

    select dgh.IDDetalleGrupoHorario
		,dgh.IDGrupoHorario
		,dgh.IDHorario
		,ch.IDTurno
		,ct.Descripcion as Turno
		,ch.Codigo as CodigoHorario
		,ch.Descripcion as DescripcionHorario
        into #TempResponse
    from [Asistencia].[tblDetalleGrupoHorario] dgh
	   join [Asistencia].[tblCatHorarios] ch on dgh.IDHorario = ch.IDHorario
	   join [Asistencia].[tblCatTurnos] ct on ch.IDTurno = ct.IDTurno
    where (dgh.IDGrupoHorario = @IDGrupoHorario or isnull (@IDGrupoHorario,0)=0)
	ORDER BY dgh.IDDetalleGrupoHorario ASC

		select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDDetalleGrupoHorario) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'DescripcionHorario'			and @orderDirection = 'asc'		then DescripcionHorario end,			
		case when @orderByColumn = 'DescripcionHorario'			and @orderDirection = 'desc'	then DescripcionHorario end desc,
		DescripcionHorario asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

end
GO
