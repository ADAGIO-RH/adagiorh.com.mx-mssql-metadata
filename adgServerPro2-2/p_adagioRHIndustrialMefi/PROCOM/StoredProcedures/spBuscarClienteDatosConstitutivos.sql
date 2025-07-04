USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spBuscarClienteDatosConstitutivos](
	 @IDClienteDatosConstitutivos int = 0
	,@IDCliente int = 0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Vigente'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Vigente' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		 CR.IDClienteDatosConstitutivos
		,ISNULL(CR.IDCliente,0) as IDCliente
		,C.NombreComercial as Cliente
		,CR.RazonSocial
		,CR.NumeroEscritura
		,CR.FolioMercantil
		,CR.FechaEscritura
		,ISNULL(CR.IDCatTipoPoder,0) as IDCatTipoPoder
		,TP.Descripcion as TipoPoder
		,ISNULL(CR.IDCatTipoEscritura,0) as IDCatTipoEscritura
		,TE.Descripcion as TipoEscritura
		,ISNULL(CR.IDCatTipoFederativo,0) as IDCatTipoFederativo
		,TF.Descripcion as TipoFederativo
		,CR.RepresentantePaterno
		,CR.RepresentanteMaterno
		,CR.RepresentanteNombre
		,CR.RepresentanteRFC
		,CR.RepresentanteCURP
		,CR.NotarioPaterno
		,CR.NotarioMaterno
		,CR.NotarioNombre
		,ISNULL(CR.IDEstado,0) as IDEstado
		,ES.NombreEstado as Estado
		,ISNULL(CR.IDMunicipio,0) as IDMunicipio
		,Muni.Descripcion as Municipio
		,CR.LugarEscrituracion
		,CR.NumeroNotario
		,isnull(CR.Vigente,0) as Vigente
	   
	into #tempResponse
	FROM [Procom].[tblClienteDatosConstitutivos] CR with(nolock)     
		inner join [RH].[tblCatClientes] C with(nolock)
			on CR.IDCliente = C.IDCliente
		left join Procom.TblCatTipoPoder TP with(nolock)
			on TP.IDCatTipoPoder = CR.IDCatTipoPoder
		left join Procom.tblCatTipoEscritura TE with(nolock)
			on TE.IDCatTipoEscritura = CR.IDCatTipoEscritura
		left join Procom.tblCatTipoFederativo TF with(nolock)
			on TF.IDCatTipoFederativo = CR.IDCatTipoPoder
		left join Sat.tblCatEstados ES with(nolock)
			on ES.IDEstado = CR.IDEstado
		left join SAT.tblCatMunicipios Muni with(nolock)
			on muni.IDMunicipio = CR.IDMunicipio
 	WHERE
		((CR.IDClienteDatosConstitutivos = @IDClienteDatosConstitutivos) OR (ISNULL(@IDClienteDatosConstitutivos,0) = 0))
		AND ((CR.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		AND (@query = '""' or contains(CR.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteDatosConstitutivos) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Vigente'			and @orderDirection = 'asc'		then Vigente end,			
		case when @orderByColumn = 'Vigente'			and @orderDirection = 'desc'	then Vigente end desc,		
		Vigente desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END;
GO
