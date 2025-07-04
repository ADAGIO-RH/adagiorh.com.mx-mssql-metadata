USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spBuscarMiembrosComisionMixta] (
	 @IDMiembroComisionMixta int = 0
	,@IDClienteComisionMixta int =0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'NombreCompleto'
    ,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN 
		SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'NombreCompleto' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	SELECT     
		MCM.IDMiembroComisionMixta
		,isnull(TMCM.IDCatTipoMiembroComisionMixta,0) as IDCatTipoMiembroComisionMixta
		,TMCM.Descripcion as TipoMiembroComisionMixta
		,MCM.NombreCompleto
		,MCM.Puesto
		,MCM.FechaIngreso
		,MCM.IMSS
		,MCM.FechaIMSS as FechaIMSS
		,isnull(MCM.IDClienteComisionMixta,0) as IDClienteComisionMixta
		,CCM.Nombre as ComisionMixta
	into #tempResponse
	FROM [Procom].[tblMiembrosComisionMixta] MCM with(nolock)     
		inner join [Procom].[tblClienteComisionMixta] CCM with(nolock)
			on MCM.IDClienteComisionMixta = CCM.IDClienteComisionMixta
		inner join [Procom].[TblCatTipoMiembroComisionMixta] TMCM with(nolock)
			on TMCM.IDCatTipoMiembroComisionMixta = MCM.IDCatTipoMiembroComisionMixta
 	WHERE
		((MCM.IDMiembroComisionMixta = @IDMiembroComisionMixta) OR (ISNULL(@IDMiembroComisionMixta,0) = 0))
		AND ((MCM.IDClienteComisionMixta = @IDClienteComisionMixta) OR (ISNULL(@IDClienteComisionMixta,0) = 0))
		AND
		(@query = '""' or contains(MCM.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDMiembroComisionMixta) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'NombreCompleto'			and @orderDirection = 'asc'		then NombreCompleto end,			
		case when @orderByColumn = 'NombreCompleto'			and @orderDirection = 'desc'	then NombreCompleto end desc,		
		NombreCompleto ASC

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END;
GO
