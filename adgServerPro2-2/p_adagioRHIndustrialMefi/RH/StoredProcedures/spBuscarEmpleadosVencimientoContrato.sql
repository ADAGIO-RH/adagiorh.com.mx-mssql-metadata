USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----Andrea Zainos:03/10/2022 
--Se agrega 
--la validación para que la búsqueda
--también muestre a los colaboradores que no tienen ningún contrato.

---Javier Peña:19/10/2022
/*Se corrige error en nombre de filtro de TipoContratacion, anteriormente estaba 
como TiposContratacion, y el back lo manda como TipoContratacion*/

CREATE PROCEDURE [RH].[spBuscarEmpleadosVencimientoContrato](    
	@FechaIni date = '1900-01-01',
	@Fechafin date = '9999-12-31',
	@IDUsuario int = 0,
	@EmpleadoIni Varchar(20) = '0',
	@EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',
	@IDTipoNomina int = 0,
	@dtFiltros [Nomina].[dtFiltrosRH] READONLY
)
AS
BEGIN
	SET QUERY_GOVERNOR_COST_LIMIT 0;        
	SET FMTONLY OFF;    

	DECLARE 
		--@dtVigenciaEmpleado [RH].[dtVigenciaEmpleado],
		--@dtContratosEmpleado [RH].[dtContratoEmpleado],
		@dtEmpleados [RH].[dtEmpleados],
		@QuerySelect Varchar(Max) = '',
		@QuerySelect2 Varchar(Max) = '',
		@QueryFrom Varchar(Max) = '',
		@QueryFrom2 Varchar(Max) = '',
		@QueryWhere Varchar(Max) = '',
		@LenFrom int,
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempFiltros') is not null drop table #tempFiltros;  
	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil    
    if object_id('tempdb..#tempContra') is not null drop table #tempContra          

	select *
	INTO #tempFiltros
	from @dtFiltros

	delete #tempFiltros
	where Value is null or Value = ''

	if (isnull(@EmpleadoIni,'0') = '0' and isnull(@EmpleadoFin,'ZZZZZZZZZZZZZZZZZZZZ') = 'ZZZZZZZZZZZZZZZZZZZZ')
	begin
		SET @EmpleadoIni = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')
		SET @EmpleadoFin = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')
	end;

	if ((isnull(@IDTipoNomina,0) = 0) and exists(select top 1 1 from #tempFiltros where Catalogo= 'TiposNomina'))
	begin
		select @IDTipoNomina = cast(Value as int)
		from #tempFiltros where Catalogo= 'TiposNomina'
	end;

	IF(@FechaIni <> isnull((Select top 1 cast(item as Date) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'FechaIni'),',')),getdate()))
	BEGIN
		set @FechaIni = isnull((Select top 1 cast(item as Date) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'FechaIni'),',')),getdate())
	END

	IF(@FechaFin <> isnull((Select top 1 cast(item as Date) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'FechaFin'),',')),getdate()))
	BEGIN
		set @FechaFin = isnull((Select top 1 cast(item as Date) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'FechaFin'),',')),getdate())
	END
  
	select 
		mm.IDEmpleado
		,FechaAlta
		,FechaBaja
		,case when ((mm.FechaBaja is not null and mm.FechaReingreso is not null) and mm.FechaReingreso > mm.FechaBaja) then mm.FechaReingreso else null end as FechaReingreso
		,mm.FechaReingresoAntiguedad
		,mm.IDMovAfiliatorio    
		,mm.SalarioDiario
		,mm.SalarioVariable
		,mm.SalarioIntegrado
		,mm.SalarioDiarioReal
	into #tempMovAfil  
	from IMSS.TblVigenciaEmpleado mm with(nolock)
	where ( mm.FechaAlta<=@FechaFin and (mm.FechaBaja>=@FechaIni or mm.FechaBaja is null)) or (mm.FechaReingreso<=@FechaFin)

	update tm 
		set tm.SalarioDiario	 = fm.SalarioDiario
			,tm.SalarioVariable	 = fm.SalarioVariable
			,tm.SalarioIntegrado  = fm.SalarioIntegrado
			,tm.SalarioDiarioReal = fm.SalarioDiarioReal
	from #tempMovAfil tm
		join (
			Select  mSalario.*,ROW_NUMBER()over(partition by mSalario.IDEmpleado order by mSalario.IDEmpleado,mSalario.Fecha desc ) as [ROW]
			from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
				join #tempMovAfil tma on mSalario.IDEmpleado = tma.IDEmpleado
				join [IMSS].[tblCatTipoMovimientos] c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
			where mSalario.IDEmpleado= tma.IDEmpleado and c.Codigo in ('A','M','R')      
				and mSalario.Fecha <= @FechaFin        
			--order by mSalario.Fecha desc 
		) fm on tm.IDEmpleado = fm.IDEmpleado and fm.[ROW] = 1


	select  ContratoEmpleado.IDContratoEmpleado
		   ,ContratoEmpleado.IDEmpleado
		   ,Isnull(documentos.IDDocumento,0) as IDDocumento             
		   ,UPPER(Isnull(documentos.Descripcion,'')) as Documento             
		   ,Isnull(tipoContrato.IDTipoContrato,0) as IDTipoContrato             
		   ,UPPER(Isnull(tipoContrato.Descripcion,'')) as TipoContrato            
		   ,isnull(ContratoEmpleado.FechaIni,'1900-01-01') as FechaIniContrato          
		   ,isnull(ContratoEmpleado.FechaFin,'1900-01-01') as FechaFinContrato 
		   , RN = ROW_NUMBER()Over(partition by ContratoEmpleado.IDEmpleado order by ContratoEmpleado.FechaFin desc )
	into #tempContra
	from [RH].[tblContratoEmpleado] ContratoEmpleado WITH(NOLOCK)
		inner JOIN [RH].[tblCatDocumentos] documentos WITH(NOLOCK)
			ON ContratoEmpleado.IDDocumento = documentos.IDDocumento          
				and documentos.EsContrato = 1
		inner JOIN [sat].[tblCatTiposContrato] tipoContrato WITH(NOLOCK)
			ON ContratoEmpleado.IDTipoContrato = tipoContrato.IDTipoContrato    
  -- where ContratoEmpleado.FechaFin between @FechaIni and @Fechafin
    
