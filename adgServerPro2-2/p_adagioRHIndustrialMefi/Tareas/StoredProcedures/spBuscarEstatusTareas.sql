USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de buscar los 'estatus tareas'.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:      
    Este sp puede realizar busqueda por los siguientes filtros:
        * @IDEstatusTarea (Tareas.tblCatEstatusTareas)        
        * @IDReferencia y @IDTipoTablero (Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.)

    @IDUsuario
        Usuarios que ejecuto la acción.            
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spBuscarEstatusTareas](    	
    @IDTipoTablero int ,
    @IDReferencia int ,
    @IDEstatusTarea int =null,
	@IDUsuario int
       ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
    ,@ValidarFiltros bit =1
) as
begin
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
		 @orderByColumn	 = case when @orderByColumn	 is null then 'NombrePlantilla' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse ;
	
	
	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Plantilla'  

	set @query = case 
				when @query is null then '""' 
				when @query = '' then '""'
				when @query = '""' then '""'
			else '"'+@query + '*"' end

    select [IDEstatusTarea],
        [IDTipoTablero],
        [IDReferencia],
        [Icon],
        [Titulo],
        [Descripcion],
        Orden,
        isnull(IsEnd,0) as IsEnd,
        isnull(isDefault,0) as IsDefault,
        (select count(*) from Tareas.tblTareas WHERE IDTipoTablero=c.IDTipoTablero and IDReferencia=c.IDReferencia and IDEstatusTarea=c.IDEstatusTarea) as TotalTareas,
        ROWNUMBER = ROW_NUMBER()OVER(ORDER BY Titulo ASC) 
    Into #TempResponse
     from Tareas.tblCatEstatusTareas c
    where 
     ((IDTipoTablero=@IDTipoTablero and IDReferencia=@IDReferencia ) or ( isnull(@IDReferencia,0)=0  and isnull(@IDTipoTablero,0)=0 ))   and
     (IDEstatusTarea=@IDEstatusTarea or isnull(@IDEstatusTarea,0)=0 ) 
         AND  (IDEstatusTarea in (select ID from #TempFiltros)  
			OR Not Exists(select ID from #TempFiltros) or @ValidarFiltros=0)  
			and (@query = '""' or contains(c.*, @query)) 
    order by c.Orden

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(@IDEstatusTarea) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		-- case when @orderByColumn = 'Titulo'			and @orderDirection = 'asc'		then Titulo end,			
		-- case when @orderByColumn = 'Titulo'			and @orderDirection = 'desc'	then Titulo end desc,		
        -- case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		-- case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,
		Orden asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

end
GO
