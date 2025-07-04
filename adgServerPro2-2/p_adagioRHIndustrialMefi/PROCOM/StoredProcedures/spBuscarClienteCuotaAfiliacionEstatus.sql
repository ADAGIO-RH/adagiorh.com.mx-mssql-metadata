USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBuscarClienteCuotaAfiliacionEstatus(
	@IDClienteCuotaAfiliacionEstatus int = 0
	,@IDClienteCuotaAfiliacion  int = 0
	,@IDCliente int = 0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'FechaHora'
    ,@orderDirection varchar(4) = 'desc'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaHora' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		CAE.IDClienteCuotaAfiliacionEstatus
		,CAE.IDClienteCuotaAfiliacion
		,CCA.Anio
		,isnull(CCA.Cuota,0.00) as Cuota
		,CCA.IDCliente
		,C.NombreComercial as Cliente
		,CAE.IDCatEstatusCuotaAfiliacion
		,ECA.Descripcion as EstatusCuotaAfiliacion
		,isnull(ECA.LayoutDescargable,0) as LayoutDescargable
		,CAE.FechaHora
	into #tempResponse
	FROM [Procom].[tblClienteCuotaAfiliacionEstatus] CAE with(nolock)     
		inner join [Procom].[tblClienteCuotaAfiliacion] CCA with(nolock)
			on CAE.IDClienteCuotaAfiliacion = CCA.IDClienteCuotaAfiliacion 
		inner join [RH].[tblCatClientes] C with(nolock)
			on CCA.IDCliente = C.IDCliente	
		inner join [Procom].[tblCatEstatusCuotaAfiliacion] ECA with(nolock)
			on ECA.IDCatEstatusCuotaAfiliacion = CAE.IDCatEstatusCuotaAfiliacion
 	WHERE
		((CAE.IDClienteCuotaAfiliacionEstatus = @IDClienteCuotaAfiliacionEstatus) OR (ISNULL(@IDClienteCuotaAfiliacionEstatus,0) = 0))
		AND ((CCA.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		and ((CAE.IDClienteCuotaAfiliacion = @IDClienteCuotaAfiliacion) OR (ISNULL(@IDClienteCuotaAfiliacion,0) = 0))
		--AND (@query = '""' or contains(CR.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteCuotaAfiliacionEstatus) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'FechaHora'			and @orderDirection = 'asc'		then FechaHora end,			
		case when @orderByColumn = 'FechaHora'			and @orderDirection = 'desc'	then FechaHora end desc,		
		FechaHora desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
