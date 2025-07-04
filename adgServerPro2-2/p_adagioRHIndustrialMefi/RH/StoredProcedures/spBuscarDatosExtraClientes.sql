USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarDatosExtraClientes](
	@IDCliente int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
) AS
BEGIN

	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	 
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
			 IDCatDatoExtraCliente   int   
			,Nombre       varchar(255)
			,Descripcion  varchar(500)    
			,TipoDato varchar(50)
			,IDDatoExtraCliente int 
			,Valor varchar(500)   
			,IDCliente int
		);

	insert @tempResponse
	SELECT
			DE.IDCatDatoExtraCliente
			,DE.Nombre
			,DE.Descripcion
			,DE.TipoDato
			,ISNULL(DEE.IDDatoExtraCliente,0) IDDatoExtraCliente
			,CASE WHEN (DE.TipoDato in ('bool','BIT'))THEN ISNULL(DEE.Valor,'false')
				WHEN (DE.TipoDato in ('string','Varchar'))THEN ISNULL(DEE.Valor,'')
				WHEN (DE.TipoDato in ('Date'))THEN ISNULL(DEE.Valor,'')
				WHEN (DE.TipoDato in ('INT','FLOAT','REAL','DECIMAL', 'NUMERIC'))THEN ISNULL(DEE.Valor,'0')
			 ELSE '0'
			 END as Valor
			,@IDCliente as IDCliente
	FROM RH.tblCatDatosExtraClientes DE
		left join RH.tblDatosExtraClientes DEE on DE.IDCatDatoExtraCliente = DEE.IDCatDatoExtraCliente
	  and  DEE.IDCliente = @IDCliente	
	where (@query = '""' or contains(DE.*, @query)) 
	  order by DE.Nombre asc

	  	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDCatDatoExtraCliente]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		case when @orderByColumn = 'TipoDato'	and @orderDirection = 'asc'		then TipoDato end,		
		case when @orderByColumn = 'TipoDato'	and @orderDirection = 'desc'	then TipoDato end desc,					
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
