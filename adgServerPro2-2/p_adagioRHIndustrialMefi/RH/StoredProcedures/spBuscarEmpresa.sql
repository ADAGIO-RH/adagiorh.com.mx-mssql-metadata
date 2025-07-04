USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarEmpresa](    
	@IDEmpresa int = null    
	,@IDUsuario int = null  
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'RFC'
	,@orderDirection varchar(4) = 'asc'
    ,@ValidarFiltros bit = 1
)    
AS    
BEGIN    
	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when isnull(@orderByColumn,'')	= '' then 'RFC' else @orderByColumn  end 
		,@orderDirection = case when isnull(@orderDirection,'') = '' then  'asc' else @orderDirection end 
    
    

	IF OBJECT_ID('tempdb..#TempEmpresa') IS NOT NULL DROP TABLE #TempEmpresa  
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  

	select ID   
	Into #TempEmpresa  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'RazonesSociales'  
  
	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

	SELECT     
		C.IDEmpresa    
		,C.RFC    
		,C.NombreComercial    
		,C.RegFonacot    
		,C.RegInfonavit    
		,C.RegSIEM    
		,C.RegEstatal    
		,isnull(C.IDCodigoPostal,0) as IDCodigoPostal    
		,CP.CodigoPostal    
		,isnull(C.IDEstado,0) as IDEstado    
		,'['+E.Codigo+'] '+E.NombreEstado as Estado    
		,isnull(C.IDMunicipio,0) as IDMunicipio    
		,'['+M.Codigo+'] '+M.Descripcion as Municipio    
		,isnull(C.IDColonia,0) as IDColonia    
		,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia    
		,isnull(C.IDPais,0) as IDPais    
		,'['+P.Codigo+'] '+P.Descripcion as Pais    
		,C.Calle    
		,C.Exterior    
		,C.Interior    
		,ISNULL(C.IDRegimenFiscal,0) AS IDRegimenFiscal    
		,RF.Descripcion as RegimenFiscal    
		,ISNULL(C.IDOrigenRecurso,0) AS IDOrigenRecurso    
		,OrigenRecurso.Descripcion as OrigenRecurso
		,C.PasswordInfonavit as [PasswordInfonavit]
		,'['+C.RFC+'] - '+ C.NombreComercial as [FullEmpresaDescripcion]
		, C.CURP  
		,ROW_NUMBER()over(ORDER BY C.IDEmpresa )as ROWNUMBER 
	into #tempResponse
	FROM RH.[tblEmpresa] C with(nolock)    
		LEFT join Sat.tblCatCodigosPostales CP  with(nolock) on c.IDCodigoPostal = CP.IDCodigoPostal    
		LEFT join Sat.tblCatPaises P    with(nolock) on c.IDPais = p.IDPais    
		LEFT join Sat.tblCatEstados E   with(nolock) on C.IDEstado = E.IDEstado    
		LEFT join Sat.tblCatMunicipios M   with(nolock) on c.IDMunicipio = m.IDMunicipio    
		LEFT join Sat.tblCatColonias CL    with(nolock) on c.IDColonia = CL.IDColonia    
		Left Join Sat.tblCatRegimenesFiscales RF  with(nolock) on C.IDRegimenFiscal = RF.IDRegimenFiscal    
		Left Join Sat.tblCatOrigenesRecursos OrigenRecurso with(nolock) on OrigenRecurso.IDOrigenRecurso = C.IDOrigenRecurso    
	WHERE (c.IDEmpresa = @IDEmpresa) OR (ISNULL(@IDEmpresa,0) = 0)    
		and ((c.IdEmpresa in  ( select ID from #TempEmpresa)) OR Not Exists(select ID from #TempEmpresa) or @ValidarFiltros=0)  
		and (@query = '""' or contains(c.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT([IDEmpresa]) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'RFC'			and @orderDirection = 'asc'		then RFC end,			
		case when @orderByColumn = 'RFC'			and @orderDirection = 'desc'	then RFC end desc,			
		case when @orderByColumn = 'NombreComercial'and @orderDirection = 'asc'		then NombreComercial end,			
		case when @orderByColumn = 'NombreComercial'and @orderDirection = 'desc'	then NombreComercial end desc,			
		case when @orderByColumn = 'CURP'	and @orderDirection = 'asc'		then CURP end,		
		case when @orderByColumn = 'CURP'	and @orderDirection = 'desc'	then CURP end desc,		
		RFC asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
