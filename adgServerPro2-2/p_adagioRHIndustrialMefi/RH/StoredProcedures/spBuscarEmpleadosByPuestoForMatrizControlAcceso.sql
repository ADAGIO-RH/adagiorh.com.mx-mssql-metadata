USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar lista de empleados para el modulo de Matriz control acceso
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2023-08-03
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spBuscarEmpleadosByPuestoForMatrizControlAcceso] (
	@IDPuesto int = 0	
	,@IDUsuario int        
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = null
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
) as
	SET FMTONLY OFF;  

	declare  
		@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
		,@IDTipoCatalogoEstatusPlazas int = 4
		,@IDIdioma varchar(20)
        ,@IDOrganigrama int
	;	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query = '' then null
				else @query end
         
    -- set @query = case 
    --             when @query is null then '""' 
    --             when @query = '' then '""'
    --             when @query =  '""' then '""'
    --         else '"*'+@query + '*"' end

  
	IF OBJECT_ID('tempdb..#TempEmpleados') IS NOT NULL DROP TABLE #TempEmpleados

	select 
		m.IDEmpleado,
        m.NOMBRECOMPLETO [NombreCompleto],        
        isnull(ft.ClaveEmpleado,'') as Foto,
        m.ClaveEmpleado,
        SUBSTRING(coalesce(m.Nombre, ''), 1, 1)+SUBSTRING(coalesce(m.Paterno, coalesce(m.Materno, '')), 1, 1) as Iniciales,
        isnull((
            SELECT 
                asignacion.IDMatrizControlAcceso as [IDMatrizControlAcceso],
                Value
                -- (select Parent from  rh.tblMatrizControlAcceso where IDMatrizControlAcceso=asignacion.IDAsignacionMatrizControlAcceso) as Parent                 
            FROM 
                RH.tblAsignacionesMatrizControlAcceso asignacion
                -- inner join rh.tblMatrizControlAcceso matriz on matriz.IDMatrizControlAcceso=asignacion.IDMatrizControlAcceso
            where IDEmpleado = m.IDEmpleado
            for json auto, WITHOUT_ARRAY_WRAPPER
        ),'{}') as MatrizControlAcceso        
	into #TempEmpleados
	from RH.tblEmpleadosMaster m
    left join rh.tblFotosEmpleados ft on ft.IDEmpleado=m.IDEmpleado
    -- left join rh.tblAsignacionesMatrizControlAcceso asig on asig.IDEmpleado=m.IDEmpleado
    where m.IDPuesto=@IDPuesto and 
    (  m.NOMBRECOMPLETO like '%'+@query+'%' OR ISNULL(@query,'')='' or m.ClaveEmpleado=@query)
    and m.Vigente=1
			
            
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempEmpleados

	select @TotalRegistros = cast(COUNT([IDEmpleado]) as decimal(18,2)) from #TempEmpleados		
	    
	select
		IDEmpleado,NombreCompleto,ClaveEmpleado,Foto,Iniciales,MatrizControlAcceso,NombreCompleto
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        , cast(@TotalRegistros  as int ) as TotalRows
	from #TempEmpleados
	 ORDER BY 
		CASE WHEN @orderByColumn = 'NombreCompleto'	and @orderDirection = 'asc'	then NombreCompleto end,			
		CASE WHEN @orderByColumn = 'NombreCompleto'	and @orderDirection = 'desc' then NombreCompleto end desc,			
		CASE WHEN @orderByColumn = 'ClaveEmpleado'	and @orderDirection = 'asc'	then ClaveEmpleado end,			
		CASE WHEN @orderByColumn = 'ClaveEmpleado'	and @orderDirection = 'desc' then ClaveEmpleado end desc,				
		ClaveEmpleado asc                     
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO
