USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarCatTipoNomina](        
	 @IDCliente int = null        
	,@IDTipoNomina int = null     
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'desc'
	,@IDUsuario int = null   
)        
AS        
BEGIN      
	SET FMTONLY OFF;     
    
	DECLARE @IDIdioma varchar(max)
	 ,@TotalPaginas int = 0
	   ,@TotalRegistros int
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempTiposNomina') IS NOT NULL DROP TABLE #TempTiposNomina    
	IF OBJECT_ID('tempdb..#tempNomina') IS NOT NULL DROP TABLE #tempNomina    
    
	select ID     
	Into #TempTiposNomina    
	from Seguridad.tblFiltrosUsuarios     
	where IDUsuario = @IDUsuario and Filtro = 'TiposNomina'    
 

 
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	Select         
		tp.IDTipoNomina,        
		tp.Descripcion,        
		tp.IDPeriodicidadPago,        
		upper(pp.Descripcion) as PerioricidadPago,        
		isnull(tp.IDPeriodo,0) as IDPeriodo,        
		p.ClavePeriodo,      
		upper(p.Descripcion) as DescripcionPeriodo,        
		ISNULL(C.IDCliente,0) as IDCliente,        
		JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
		ISNULL(Pais.IDPais,0) as IDPais,
		Pais.Descripcion as Pais,
		ISNULL(TP.Asimilados,0) as Asimilados,
        ISNULL(tp.ConfigISRProporcional,0) ConfigISRProporcional,
        tp.IDISRProporcional,
        tp.IDISRProporcionalFiniquito
		into #tempNomina
	from Nomina.tblCatTipoNomina tp   with (nolock)     
		inner join Sat.tblCatPeriodicidadesPago pp with (nolock) on tp.IDPeriodicidadPago = pp.IDPeriodicidadPago 
			and ((tp.IDTipoNomina = @IDTipoNomina)  OR(ISNULL(@IDTipoNomina,0) = 0))
		left join Nomina.tblCatPeriodos p  with (nolock) on tp.IDPeriodo = p.IDPeriodo        
		Inner Join RH.tblCatClientes c   with (nolock) on tp.IDCliente = c.IDCliente
		left join SAT.tblCatPaises Pais with (nolock) on Pais.IDPais = tp.IDPais
	where (tp.IDCliente = @IDCliente) or (ISNULL(@IDCliente,0) = 0)      
		and (tp.IDTipoNomina in  ( select ID from #TempTiposNomina)    
			OR Not Exists(select ID from #TempTiposNomina)) 

	and ( (@query = '""' or contains(tp.*, @query)) OR
			(@query = '""' or contains(pp.*, @query)) OR
			(@query = '""' or contains(C.*, @query)) OR
			(@query = '""' or contains(Pais.*, @query)) 
		) 
	
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempNomina

	select @TotalRegistros = COUNT(IDTipoNomina) from #tempNomina		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempNomina
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,		
		Descripcion asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
