USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spBuscarClienteSucursal](
	@IDClienteSucursal int = 0
	,@IDCliente int = 0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Codigo'
    ,@orderDirection varchar(4) = 'asc'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		CR.IDClienteSucursal
		,CR.IDCliente
		,C.NombreComercial as Cliente
		,CR.Codigo
	    ,CR.Descripcion
		,ISNULL(CR.IDCodigoPostal,0) as IDCodigoPostal
		,isnull(CR.CodigoPostal,cp.CodigoPostal) as CodigoPostal
		,ISNULL(CR.IDEstado,0) as IDEstado
		,isnull(CR.Estado,est.NombreEstado) as Estado
		,ISNULL(CR.IDMunicipio,0) as IDMunicipio
		,isnull(CR.Municipio,muni.Descripcion) as Municipio
		,ISNULL(L.IDLocalidad,0) as IDLocalidad
		,ISNULL(CR.Localidad,L.Descripcion) as Localidad
		,ISNULL(CR.IDColonia,0) as IDColonia
		,isnull(CR.Colonia,col.NombreAsentamiento) as Colonia
		,ISNULL(CR.IDPais,0) as IDPais
		,isnull(CR.Pais,pais.Descripcion) as Pais
		,CR.Calle
		,CR.Exterior 
		,CR.Interior 
	into #tempResponse
	FROM [Procom].[tblClienteSucursal] CR with(nolock)     
		inner join [RH].[tblCatClientes] C with(nolock)
			on CR.IDCliente = C.IDCliente
		LEFT JOIN sat.tblCatCodigosPostales cp with(nolock)
			on cp.IDCodigoPostal = CR.IDCodigoPostal
		left join Sat.tblCatEstados est with(nolock)
			on est.IDEstado = cr.IDEstado
		left join Sat.tblCatMunicipios muni with(nolock)
			on muni.IDMunicipio = cr.IDMunicipio
		left join sat.tblCatColonias col with(nolock)
			on col.IDColonia = cr.IDColonia
		left join sat.tblCatPaises pais with(nolock)
			on pais.IDPais = cr.IDPais
		left join Sat.tblCatLocalidades L
			on cp.IDLocalidad = L.IDLocalidad
 	WHERE
		((CR.IDClienteSucursal = @IDClienteSucursal) OR (ISNULL(@IDClienteSucursal,0) = 0))
		AND ((CR.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		AND (@query = '""' or contains(CR.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteSucursal) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,		
		Codigo ASC

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END;
GO
