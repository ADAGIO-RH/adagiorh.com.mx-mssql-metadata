USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca matriz de control de acceso
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-08-01
** Paremetros		:              

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarMatrizControlAcceso]    
(    
    @IDMatrizControlAcceso int =null
    ,@Nombre Varchar(max) = null      
    ,@Estatus bit = null
    ,@IDUsuario int = null    
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = ''
    ,@orderByColumn	varchar(50) = 'Nombre'
    ,@orderDirection varchar(4) = 'asc'     
)    
AS    
BEGIN    
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 
	
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse    	
    
	-- set @query = case 
	-- 	when @query is null then '""' 
	-- 	when @query = '' then '""'
	-- 	when @query = '""' then '""'
	-- else '"'+@query + '*"' end      
	SELECT     
		    [IDMatrizControlAcceso],
            [Nombre],
            [Descripcion],
            [Color],
            [BackgroundColor],
            [Icono],
            [Parent],
            isnull([Orden],0) as [Orden],
            isnull([Estatus],0) as Estatus
	into #tempResponse
	FROM [RH].[tblMatrizControlAcceso] d with(nolock)     
	where 
        ((Nombre like '%'+@query+'%') or isnull(@query,'') = '')  and (Estatus=@Estatus or @Estatus is null )

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDMatrizControlAcceso) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRows
	from #tempResponse    
	order by 
		case when @orderDirection = 'asc'	then  Nombre end,			
		case when @orderDirection = 'desc'	then  Nombre end ,		
		Nombre 

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO
