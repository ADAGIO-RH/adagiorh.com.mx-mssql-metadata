USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Nomina].[spBuscarTiposPrestamo_Vue](
	@IDTipoPrestamo int = null
    ,@IDUsuario int =null
	,@PageNumber INT = 1
	,@PageSize INT = 2147483647
	,@query VARCHAR(4000) = '""'
	,@orderByColumn VARCHAR(50) = 'Codigo'
	,@orderDirection VARCHAR(4) = 'asc'
	,@SoloTiposConConcepto bit = 0
	,@SoloIntranet bit = 0
)
as
begin
	SET FMTONLY OFF;
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
       , @IDIdioma as VARCHAR(max);

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+ @query + '*"' end

	select
		@orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	if object_id('tempdb..#tempPrestamos') is not null drop table #tempPrestamos;


    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT 
		p.IDTipoPrestamo  
		,p.Codigo  	
        ,UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Descripcion 
		,isnull(p.IDConcepto,0) as IDConcepto  
		,c.Codigo +' - '+ c.Descripcion as DescripcionConcepto  
		,ISNULL(p.Intranet, 0) as Intranet
		,ROW_NUMBER()over(ORDER BY P.IDTipoPrestamo)as ROWNUMBER  
    into #tempPrestamos
	FROM Nomina.tblCatTiposPrestamo p with (nolock)   
		left join Nomina.tblCatConceptos c with (nolock) on p.IDConcepto = c.IDConcepto  
	WHERE ((IDTipoPrestamo = @IDTipoPrestamo) or isnull(@IDTipoPrestamo,0)=0 )
		and (isnull(p.IDConcepto,0) > 0 or @SoloTiposConConcepto = 0)
		and (isnull(p.Intranet,0) = 1 or @SoloIntranet = 0)
		and (@query = '""' or contains(P.*, @query))

	select @TotalPaginas =CEILING(cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempPrestamos

	select @TotalRegistros = count(IDTipoPrestamo) from #tempPrestamos

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempPrestamos
	order by
		case when @orderByColumn = 'Codigo'	and @orderDirection = 'asc'	then Codigo end,
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'	then Descripcion end,
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
