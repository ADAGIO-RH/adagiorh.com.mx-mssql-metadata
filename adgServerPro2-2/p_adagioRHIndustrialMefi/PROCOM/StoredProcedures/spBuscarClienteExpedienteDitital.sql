USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spBuscarClienteExpedienteDitital](
	@IDClienteExpedienteDigital int = 0
	,@IDCliente int
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'Nombre'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	SELECT     
		 [EXP].IDClienteExpedienteDigital
		,[EXP].IDCliente
		,C.NombreComercial as Cliente
		,[EXP].Nombre
		,[EXP].[Name]
		,[EXP].ContentType
		,[EXP].PathFile
		,[EXP].Size
		
	into #tempResponse
	FROM [Procom].tblClienteExpedienteDigital [EXP] with(nolock)     
		inner join RH.tblCatClientes C with(nolock)
			on [EXP].IDCliente = c.IDCliente
 	WHERE
		(([EXP].IDClienteExpedienteDigital = @IDClienteExpedienteDigital) OR (ISNULL(@IDClienteExpedienteDigital,0) = 0))
		AND (([EXP].IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		AND
		(@query = '""' or contains([EXP].*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteExpedienteDigital) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,		
		Nombre ASC

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
