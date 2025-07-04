USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Busca Catalogo de Beneficiarios de contratacion
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2024-06-04
** Paremetros		:     
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spBuscarCatBeneficiariosContratacion](    
	 @IDCatBeneficiarioContratacion int =null
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'RFC'
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'RFC' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		 d.IDCatBeneficiarioContratacion    
		,UPPER(d.RFC) as RFC
		,UPPER(d.RazonSocial) as RazonSocial
		,FullBeneficiarioContratacion = UPPER(d.RFC)+' - '+UPPER(d.RazonSocial)
	into #tempResponse
	FROM RH.tblCatBeneficiariosContratacion d with(nolock)     
	WHERE
        (d.IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion or isnull(@IDCatBeneficiarioContratacion,0) =0)
		and (@query = '""' or contains(d.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDCatBeneficiarioContratacion) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'RFC'			and @orderDirection = 'asc'		then RFC end,			
		case when @orderByColumn = 'RFC'			and @orderDirection = 'desc'	then RFC end desc,		
		RFC asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
