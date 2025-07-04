USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatTiposPrestaciones](  
	@IDTipoPrestacion int = 0 
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
declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
          ,@IDIdioma varchar(max)
	;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
		            else '"'+@query + '*"' end
	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


	IF OBJECT_ID('tempdb..#TempTiposPrestaciones') IS NOT NULL DROP TABLE #TempTiposPrestaciones
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	select ID 
	Into #TempTiposPrestaciones
	from Seguridad.tblFiltrosUsuarios 
	where IDUsuario = @IDUsuario and Filtro = 'Prestaciones'

	SELECT   
		IDTipoPrestacion  
		,Codigo  
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))+' '+case when isnull(tp.Sindical,0) = 1 then '(SINDICAL)' else '(CONFIANZA)' end as FacIntegracion  
		,UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as _Descripcion
		,ConfianzaSindical  
		,Factor = isnull((Select top 1 Factor from [RH].[tblCatTiposPrestacionesDetalle] where IDTipoPrestacion = tp.IDTipoPrestacion order by Antiguedad asc),0)  
		,isnull(tp.PorcentajeFondoAhorro,0) as PorcentajeFondoAhorro  
		,tp.IDsConceptosFondoAhorro  
		,ConceptosFondoAhorro = ISNULL( STUFF(  
			(   SELECT ', ['+ cast(Codigo as varchar(10))+'] '+ CONVERT(NVARCHAR(100), Descripcion)   
			FROM Nomina.tblCatConceptos  
			WHERE IDConcepto in (select cast(rtrim(ltrim(item)) as int) from app.Split(tp.IDsConceptosFondoAhorro,','))  
			ORDER BY OrdenCalculo  asc  
			FOR xml path('')  
			)  
			, 1  
			, 1  
			, ''), 'Conceptos no definidos')  
		,isnull(tp.ToparFondoAhorro,0) as ToparFondoAhorro  
		,isnull(tp.Sindical,0) as Sindical  
		,ROW_NUMBER()over(ORDER BY IDTipoPrestacion)as ROWNUMBER   
        ,Traduccion
		into #TempResponse
	FROM [RH].[tblCatTiposPrestaciones] tp  
	WHERE (IDTipoPrestacion = @IDTipoPrestacion or isnull(@IDTipoPrestacion,0) = 0)  
		and (IDTipoPrestacion in  ( select ID from #TempTiposPrestaciones)
		OR Not Exists(select ID from #TempTiposPrestaciones) or @ValidarFiltros=0)
			and (@query = '""' or contains(tp.*, @query)) 
	ORDER BY Descripcion ASC  

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempResponse

	select @TotalRegistros = COUNT(IDTipoPrestacion) from #TempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
