USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Procom.spBuscarProtocoloIX(
	@IDProtocoloIX int = 0,
	@FechaIni Date = '1900-01-01',
	@FechaFin Date = '9999-12-31',
	@Ejercicio int = 0,
	@IDMes int = 0,
	@IDUsuario int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaIni'
	,@orderDirection varchar(4) = 'desc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@IDIdioma varchar(max)
			--@IDUsuario int = 1
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;


	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaIni' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		 F.IDProtocoloIX    
		,F.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,F.IDClienteModelo
		,E.NombreComercial as Modelo
		,f.IDClienteRazonSocial
		,CRS.RazonSocial
		,F.FechaIni
		,F.FechaFin
		,F.Ejercicio
		,F.IDMes
		,JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Mes

	into #tempResponse
	FROM [Procom].[tblProtocoloIX] F with(nolock) 
		inner join RH.tblcatClientes C with(nolock)
			on F.IDCliente = C.IDCliente
		inner join Procom.tblClienteModelos CM with(nolock)
			on CM.IDCliente = C.IDCliente	
				and CM.IDClienteModelo = F.IDClienteModelo
		inner join RH.tblEmpresa E with(nolock)
			on E.IdEmpresa = CM.IDEmpresa
		inner join Procom.tblClienteRazonSocial CRS with(nolock)
			on CRS.IDCliente = C.IDCliente
				and CRS.IDClienteRazonSocial = F.IDClienteRazonSocial
		inner join Nomina.tblcatMeses M with(nolock)
			on F.IDMes = m.IDMes
	WHERE
       (f.IDProtocoloIX = @IDProtocoloIX or isnull(@IDProtocoloIX,0) =0)
        AND ((f.FechaIni Between @FechaIni and @FechaFin) OR ((f.FechaFin Between @FechaIni and @FechaFin)))
		and ( (@query = '""' or contains(C.*, @query)) 	
			OR (@query = '""' or contains(E.*, @query)) 	
			OR (@query = '""' or contains(CRS.*, @query)) 	
		)
		
	   


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDProtocoloIX) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'FechaIni'			and @orderDirection = 'asc'		then FechaIni end,			
		case when @orderByColumn = 'FechaIni'			and @orderDirection = 'desc'	then FechaIni end desc,		
		FechaIni asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
