USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************** 
** Descripción		: Busca lista de niveles
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2017-08-01
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el Result set de este sp es necesario refactorizar los siguiente sps
		[ReporteClimaLaboralV1].spBuscarSatisfaccionGeneralPorNiveles
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2023-07-26          Julio Castillo      Se forzo que el ordenamiento sea por el ORDEN del catalogo ya que siempre es Numerico y en la vista
                                        no tiene para hacerlo asc o desc. 
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarNivelesEmpresariales]    
(    
    @IDNivelEmpresarial int =null
    ,@Nombre Varchar(max) = null  
    ,@Orden int = null  
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
	;
 
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
		 IDNivelEmpresarial,Nombre,Orden
	into #tempResponse
	FROM [RH].[tblCatNivelesEmpresariales] d with(nolock)     
	

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDNivelEmpresarial) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderDirection = 'asc'	then  Orden end,			
		case when @orderDirection = 'desc'	then  Orden end ,		
		Orden 

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
