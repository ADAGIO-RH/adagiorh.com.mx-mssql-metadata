USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatPuestos](    
	@IDPuesto int = null  
	,@IDUsuario int = null     
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
    ,@ValidarFiltros bit =1
)    
AS    
BEGIN    
	SET FMTONLY OFF;  

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int, 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

	if OBJECT_ID('tempdb..#TempPuestosFiltros') is not null drop table #TempPuestosFiltros;
	IF OBJECT_ID('tempdb..#TempPuestos') IS NOT NULL DROP TABLE #TempPuestos  
  
	select ID   
	into #TempPuestosFiltros  
	from Seguridad.tblFiltrosUsuarios with (nolock)   
	where IDUsuario = @IDUsuario and Filtro = 'Puestos'  
  
	SELECT     
		p.IDPuesto    
		,p.Codigo    
		,JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
		,p.DescripcionPuesto  
		,isnull(p.TopeSalarial,0.00) as TopeSalarial
		,isnull(p.SueldoBase,0.00) as SueldoBase    
		,isnull(p.IDOcupacion,0) as IDOcupacion    
		,'['+o.Codigo+'] - '+o.Descripcion as Ocupacion 
		,p.Traduccion
        ,p.NivelSalarialCompensaciones
		,ROW_NUMBER()OVER(ORDER BY p.IDPuesto ASC)  AS ROWNUMBER   
	into #TempPuestos
	FROM [RH].[tblCatPuestos] p with (nolock)    
		left join STPS.tblCatOcupaciones O with (nolock) on P.IDOcupacion = o.IDOcupaciones    
	WHERE (P.IDPuesto = @IDPuesto or isnull(@IDPuesto,0) = 0)    
		and (
			IDPuesto in  (select ID from #TempPuestosFiltros) or not exists(select ID from #TempPuestosFiltros)
            OR @ValidarFiltros=0
		)  
		and (@query = '""' or contains(p.*, @query)) 



	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempPuestos

	select @TotalRegistros = cast(COUNT([IDPuesto]) as decimal(18,2)) from #TempPuestos		
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempPuestos
	order by 	
	case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,		
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
