USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBuscarClienteHonorariosComisionistas(
	@IDClienteHonorarioComisionista int = 0
	,@IDClienteHonorario int = 0
	,@IDCliente int = 0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Comisionista'
	,@orderDirection varchar(4) = 'asc'
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

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Comisionista' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		 CHC.IDClienteHonorarioComisionista
		,CHC.IDClienteHonorario
		,CHC.IDCatComisionista
		,CC.Identificador +' - '+CC.NombreCompleto as Comisionista
		,isnull(CHC.Porcentaje,0.00) as Porcentaje
		,C.IDCliente
		,C.NombreComercial as Cliente
		
	into #tempResponse
	FROM [Procom].[TblClienteHonorariosComisionistas] CHC with(nolock)     
		INNER JOIN [Nomina].[TblCatComisionistas] CC with(nolock)
			on CC.IDCatComisionista = CHC.IDCatComisionista
		inner join [Procom].[TblClienteHonorarios] CH with(nolock)
			on CHC.IDClienteHonorario = CH.IDClienteHonorario
		inner join [RH].[tblCatClientes] C with(nolock)
			on CH.IDCliente = C.IDCliente
 	WHERE
		((CH.IDClienteHonorario = @IDClienteHonorario) OR (ISNULL(@IDClienteHonorario,0) = 0))
		AND ((CHC.IDClienteHonorarioComisionista = @IDClienteHonorario) OR (ISNULL(@IDClienteHonorarioComisionista,0) = 0))
		AND ((C.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		AND (@query = '""' or contains(C.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteHonorario) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Comisionista'			and @orderDirection = 'asc'		then Cliente end,			
		case when @orderByColumn = 'Comisionista'			and @orderDirection = 'desc'	then Cliente end desc,		
		Comisionista desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO
