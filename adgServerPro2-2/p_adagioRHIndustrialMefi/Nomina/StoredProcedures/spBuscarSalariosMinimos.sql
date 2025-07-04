USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBuscarSalariosMinimos]
(
    @IDSalarioMinimo int = 0
	,@IDUsuario int
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Fecha'
    ,@orderDirection varchar(4) = 'asc'
) as
begin

	SET FMTONLY OFF;

    declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

				
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	IF OBJECT_ID('tempdb..#TempSalariosMinimos') IS NOT NULL DROP TABLE #TempSalariosMinimos;

	select 
		SM.IDSalarioMinimo
		,SM.Fecha
		,isnull(SM.SalarioMinimo, 0) as SalarioMinimo
		,isnull(SM.SalarioMinimoFronterizo, 0) as SalarioMinimoFronterizo
		,isnull(SM.UMA, 0) as UMA
		,isnull(SM.FactorDescuento,0) as FactorDescuento
		,ISNULL(p.IDPais,0) as IDPais
		,P.Descripcion as Pais
		,ISNULL(SM.AjustarUMI,0) AjustarUMI
		,CASE WHEN ISNULL(SM.AjustarUMI,0) = 0 THEN 'NO' ELSE 'SI' END AjustarUMISTR 
		,ISNULL(SM.TopeMensualSubsidioSalario,0.00) as TopeMensualSubsidioSalario
		,isnull(SM.PorcentajeUMASubsidio,0.00) as PorcentajeUMASubsidio
	into #TempSalariosMinimos
    from [Nomina].[tblSalariosMinimos] SM with(Nolock)
		left join SAT.tblCatPaises P on SM.IDPais = P.IDPais
    where (SM.IDSalarioMinimo = @IDSalarioMinimo or ISNULL(@IDSalarioMinimo,0) = 0)
		and (@query = '""' or contains(p.*, @query)) 
    order by SM.fecha desc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempSalariosMinimos

	select @TotalRegistros = cast(COUNT(IDSalarioMinimo) as int) from #TempSalariosMinimos		

	select *
		,TotalPages = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,TotalRows=@TotalRegistros
	from #TempSalariosMinimos
	order by 
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'asc'		then Fecha end,			
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'desc'	then Fecha end desc,					
		Fecha asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

end
GO