--	delete #tempContra where RN > 1

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
   ,UPPER(ISNULL(ISNULL(LOCALIDAD.Descripcion,E.LocalidadNacimiento),'''')) AS LocalidadNacimiento
   ,ISNULL(E.IDMunicipioNacimiento,0) as IDMunicipioNacimiento
   ,UPPER(ISNULL(ISNULL(MUNICIPIO.Descripcion,E.MunicipioNacimiento),'''')) AS MunicipioNacimiento
   ,ISNULL(E.IDEstadoNacimiento,0) as IDEstadoNacimiento
   ,UPPER(ISNULL(ISNULL(ESTADOS.NombreEstado,E.EstadoNacimiento),'''')) AS EstadoNacimiento
   ,ISNULL(E.IDPaisNacimiento,0) as IDPaisNacimiento
   ,UPPER(ISNULL(ISNULL(PAISES.Descripcion,E.PaisNacimiento),'''')) AS PaisNacimiento
   ,isnull(E.FechaNacimiento,''1900-01-01'') as FechaNacimiento
   ,ISNULL(E.IDEstadoCiviL,0) AS IDEstadoCivil
   ,JSON_VALUE(CIVILES.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')) as EstadoCivil
   ,JSON_VALUE(SEXOS.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')) as Sexo
   ,isnull(E.IDEscolaridad,0) as IDEscolaridad
   ,UPPER(isnull(ESTUDIOS.Descripcion,'''')) as Escolaridad
   ,UPPER(E.DescripcionEscolaridad) AS DescripcionEscolaridad
   ,ISNULL(E.IDInstitucion,0) as IDInstitucion
   ,UPPER(isnull(I.Descripcion,'''')) as Institucion
   ,ISNULL(E.IDProbatorio,0) as IDProbatorio
   ,UPPER(isnull(Probatorio.Descripcion,'''')) as Probatorio
   ,isnull(E.FechaPrimerIngreso,''1900-01-01'') as FechaPrimerIngreso
   ,isnull(E.FechaIngreso,''1900-01-01'') as FechaIngreso
   ,CASE WHEN isnull(M.FechaReingresoAntiguedad,''1900-01-01'') >= M.FechaAlta THEN ISNULL(M.FechaReingresoAntiguedad,''1900-01-01'')
				ELSE M.FechaAlta
				END  as FechaAntiguedad
   ,isnull(E.Sindicalizado,0) as Sindicalizado
   ,ISNULL(E.IDJornadaLaboral,0)AS IDJornadaLaboral
   ,UPPER(ISNULL(JORNADA.Descripcion,'''')) AS JornadaLaboral
   ,UPPER(E.UMF) AS UMF
   ,UPPER(E.CuentaContable) AS CuentaContable
   ,isnull(E.IDTipoRegimen,0) AS IDTipoRegimen
   ,UPPER(ISNULL(TR.Descripcion,'''')) AS TipoRegimen
   ,ISNULL(E.IDPreferencia,0) AS IDPreferencia
   ,isnull(D.IDDepartamento,0) as  IDDepartamento
   ,UPPER(isnull(JSON_VALUE(D.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')),''SIN DEPARTAMENTO'')) as Departamento
   ,isnull(S.IDSucursal,0) as  IDSucursal
   ,UPPER(isnull(S.Descripcion,''SIN SUCURSAL'')) as Sucursal
   ,isnull(P.IDPuesto,0) as  IDPuesto
   ,UPPER(isnull(P.Descripcion,''SIN PUESTOS'')) as Puesto             
   ,isnull(C.IDCliente,0) as  IDCliente
   ,JSON_VALUE(C.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''NombreComercial'')) as Cliente
   ,isnull(EMP.IdEmpresa,0) as  IDEmpresa
   ,substring(UPPER(isnull(EMP.NombreComercial,''SIN EMPRESA'')),1,49) as Empresa
'

set @QuerySelect2 = '
   ,isnull(CC.IDCentroCosto,0) as  IDCentroCosto
   ,UPPER(isnull(JSON_VALUE(CC.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')),''SIN CENTRO DE COSTO'')) as CentroCosto
   ,isnull(A.IDArea,0) as  IDArea
   ,UPPER(isnull(JSON_VALUE(A.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')),''SIN ÁREA'')) as Area
   ,isnull(DV.IDDivision,0) as  IDDivision
   ,UPPER(isnull(JSON_VALUE(DV.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')),''SIN DIVISIÓN'')) as Division
   ,isnull(R.IDRegion,0) as  IDRegion
   ,UPPER(isnull(JSON_VALUE(R.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')),''SIN REGIÓN'')) as Region
   ,isnull(CP.IDClasificacionCorporativa,0) as  IDClasificacionCorporativa
   ,UPPER(isnull(CP.Descripcion,''SIN CLASIFICACIÓN CORPORATIVA'')) as ClasificacionCorporativa
   ,isnull(RP.IDRegPatronal,0) as  IDRegPatronal
   ,UPPER(isnull(RP.RazonSocial,''SIN REG. PATRONAL'')) as RegPatronal
   ,isnull(TipoNomina.IDTipoNomina,0) as  IDTipoNomina       
   ,UPPER(isnull(TipoNomina.Descripcion,''SIN TIPO DE NÓMINA'')) as TipoNomina
   ,ISNULL(m.SalarioDiario,0.00) as SalarioDiario
   ,ISNULL(m.SalarioDiarioReal,0.00) as SalarioDiarioReal
   ,ISNULL(m.SalarioIntegrado,0.00)as SalarioIntegrado
   ,ISNULL(m.SalarioVariable,0.00)as SalarioVariable
   ,ISNULL(Prestaciones.IDTipoPrestacion,0) as IDTipoPrestacion
   ,isnull(RazonSocial.IDRazonSocial,0) as  IDRazonSocial
   ,UPPER(isnull(RazonSocial.RazonSocial,''SIN RAZÓN SOCIAL'')) as RazonSocial
   ,isnull(afore.IDAfore,0) as  IDAfore
   ,UPPER(isnull(afore.Descripcion,''SIN AFORE'')) as Afore
   ,cast(0 as bit) as Vigente       
   ,0 as RowNumber          
   ,NULL as [ClaveNombreCompleto]            
   ,Isnull(E.PermiteChecar,0) as  PermiteChecar             
   ,Isnull(E.RequiereChecar,0) as  RequiereChecar             
   ,Isnull(E.PagarTiempoExtra,0) as  PagarTiempoExtra             
   ,Isnull(E.PagarPrimaDominical,0) as  PagarPrimaDominical             
   ,Isnull(E.PagarDescansoLaborado,0) as  PagarDescansoLaborado             
   ,Isnull(E.PagarFestivoLaborado,0) as  PagarFestivoLaborado          
   ,Isnull(contratos.IDDocumento,0) as IDDocumento             
   ,UPPER(Isnull(contratos.Documento,'''')) as Documento             
   ,Isnull(contratos.IDTipoContrato,0) as IDTipoContrato             
   ,UPPER(Isnull(contratos.TipoContrato,'''')) as TipoContrato            
   ,isnull(contratos.FechaIniContrato,''1900-01-01'') as FechaIniContrato          
   ,isnull(contratos.FechaFinContrato,''1900-01-01'') as FechaFinContrato 
   ,isnull(JSON_VALUE(CatPrestaciones.Traduccion, FORMATMESSAGE(''$.%s.%s'', '''+lower(replace(@IDIdioma, '-',''))+''', ''Descripcion'')),''SIN PRESTACION'') as TiposPrestacion
   ,isnull(catTipoTrabajador.Descripcion,''SIN TIPO DE TRABAJADOR'') as tipoTrabajadorEmpleado
   '
   
     --print @QuerySelect      

 SET @QueryFrom ='      
  FROM [RH].[tblEmpleados] E WITH(NOLOCK)   
  JOIN Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe on dfe.IDEmpleado = E.IDEmpleado and dfe.IDUsuario = '+Cast(@IDUsuario as Varchar(100))+'   
  LEFT JOIN SAT.tblCatTiposRegimen TR WITH(NOLOCK) on E.IDTipoRegimen = TR.IDTipoRegimen
  LEFT JOIN SAT.tblCatLocalidades LOCALIDAD WITH(NOLOCK) ON E.IDLocalidadNacimiento = LOCALIDAD.IDLocalidad
  LEFT JOIN SAT.tblCatMunicipios MUNICIPIO WITH(NOLOCK)ON E.IDMunicipioNacimiento = MUNICIPIO.IDMunicipio
  LEFT JOIN SAT.tblCatEstados ESTADOS WITH(NOLOCK)ON E.IDEstadoNacimiento = ESTADOS.IDEstado
  LEFT JOIN SAT.tblCatPaises PAISES WITH(NOLOCK) ON E.IDPaisNacimiento = PAISES.IDPais
  LEFT JOIN RH.tblCatEstadosCiviles CIVILES WITH(NOLOCK) ON E.IDEstadoCivil = CIVILES.IDEstadoCivil
  LEFT JOIN RH.tblCatGeneros SEXOS WITH(NOLOCK) ON E.Sexo = SEXOS.IDGenero
  LEFT JOIN STPS.tblCatEstudios ESTUDIOS WITH(NOLOCK) ON E.IDEscolaridad = ESTUDIOS.IDEstudio
  LEFT JOIN STPS.tblCatInstituciones I WITH(NOLOCK) on I.IDInstitucion = E.IDInstitucion
  LEFT JOIN STPS.tblCatProbatorios Probatorio WITH(NOLOCK) on Probatorio.IDProbatorio = e.IDProbatorio
  LEFT JOIN SAT.tblCatTiposJornada JORNADA WITH(NOLOCK) ON E.IDJornadaLaboral = JORNADA.IDTipoJornada
  LEFT JOIN [RH].[tblCatAfores] afore  with (nolock) ON afore.IDAfore = e.IDAfore
  LEFT JOIN [RH].[tblDepartamentoEmpleado] DE WITH(NOLOCK) ON E.IDEmpleado = DE.IDEmpleado AND DE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and dE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' 
  LEFT JOIN [RH].[tblCatDepartamentos] D WITH(NOLOCK) ON D.IDDepartamento = DE.IDDepartamento
  LEFT JOIN [RH].[tblSucursalEmpleado] SE WITH(NOLOCK)ON SE.IDEmpleado = E.IDEmpleado AND SE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and SE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' 
  LEFT JOIN [RH].[tblCatSucursales] S WITH(NOLOCK) ON SE.IDSucursal = S.IDSucursal
  LEFT JOIN [RH].[tblPuestoEmpleado] PE WITH(NOLOCK) ON PE.IDEmpleado = E.IDEmpleado AND PE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and PE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' 
  LEFT JOIN [RH].[tblCatPuestos] P WITH(NOLOCK) ON P.IDPuesto = PE.IDPuesto
  LEFT JOIN [RH].[tblClienteEmpleado] CE WITH(NOLOCK) ON CE.IDEmpleado = E.IDEmpleado AND CE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and CE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' 
  LEFT JOIN [RH].[tblCatClientes] C WITH(NOLOCK) ON C.IDCliente = CE.IDCliente '

Select @QueryFrom2 = '      
  LEFT JOIN [RH].[tblEmpresaEmpleado] EMPE WITH(NOLOCK) ON EMPE.IDEmpleado = E.IDEmpleado AND EMPE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and EMPE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''             
  LEFT JOIN [RH].[tblEmpresa] EMP WITH(NOLOCK) ON EMP.IdEmpresa = EMPE.IDEmpresa
  LEFT JOIN [RH].[tblCentroCostoEmpleado] CCE WITH(NOLOCK) ON CCE.IDEmpleado = E.IDEmpleado AND CCE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and CCE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatCentroCosto] CC WITH(NOLOCK) ON CC.IDCentroCosto = CCE.IDCentroCosto
  LEFT JOIN [RH].[tblAreaEmpleado] AE WITH(NOLOCK) ON AE.IDEmpleado = E.IDEmpleado AND AE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and AE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''         
  LEFT JOIN [RH].[tblCatArea] A WITH(NOLOCK) ON A.IDArea = AE.IDArea
  LEFT JOIN [RH].[tblDivisionEmpleado] DVE WITH(NOLOCK) ON DVE.IDEmpleado = E.IDEmpleado AND DVE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and DVE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatDivisiones] DV WITH(NOLOCK) ON DV.IDDivision = DVE.IDDivision
  LEFT JOIN [RH].[tblRegionEmpleado] RE WITH(NOLOCK) ON RE.IDEmpleado = E.IDEmpleado AND RE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and RE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatRegiones] R WITH(NOLOCK) ON R.IDRegion = RE.IDRegion
  LEFT JOIN [RH].[tblClasificacionCorporativaEmpleado] CPE WITH(NOLOCK) ON CPE.IDEmpleado = E.IDEmpleado AND CPE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and CPE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''            
  LEFT JOIN [RH].[tblCatClasificacionesCorporativas] CP WITH(NOLOCK) ON CP.IDClasificacionCorporativa = CPE.IDClasificacionCorporativa
  LEFT JOIN [RH].[tblRegPatronalEmpleado] RPE WITH(NOLOCK) ON RPE.IDEmpleado = E.IDEmpleado AND RPE.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and RPE.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatRegPatronal] RP WITH(NOLOCK)ON RP.IDRegPatronal = RPE.IDRegPatronal 
  LEFT JOIN [RH].[tblTipoNominaEmpleado] TipoNominaEmpleado WITH(NOLOCK) on e.IDEmpleado = TipoNominaEmpleado.IDEmpleado and TipoNominaEmpleado.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and TipoNominaEmpleado.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''            
  LEFT JOIN [Nomina].[tblCatTipoNomina] TipoNomina WITH(NOLOCK) on TipoNomina.IDTipoNomina = TipoNominaEmpleado.IDTipoNomina
  LEFT JOIN [RH].[tblRazonSocialEmpleado] RazonSocialEmpleado WITH(NOLOCK) on e.IDEmpleado = RazonSocialEmpleado.IDEmpleado and RazonSocialEmpleado.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and RazonSocialEmpleado.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''
  LEFT JOIN [RH].[tblCatRazonesSociales] RazonSocial WITH(NOLOCK)on RazonSocial.IDRazonSocial = RazonSocialEmpleado.IDRazonSocial            
  left join #tempContra contratos on contratos.IDEmpleado = e.IDEmpleado          
  LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) ON Prestaciones.IDEmpleado = E.IDEmpleado AND Prestaciones.FechaIni<= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and Prestaciones.FechaFin >= '''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''           
  JOIN #tempMovAfil m ON m.IDEmpleado = e.IDEmpleado
  LEFT JOIN [RH].[tblCatTiposPrestaciones] CatPrestaciones WITH(NOLOCK) ON Prestaciones.IDTipoPrestacion = CatPrestaciones.IDTipoPrestacion
  LEFT JOIN [RH].[tblTipoTrabajadorEmpleado] tipoTrabajadorEmpleado WITH(NOLOCK) ON tipoTrabajadorEmpleado.IDEmpleado = E.IDEmpleado
  LEFT JOIN [IMSS].[tblCatTipoTrabajador] catTipoTrabajador WITH(NOLOCK) ON tipoTrabajadorEmpleado.IDTipoTrabajador = catTipoTrabajador.IDTipoTrabajador
 '
 	        
SET @QueryWhere = N'            
  WHERE (E.ClaveEmpleado BETWEEN '''+@EmpleadoIni+''' AND '''+@EmpleadoFin+''' )  ' +             
   CASE WHEN @IDTipoNomina <> 0 THEN 'and ((TipoNomina.IDTipoNomina ='+ CAST(@IDTipoNomina as varchar(20))+'))' ELSE '' END +  
  'and (contratos.FechaFinContrato between '''+FORMAT(@FechaIni,'yyyy-MM-dd')+''' and '''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' or contratos.FechaFinContrato is null )'+ 
  -- 'and ( (M.FechaAlta<='''+FORMAT(@Fechafin,'yyyy-MM-dd')+''' and (M.FechaBaja>='''+FORMAT(@FechaIni,'yyyy-MM-dd')+''' or M.FechaBaja is null)) or (M.FechaReingreso<='''+FORMAT(@Fechafin,'yyyy-MM-dd')+'''))'+
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Empleados')						THEN ' and ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Empleados''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Departamentos')					THEN ' and ((D.IDDepartamento in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Departamentos''),'',''))))  ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Sucursales')						THEN ' and ((S.IDSucursal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Sucursales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Puestos')						THEN ' and ((P.IDPuesto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Puestos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Prestaciones')					THEN ' and ((Prestaciones.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Prestaciones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Clientes')						THEN ' and ((C.IDCliente in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Clientes''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'TipoContratacion')				THEN ' and ((contratos.IDTipoContrato in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''TipoContratacion''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RazonesSociales')				THEN ' and ((EMP.IdEmpresa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RazonesSociales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RegPatronales')					THEN ' and ((RP.IDRegPatronal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RegPatronales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Divisiones')						THEN ' and ((DV.IDDivision in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Divisiones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'CentrosCostos')					THEN ' and ((CC.IDCentroCosto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''CentrosCostos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Areas')					        THEN ' and ((AE.IDArea in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Areas''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Regiones')					    THEN ' and ((RE.IDRegion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Regiones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'CentrosCostos')				    THEN ' and ((CC.IDCentroCosto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''CentrosCostos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'ClasificacionesCorporativas')	THEN ' and ((CP.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''ClasificacionesCorporativas''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'NombreClaveFilter')				THEN ' and ((COALESCE(E.ClaveEmpleado,'''')+'' ''+ COALESCE(E.Paterno,'''')+'' ''+COALESCE(E.Materno,'''')+'', ''+COALESCE(E.Nombre,'''')+'' ''+COALESCE(E.SegundoNombre,'''')) like ''%''+(Select top 1 Value from #tempFiltros where Catalogo = ''NombreClaveFilter'')+''%'')' ELSE '' END 
   --+ ' order by e.ClaveEmpleado asc' 

exec (@querySelect  + @QuerySelect2 + @QueryFrom +@queryFrom2 + @QueryWhere)

END
GO
