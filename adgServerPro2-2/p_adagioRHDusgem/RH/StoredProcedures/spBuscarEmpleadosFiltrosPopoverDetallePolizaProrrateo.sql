USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx
** FechaCreacion : 2022-07-04
** Paremetros  :
-- PENDIENTES POR REVISAR EXCLUIR USUARIOS , INCIDENCIASAUSENTISMOS, SOLO VIGENTES , SUBORDINADOS
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor   Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/ 
Create   PROCEDURE [RH].[spBuscarEmpleadosFiltrosPopoverDetallePolizaProrrateo]
(
	@dtFiltros [Nomina].[dtFiltrosRH]  READONLY,
    @IDUsuario int ,
    @PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '',
	@orderByColumn	VARCHAR(50) = 'ClaveEmpleado',
	@orderDirection VARCHAR(4) = 'asc'
)
AS
BEGIN	 
    DECLARE                       
        @TotalPaginas INT = 0
        ,@TotalRegistros DECIMAL(18,2) = 0.00
        ,@Conjuncion varchar(3)
        ,@QueryMain as varchar(max)
		,@IDPoliza int;
        
    
    SET @PageNumber = CASE WHEN isnull(@PageNumber,0) =0 THEN 1 ELSE @PageNumber END
    SET @PageSize = CASE WHEN isnull(@PageSize,0) =0 THEN 2147483647 ELSE @PageSize END
    SET @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'ClaveEmpleado' ELSE @orderByColumn END
    SET @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'asc' ELSE @orderDirection END

    if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;    
    if object_id('tempdb..#tempFiltros') is not null drop table #tempFiltros  

	SELECT * INTO #tempFiltros from @dtFiltros	
	DELETE #tempFiltros where Value is null or Value = ''
	
    SELECT @Conjuncion= Value from @dtFiltros where Catalogo= 'Conjuncion'    

	set @IDPoliza =CAST( [Nomina].[fnObtenerValorFiltro](@dtFiltros, 'IDPoliza', '0') as int)
 
    create table #tempFinalEmpleados (
        IDEmpleado int,
        IDUsuario int,
        ClaveEmpleado varchar(255),
        Nombre varchar(255),
        NombreCompleto varchar(255),
        Puesto varchar(255),
        Departamento varchar(255),
        Sucursal varchar(255),
        UrlFoto  varchar(255) 
    )        
       
    SET @QueryMain= N' 
    SELECT  
        isnull(u.IDEmpleado,0) as IDEmpleado,
        u.IDUsuario,COALESCE(ClaveEmpleado,''N/A'') As ClaveEmpleado, 
        COALESCE(e.Nombre,u.Nombre) as Nombre , 
        COALESCE(e.NombreCompleto,(concat(isnull(u.Nombre,''''),'' '',isnull(u.Apellido,'''') ) ))  AS NombreCompleto,
        e.Puesto,
        e.Departamento,
        e.Sucursal,
        [Utilerias].[fnGetUrlFotoUsuario](u.Cuenta) as UrlFoto 
    FROM  Seguridad.tblUsuarios u
		LEFT JOIN RH.tblEmpleadosMaster e on e.IDEmpleado=u.IDEmpleado
		JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on dfe.IDEmpleado = U.IDEmpleado and dfe.IDUsuario = '+Cast(@IDUsuario as Varchar(100))+'
		
	WHERE 
		u.IDEmpleado not in (select IDEmpleado from Nomina.tblDetallePolizaProrrateoEmpleado where IDPoliza = '+Cast(@IDPoliza as Varchar(100))+') and
		'+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Solo Vigentes') THEN '(e.Vigente=1) AND ' ELSE '' END +'
        (1='+ (case when @Conjuncion='AND' then '1' else '0' end )+ '
        
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Areas') THEN @Conjuncion+'   ((E.IDArea in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Areas''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'CentrosCostos') THEN @Conjuncion+' ((E.IDCentroCosto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''CentrosCostos''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'ClasificacionesCorporativas') THEN @Conjuncion+' ((E.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''ClasificacionesCorporativas''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Clientes') THEN  @Conjuncion+' ((E.IDCliente in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Clientes''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Departamentos') THEN  @Conjuncion+' ((E.IDDepartamento in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Departamentos''),'',''))))  ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Divisiones') THEN  @Conjuncion+' ((E.IDDivision in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Divisiones''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Prestaciones') THEN  @Conjuncion+' ((E.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Prestaciones''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Puestos') THEN @Conjuncion+' ((E.IDPuesto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Puestos''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RazonesSociales') THEN  @Conjuncion+' ((E.IdEmpresa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RazonesSociales''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Regiones') THEN  @Conjuncion+' ((E.IDRegion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Regiones''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RegPatronales') THEN  @Conjuncion+' ((E.IDRegPatronal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RegPatronales''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Sucursales') THEN  @Conjuncion+' ((E.IDSucursal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Sucursales''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'TiposContratacion') THEN  @Conjuncion+' ((E.IDTipoContrato in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''TiposContratacion''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'TiposNomina') THEN  @Conjuncion+' ((E.IDTipoNomina in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''TiposNomina''),'','')))) ' ELSE '' END +'
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Usuarios' ) THEN  @Conjuncion+' ((u.IDUsuario in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Usuarios''),'','')))) ' ELSE '' END +'        
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Empleados' ) THEN  @Conjuncion+' ((e.IDEmpleado in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Empleados''),'','')))) ' ELSE '' END +'        
        '+ CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Excluir Empleado' ) THEN  @Conjuncion+' ((e.IDEmpleado not in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Excluir Empleado''),'','')))) ' ELSE '' END +'        
        )  '+ Case WHEN ISNULL(@query,'') <> '' then 'AND 
                                            (
                                                ClaveEmpleado like ''%'+@query+'%'' or
                                                NombreCompleto like ''%'+@query+'%'' 
                                            )'  ELSE '' end 
		
   
    
    insert into #tempFinalEmpleados
    exec (@QueryMain);               

    SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
    FROM #tempFinalEmpleados

    SELECT @TotalRegistros = CAST(COUNT([IDEmpleado]) AS DECIMAL(18,2)) FROM #tempFinalEmpleados

    SELECT *,
        TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
        cast(@TotalRegistros as int) [TotalRows]
    FROM #tempFinalEmpleados
    ORDER BY
        case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		    then ClaveEmpleado end  ,
        case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'		then ClaveEmpleado end desc,
        case when @orderByColumn = 'NombreCompleto'			and @orderDirection = 'asc'		    then NombreCompleto end  ,
        case when @orderByColumn = 'NombreCompleto'			and @orderDirection = 'desc'		then NombreCompleto end desc --,
        -- case when @orderByColumn = 'Puesto'			        and @orderDirection = 'asc'		    then Puesto end ,
        -- case when @orderByColumn = 'Puesto'			        and @orderDirection = 'desc'		then Puesto end desc,
        -- case when @orderByColumn = 'Sucursal'			    and @orderDirection = 'asc'		    then Sucursal end ,
        -- case when @orderByColumn = 'Sucursal'			    and @orderDirection = 'desc'		then Sucursal end desc ,
        -- case when @orderByColumn = 'Departamento'			and @orderDirection = 'asc'		    then Departamento end  ,
        -- case when @orderByColumn = 'Departamento'			and @orderDirection = 'desc'		then Departamento end desc
    OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
    
END
GO
