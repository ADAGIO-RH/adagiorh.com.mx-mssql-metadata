USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarEmpleadosMaster](  
	@FechaIni date = '1900-01-01',              
	@Fechafin date = '9999-12-31',              
	@IDUsuario int = 0,              
	@EmpleadoIni Varchar(20) = '0',              
	@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',              
	@IDTipoNomina int = 0,              
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY              
) AS              
BEGIN              
	SET QUERY_GOVERNOR_COST_LIMIT 0;        
	SET FMTONLY OFF;   

	DECLARE 
		@dtEmpleados [RH].[dtEmpleados],
		@QuerySelect Varchar(Max) = '',
		@QueryFrom Varchar(Max) = '',
		@QueryFrom2 Varchar(Max) = '',
		@QueryWhere Varchar(Max) = '',
		@LenFrom int
	;

	if object_id('tempdb..#tempFiltros') is not null drop table #tempFiltros  

	select *
	INTO #tempFiltros
	from @dtFiltros
	
	delete #tempFiltros
	where Value is null or Value = ''


SET @QuerySelect = N'      
 SELECT               
   E.IDEmpleado              
   ,UPPER(E.ClaveEmpleado)AS ClaveEmpleado              
   ,UPPER(E.RFC) AS RFC              
   ,UPPER(E.CURP) AS CURP              
   ,UPPER(E.IMSS) AS IMSS              
   ,UPPER(E.Nombre) AS Nombre              
   ,UPPER(E.SegundoNombre) AS SegundoNombre               
   ,UPPER(E.Paterno) AS Paterno              
   ,UPPER(E.Materno) AS Materno              
   ,substring(UPPER(COALESCE(E.Paterno,'''')+'' ''+COALESCE(E.Materno,'''')+'' ''+COALESCE(E.Nombre,'''')+'' ''+COALESCE(E.SegundoNombre,'''')),1,49 ) AS NOMBRECOMPLETO              
   ,ISNULL(E.IDLocalidadNacimiento,0) as IDLocalidadNacimiento              
   ,UPPER(ISNULL(E.LocalidadNacimiento,'''')) AS LocalidadNacimiento              
   ,ISNULL(E.IDMunicipioNacimiento,0) as IDMunicipioNacimiento              
   ,UPPER(ISNULL(E.MunicipioNacimiento,'''')) AS MunicipioNacimiento              
   ,ISNULL(E.IDEstadoNacimiento,0) as IDEstadoNacimiento              
   ,UPPER(ISNULL(E.EstadoNacimiento,'''')) AS EstadoNacimiento              
   ,ISNULL(E.IDPaisNacimiento,0) as IDPaisNacimiento              
   ,UPPER(ISNULL(E.PaisNacimiento,'''')) AS PaisNacimiento              
   ,isnull(E.FechaNacimiento,''1900-01-01'') as FechaNacimiento              
   ,ISNULL(E.IDEstadoCiviL,0) AS IDEstadoCivil              
   ,UPPER(ISNULL(e.EstadoCivil,'''')) AS EstadoCivil              
   ,E.Sexo              
   ,isnull(E.IDEscolaridad,0) as IDEscolaridad              
   ,UPPER(isnull(e.Escolaridad,'''')) as Escolaridad              
   ,UPPER(E.DescripcionEscolaridad) AS DescripcionEscolaridad              
   ,ISNULL(E.IDInstitucion,0) as IDInstitucion              
   ,UPPER(isnull(e.Institucion,'''')) as Institucion              
   ,ISNULL(E.IDProbatorio,0) as IDProbatorio              
   ,UPPER(isnull(e.Probatorio,'''')) as Probatorio              
   ,isnull(E.FechaPrimerIngreso,''1900-01-01'') as FechaPrimerIngreso              
   ,isnull(E.FechaIngreso,''1900-01-01'') as FechaIngreso              
   ,isnull(E.FechaAntiguedad,''1900-01-01'') as FechaAntiguedad              
   ,isnull(E.Sindicalizado,0) as Sindicalizado              
   ,ISNULL(E.IDJornadaLaboral,0)AS IDJornadaLaboral              
   ,UPPER(ISNULL(e.JornadaLaboral,'''')) AS JornadaLaboral              
   ,UPPER(E.UMF) AS UMF              
   ,UPPER(E.CuentaContable) AS CuentaContable              
   ,isnull(E.IDTipoRegimen,0) AS IDTipoRegimen              
   ,UPPER(ISNULL(e.TipoRegimen,'''')) AS TipoRegimen              
   ,ISNULL(E.IDPreferencia,0) AS IDPreferencia              
   ,isnull(E.IDDepartamento,0) as  IDDepartamento              
   ,UPPER(isnull(e.Departamento,'''')) as Departamento              
   ,isnull(E.IDSucursal,0) as  IDSucursal              
   ,UPPER(isnull(e.Sucursal,'''')) as Sucursal              
   ,isnull(E.IDPuesto,0) as  IDPuesto              
   ,UPPER(isnull(e.Puesto,'''')) as Puesto             
   ,isnull(E.IDCliente,0) as  IDCliente              
   ,UPPER(isnull(e.Cliente,'''')) as Cliente              
   ,isnull(E.IdEmpresa,0) as  IDEmpresa              
   ,substring(UPPER(isnull(e.Empresa,'''')),1,49) as Empresa              
   ,isnull(E.IDCentroCosto,0) as  IDCentroCosto              
   ,UPPER(isnull(e.CentroCosto,'''')) as CentroCosto              
   ,isnull(E.IDArea,0) as  IDArea              
   ,UPPER(isnull(e.Area,'''')) as Area              
   ,isnull(E.IDDivision,0) as  IDDivision              
   ,UPPER(isnull(e.Division,'''')) as Division              
   ,isnull(E.IDRegion,0) as  IDRegion              
   ,UPPER(isnull(e.Region,'''')) as Region              
   ,isnull(E.IDClasificacionCorporativa,0) as  IDClasificacionCorporativa              
   ,UPPER(isnull(e.ClasificacionCorporativa,'''')) as ClasificacionCorporativa              
   ,isnull(E.IDRegPatronal,0) as  IDRegPatronal              
   ,UPPER(isnull(e.RegPatronal,'''')) as RegPatronal              
   ,isnull(E.IDTipoNomina,0) as  IDTipoNomina       
   ,UPPER(isnull(e.TipoNomina,'''')) as TipoNomina              
   ,ISNULL(E.SalarioDiario,0.00) as SalarioDiario              
   ,ISNULL(E.SalarioDiarioReal,0.00) as SalarioDiarioReal              
   ,ISNULL(E.SalarioIntegrado,0.00)as SalarioIntegrado              
   ,ISNULL(E.SalarioVariable,0.00)as SalarioVariable              
   ,ISNULL(E.IDTipoPrestacion,0) as IDTipoPrestacion              
   ,isnull(E.IDRazonSocial,0) as  IDRazonSocial              
   ,UPPER(isnull(E.RazonSocial,'''')) as RazonSocial              
   ,isnull(E.IDAfore,0) as  IDAfore              
   ,UPPER(isnull(E.Afore,'''')) as Afore              
   ,isnull(E.Vigente,cast(0 as bit)) as Vigente               
   ,0 as RowNumber          
   ,E.[ClaveNombreCompleto]            
   ,Isnull(E.PermiteChecar,0) as  PermiteChecar             
   ,Isnull(E.RequiereChecar,0) as  RequiereChecar             
   ,Isnull(E.PagarTiempoExtra,0) as  PagarTiempoExtra             
   ,Isnull(E.PagarPrimaDominical,0) as  PagarPrimaDominical             
   ,Isnull(E.PagarDescansoLaborado,0) as  PagarDescansoLaborado             
   ,Isnull(E.PagarFestivoLaborado,0) as  PagarFestivoLaborado          
   ----------          
   ,Isnull(E.IDDocumento,0) as IDDocumento             
   ,UPPER(Isnull(e.Documento,'''')) as Documento             
   ,Isnull(E.IDTipoContrato,0) as IDTipoContrato             
   ,UPPER(Isnull(E.TipoContrato,'''')) as TipoContrato            
   ,isnull(E.FechaIniContrato,''1900-01-01'') as	FechaIniContrato          
   ,isnull(E.FechaFinContrato,''1900-01-01'') as	FechaFinContrato    
   ,isnull(JSON_VALUE(CatPrestaciones.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace('esmx', '-',''))+''', ''Descripcion'')),''SIN PRESTACION'') as TiposPrestacion
   ,isnull(catTipoTrabajador.Descripcion,''SIN TIPO DE TRABAJADOR'') as tipoTrabajadorEmpleado
   ---------          
  FROM [RH].[tblEmpleadosMaster] E WITH(NOLOCK) 

    LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) ON Prestaciones.IDEmpleado = E.IDEmpleado AND Prestaciones.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and Prestaciones.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''           
  LEFT JOIN [RH].[tblCatTiposPrestaciones] CatPrestaciones WITH(NOLOCK) ON Prestaciones.IDTipoPrestacion = CatPrestaciones.IDTipoPrestacion
  LEFT JOIN [RH].[tblTipoTrabajadorEmpleado] tipoTrabajadorEmpleado WITH(NOLOCK) ON tipoTrabajadorEmpleado.IDEmpleado = E.IDEmpleado
  LEFT JOIN [IMSS].[tblCatTipoTrabajador] catTipoTrabajador WITH(NOLOCK) ON tipoTrabajadorEmpleado.IDTipoTrabajador = catTipoTrabajador.IDTipoTrabajador

   

	JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on dfe.IDEmpleado = E.IDEmpleado and dfe.IDUsuario = '+Cast(@IDUsuario as Varchar(100))  
	
	
SET @QueryWhere = N'            
  WHERE (E.ClaveEmpleado BETWEEN '''+@EmpleadoIni+''' AND '''+@EmpleadoFin+''' )  ' +             
   CASE WHEN @IDTipoNomina <> 0 THEN 'and ((E.IDTipoNomina ='+ CAST(@IDTipoNomina as varchar(20))+'))' ELSE '' END +         
  -- 'and ( (M.FechaAlta<='''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and (M.FechaBaja>='''+FORMAT(@FechaIni,'yyyy-MM-dd')+''' or M.FechaBaja is null)) or (M.FechaReingreso<='''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''))'+
    CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'TiposNomina') THEN ' and ((E.IDTipoNomina in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''TiposNomina''),'','')))) ' ELSE '' END +
    CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo IN ('Usuarios')) THEN 'and ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Usuarios''),'','')))) ' ELSE '' END +
    --CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Subordinados')  THEN ' and ((jefes.IDJefe in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Subordinados''),'','')))) ' ELSE '' END +

   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Empleados') THEN ' and ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Empleados''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Departamentos') THEN '  and ((E.IDDepartamento in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Departamentos''),'',''))))  ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Sucursales') THEN '  and ((E.IDSucursal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Sucursales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Puestos') THEN '  and ((E.IDPuesto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Puestos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Prestaciones') THEN '   and ((E.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Prestaciones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Clientes') THEN '  and ((E.IDCliente in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Clientes''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'TiposContratacion') THEN '  and ((E.IDTipoContrato in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''TiposContratacion''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RazonesSociales') THEN '   and ((E.IdEmpresa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RazonesSociales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RegPatronales') THEN '   and ((E.IDRegPatronal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RegPatronales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Divisiones') THEN '   and ((E.IDDivision in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Divisiones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'CentrosCostos') THEN '   and ((E.IDCentroCosto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''CentrosCostos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Areas') THEN ' and ((E.IDArea in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Areas''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Regiones') THEN ' and ((E.IDRegion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Regiones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'ClasificacionesCorporativas') THEN '   and ((E.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''ClasificacionesCorporativas''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'NombreClaveFilter') THEN '   and ((COALESCE(E.ClaveEmpleado,'''')+'' ''+ COALESCE(E.Paterno,'''')+'' ''+COALESCE(E.Materno,'''')+'', ''+COALESCE(E.Nombre,'''')+'' ''+COALESCE(E.SegundoNombre,'''')) like ''%''+(Select top 1 Value from #tempFiltros where Catalogo = ''NombreClaveFilter'')+''%'')' ELSE '' END 
   + ' order by e.ClaveEmpleado asc' 



   exec (@querySelect  + @QueryWhere)
END
GO
