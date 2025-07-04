USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE PROCOM.spBuscarClienteContacto(
	 @IDClienteContacto int = 0
	,@IDCliente int = 0
	,@IDCatTipoContacto int = 0
	,@IDUsuario int = null  
	,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'IDCatTipoContacto'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'IDCatTipoContacto' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


	SELECT     
		CC.IDClienteContacto
		,CC.IDCliente
		,C.NombreComercial as Cliente
		,isnull(CC.IDCatTipoContacto,0) as IDCatTipoContacto
		,CTC.Descripcion as TipoContacto
		,CC.Valor
	
	into #tempResponse
	FROM [Procom].[tblClienteContacto] CC with(nolock)    
		inner join RH.tblcatClientes C with(nolock)
			on CC.IDCliente = c.IDCliente
		inner join [PROCOM].[TblCatTipoContacto] CTC with(nolock)
			on CTC.IDCatTipoContacto = CC.IDCatTipoContacto
		
 	WHERE
		((CC.IDCatTipoContacto = @IDCatTipoContacto) OR (ISNULL(@IDCatTipoContacto,0) = 0))
		and((CC.IDCliente = @IDCliente) OR (ISNULL(@IDCliente,0) = 0))
		and((CC.IDClienteContacto = @IDClienteContacto) OR (ISNULL(@IDClienteContacto,0) = 0))
		AND (@query = '""' or contains(CC.*, @query))   

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDClienteContacto) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'IDCatTipoContacto'			and @orderDirection = 'asc'		then IDCatTipoContacto end,			
		case when @orderByColumn = 'IDCatTipoContacto'			and @orderDirection = 'desc'	then IDCatTipoContacto end desc,		
		IDCatTipoContacto ASC

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END;
GO
