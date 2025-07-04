USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [PROCOM].[spBuscarFacturaPeriodo](
	@IDFacturaPeriodo int = 0
	,@IDFactura int = 0
	,@IDPeriodo int = 0
	,@IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaInicioPago'
	,@orderDirection varchar(4) = 'desc'
)
AS
BEGIN
SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;


	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaInicioPago' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		 FP.IDFacturaPeriodo    
		 ,FP.IDFactura    
		,F.Fecha 
		,F.Folio
		,F.RFC
		,F.RazonSocial
		,F.Total
		,FP.IDPeriodo    
		,isnull(P.Ejercicio,0) as Ejercicio
		,P.ClavePeriodo
		,P.Descripcion as Periodo
		,isnull(p.FechaInicioPago,'9999-12-31') as FechaInicioPago
		,isnull(p.FechaFinPago,'9999-12-31') as FechaFinPago
		,[Procom].[fnTotalPeriodo](FP.IDPeriodo) as TotalPeriodo
		,isnull(p.IDTipoNomina,0) as IDTipoNomina
		,TN.Descripcion as TipoNomina
		,isnull(TN.IDCliente,0) as IDCliente
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
	into #tempResponse
	FROM [Procom].tblFacturasPeriodos FP with(nolock)
		left join [Procom].[TblFacturas] F with(nolock)    on F.IDFactura = FP.IDFactura
		Left join [Nomina].[TblCatPeriodos] p with(nolock) on FP.IDPeriodo = p.IDPeriodo
		left join [Nomina].[TblCatTipoNomina] TN with(nolock) on p.IDTipoNomina = TN.IDTipoNomina
		left join [RH].[TblCatClientes] C with(nolock) on c.IDCliente = TN.IDCliente
	WHERE
       (FP.IDFactura = @IDFactura or isnull(@IDFactura,0) =0)
		AND (FP.IDPeriodo = @IDPeriodo  or isnull(@IDPeriodo,0) = 0)
		and (@query = '""' or contains(F.*, @query)) 
		and (@query = '""' or contains(P.*, @query)) 
	


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDFactura) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'FechaInicioPago'			and @orderDirection = 'asc'		then FechaInicioPago end,			
		case when @orderByColumn = 'FechaInicioPago'			and @orderDirection = 'desc'	then FechaInicioPago end desc,		
		FechaInicioPago asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
