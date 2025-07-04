USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Nomina].[spBuscarControlCalculoVariablesBimestrales](
	 @IDControlCalculoVariables int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Ejercicio'
	,@orderDirection varchar(4) = 'desc'
	,@IDUsuario		int = null    
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Ejercicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		 d.IDControlCalculoVariables    
		,d.Ejercicio    
		,d.IDRegPatronal
		,rp.RegistroPatronal
		,rp.RazonSocial
		,d.IDBimestre
		,b.Descripcion as Bimestre
		,b.Meses
        ,d.Aplicar
        ,d.IDUsuario
        ,Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(0,d.IDUsuario) as UsuarioEmpleadoFotoAvatar
	into #tempResponse
	FROM [Nomina].[tblControlCalculoVariablesBimestrales] d with(nolock)   
		inner join [RH].[tblCatRegPatronal] rp with(nolock)
			on rp.IDRegPatronal = d.IDRegPatronal
		inner join [Nomina].[tblCatBimestres] b with(nolock)
			on d.IDBimestre = b.IDBimestre
	WHERE
		(@query = '""' or contains(rp.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDControlCalculoVariables) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Ejercicio'			and @orderDirection = 'asc'		then Ejercicio end,			
		case when @orderByColumn = 'Ejercicio'			and @orderDirection = 'desc'	then Ejercicio end desc,	
		case when @orderByColumn = 'RegistroPatronal'			and @orderDirection = 'asc'		then RegistroPatronal end,			
		case when @orderByColumn = 'RegistroPatronal'			and @orderDirection = 'desc'	then RegistroPatronal end desc,
		case when @orderByColumn = 'RazonSocial'			and @orderDirection = 'asc'		then RazonSocial end,			
		case when @orderByColumn = 'RazonSocial'			and @orderDirection = 'desc'	then RazonSocial end desc,
		case when @orderByColumn = 'Bimestre'			and @orderDirection = 'asc'		then Bimestre end,			
		case when @orderByColumn = 'Bimestre'			and @orderDirection = 'desc'	then Bimestre end desc,
		Ejercicio desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
