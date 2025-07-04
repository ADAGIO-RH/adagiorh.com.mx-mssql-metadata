USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca lista de departamento
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2017-08-01
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el Result set de este sp es necesario refactorizar los siguiente sps
		[ReporteClimaLaboralV1].spBuscarSatisfaccionGeneralPorDepartamento
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarCatDepartamentos](    
	@IDDepartamento int =null
	,@Departamento	varchar(max) = null  
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
	,@ValidarFiltros bit =1
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

	IF OBJECT_ID('tempdb..#TempDepartamentos') IS NOT NULL DROP TABLE #TempDepartamentos 
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  
	select ID   
	Into #TempDepartamentos  
	from Seguridad.tblFiltrosUsuarios with(nolock)  
	where IDUsuario = @IDUsuario and Filtro = 'Departamentos' 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		 d.IDDepartamento    
		,d.Codigo    
		, UPPER (JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Descripcion 
		,d.CuentaContable    
		,isnull(d.IDEmpleado,0) as IDEmpleado    
		,d.JefeDepartamento     
		,ROW_NUMBER()OVER(ORDER BY d.IDDepartamento ASC)  AS ROWNUMBER    
        ,Traduccion
	into #tempResponse
	FROM [RH].[tblCatDepartamentos] d with(nolock)     
	WHERE
	--(Codigo LIKE @Departamento+'%') OR (Descripcion LIKE @Departamento+'%') OR (@Departamento IS NULL)    
	--	and 
		( 
			(d.IDDepartamento in (select ID from #TempDepartamentos)   OR Not Exists(select ID from #TempDepartamentos)  OR @ValidarFiltros=0)   
                and 
            (d.IDDepartamento = @IDDepartamento or isnull(@IDDepartamento,0) =0)
        )  
		and (@query = '""' or contains(d.*, @query)) 
	ORDER BY d.Descripcion ASC    

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDDepartamento) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,		
		Codigo asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO
