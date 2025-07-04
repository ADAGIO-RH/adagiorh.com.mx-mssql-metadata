USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Onboarding].[spBuscarProcesosOnboarding]  (
@IDProcesoOnboarding int=null,
@IDEmpleadoNuevo int =null,
@IDUsuario int =NULL
,@PageNumber	int = 1
,@PageSize		int = 2147483647
,@query			varchar(100) = '""'
,@orderByColumn	varchar(50) = 'NombreProceso'
,@orderDirection varchar(4) = 'asc'
,@ValidarFiltros bit =1
)
as
begin
    SET FMTONLY OFF;  
    declare  
        @TotalPaginas int = 0
        ,@TotalRegistros int =0
        ,@IDIdioma varchar(max)
        ;
        select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
    
        if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
        if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

        select
            @orderByColumn	 = case when @orderByColumn	 is null then 'NombreProceso' else @orderByColumn  end 
            ,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

        IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
        IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse ;
        
        
        select ID   
        Into #TempFiltros  
        from Seguridad.tblFiltrosUsuarios  with(nolock) 
        where IDUsuario = @IDUsuario and Filtro = 'ProcesoOnboarding';

        set @query = case 
                    when @query is null then '""' 
                    when @query = '' then '""'
                    when @query = '""' then '""'
                else '"'+@query + '*"' end;

With Proceso as(
  SELECT 
       PO.[IDProcesoOnboarding]
      ,PO.[NombreProceso]
      ,PO.[Terminado]      
      ,PO.[IDsPlantilla]     
      ,NombrePlantilla = ISNULL(
            STUFF(
                (
                    SELECT ', ' + CONVERT(NVARCHAR(100), ISNULL(NombrePlantilla, 'SIN ASIGNAR'))
                    FROM Onboarding.tblPlantillas WITH (NOLOCK)
                    WHERE IDPlantilla IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(PO.IDsPlantilla, ','))
                    ORDER BY NombrePlantilla ASC
                    FOR XML PATH('')
                ), 1, 1, ''
            ),
            'CARGOS NO DEFINIDOS'
        )
      ,[IDEmpleadoEncargado]
      ,ENCARGADO.NOMBRECOMPLETO as [NombreEncargado]
      ,ENCARGADO.ClaveEmpleado as ClaveEmpleado      
      ,UEncargado.IDUsuario as IDUsuarioEncargado
      ,NUEVO.ClaveEmpleado AS ClaveEmpleadoNuevo         
      ,PO.[IDNuevoEmpleado] as IDEmpleadoOnboarding
      ,UNUEVO.IDUsuario as IDUsuarioEmpleadoOnboarding
      ,NUEVO.NOMBRECOMPLETO AS [NombreCompletoOnboarding]
      ,NUEVO.Departamento as DepartamentoOnboarding
      ,NUEVO.IDDepartamento as IDDepartamentoOnboarding
      ,NUEVO.Puesto as PuestoOnboarding
      ,NUEVO.IDPuesto as IDPuestoOnboarding
      ,(Select count(*) from Tareas.tblTareas T
            where IDEstatusTarea = (select IDEstatusTarea from Tareas.tblCatEstatusTareas where IDTipoTablero=3 and IDReferencia=0 and IsEnd = 1 )
                AND PO.IDProcesoOnboarding = T.IDReferencia and T.IDTipoTablero =3) as TareasCompletadas
      ,(Select count(*) from Tareas.tblTareas T
            where IDEstatusTarea != (select IDEstatusTarea from Tareas.tblCatEstatusTareas where IDTipoTablero=3 and IDReferencia=0 and IsEnd = 1 )
                AND PO.IDProcesoOnboarding = T.IDReferencia and T.IDTipoTablero =3) as TareasPendientes
    FROM [Onboarding].[tblProcesosOnboarding] PO    
    LEFT JOIN Rh.tblEmpleadosMaster ENCARGADO on ENCARGADO.IDEmpleado =PO.IDEmpleadoEncargado 
    LEFT JOIN Rh.tblEmpleadosMaster NUEVO ON NUEVO.IDEmpleado = PO.IDNuevoEmpleado
    Left Join Seguridad.tblUsuarios UEncargado on ENCARGADO.IDEmpleado = UEncargado.IDEmpleado
    Left Join Seguridad.tblUsuarios UNUEVO on NUEVO.IDEmpleado = UNUEVO.IDEmpleado
    where  ( IDProcesoOnboarding =@IDProcesoOnboarding or isnull(@IDProcesoOnboarding, 0) = 0) AND
            (PO.IDNuevoEmpleado =@IDEmpleadoNuevo or isnull(@IDEmpleadoNuevo, 0) = 0) AND
            ( (IDProcesoOnboarding in ( select ID from #TempFiltros)) 
            OR NOT EXISTS (SELECT TOP 1 1 FROM #TempFiltros  ) OR @ValidarFiltros=0)
		and (@query = '""' or contains(PO.*, @query)) 
            	and (@query = '""' or contains(PO.*, @query)) 
)
    select *, 
        TotalTareas=TareasCompletadas+TareasPendientes, 
        Avance = CASE 
                WHEN (TareasCompletadas + TareasPendientes) = 0 THEN 0
                ELSE CAST((CAST(TareasCompletadas AS DECIMAL(18, 2))) / (TareasCompletadas + TareasPendientes) * 100 AS DECIMAL(18, 2))
            END,
         ROWNUMBER = ROW_NUMBER()OVER(ORDER BY NombreProceso ASC) 
            Into #TempResponse
    From Proceso 

    order by Proceso.NombreProceso asc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(@IDProcesoOnboarding) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'NombreProceso'			and @orderDirection = 'asc'		then NombreProceso end,			
		case when @orderByColumn = 'NombreProceso'			and @orderDirection = 'desc'	then NombreProceso end desc,
        case when @orderByColumn = 'NombreEncargado'			and @orderDirection = 'asc'		then NombreEncargado end,			
		case when @orderByColumn = 'NombreEncargado'			and @orderDirection = 'desc'	then NombreEncargado end desc,
        case when @orderByColumn = 'NombreCompletoOnboarding'	and @orderDirection = 'asc'		then NombreCompletoOnboarding end,			
		case when @orderByColumn = 'NombreCompletoOnboarding'	and @orderDirection = 'desc'	then NombreCompletoOnboarding end desc,
		NombreProceso asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
end
GO
