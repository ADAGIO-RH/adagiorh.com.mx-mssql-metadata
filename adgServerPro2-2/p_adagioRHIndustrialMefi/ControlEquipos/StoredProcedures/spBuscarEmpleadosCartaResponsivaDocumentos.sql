USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Genera toda la información necesaria para llenar las cartas responsivas
** Autor			: Javier Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-04-26
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   PROCEDURE [ControlEquipos].[spBuscarEmpleadosCartaResponsivaDocumentos]
( 
	@IDEmpleado INT
	, @FechaIni DATE = '1900-01-01'
	, @Fechafin DATE = '9999-12-31'
	, @IDContratoEmpleado INT = 0
	, @IDUsuario INT = 0
)          
AS          
BEGIN          

	SET QUERY_GOVERNOR_COST_LIMIT 0;
	
	DECLARE  
		@IDIdioma						VARCHAR(5)
		, @IdiomaSQL					VARCHAR(100) = NULL
		, @empleados					[RH].[dtEmpleados]   
		, @dtFiltros					[Nomina].[dtfiltrosRH]
		, @CustomeProcedure				VARCHAR(MAX)
		, @SPCustomContratosDocumentos	VARCHAR(MAX)
		, @IDReferencia					INT
		;

	SELECT top 1 @CustomeProcedure = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'SPCamposExtraContratosDocumentos'
	SELECT top 1 @SPCustomContratosDocumentos = Valor FROM App.tblConfiguracionesGenerales WHERE IDConfiguracion = 'SPCustomContratosDocumentos'

	IF(ISNULL(@SPCustomContratosDocumentos,'') <> '')
	BEGIN
		exec sp_executesql N'exec @miSP @IDEmpleado ,@FechaIni ,@Fechafin ,@IDContratoEmpleado ,@IDUsuario'                   
			,N' @IDEmpleado int        
			,@FechaIni date 
			,@Fechafin date     
			,@IDContratoEmpleado  int 
			,@IDUsuario int      
			,@miSP varchar(MAX)',                          
				@IDEmpleado = @IDEmpleado      
			,@FechaIni = @FechaIni          
			,@Fechafin = @Fechafin      
			,@IDContratoEmpleado = @IDContratoEmpleado
			,@IDUsuario = @IDUsuario             
			,@miSP = @SPCustomContratosDocumentos ; 
		RETURN;
	END

	SET DATEFIRST 7;

	select 
		@IDIdioma = ISNULL(documentos.IDIdioma, 'es-MX')
		, @IDReferencia = ContratoEmpleado.IDReferencia
	from [RH].[tblContratoEmpleado] ContratoEmpleado WITH(NOLOCK)              
		inner JOIN [RH].[tblCatDocumentos] documentos WITH(NOLOCK)              
			ON ContratoEmpleado.IDDocumento = documentos.IDDocumento          
				--and documentos.EsContrato = 1               
    where ContratoEmpleado.IDContratoEmpleado = @IDContratoEmpleado    

	select @IdiomaSQL = [SQL]
	from App.tblIdiomas  with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end

	SET LANGUAGE @IdiomaSQL; 
	
	if OBJECT_ID('tempdb..#tempMovAfil') is not null drop table #tempMovAfil    
	IF OBJECT_ID('tempdb..#TempEmpleado') IS NOT NULL DROP TABLE #TempEmpleado
	IF OBJECT_ID('tempdb..#TempExtra') IS NOT NULL DROP TABLE #TempExtra
	IF OBJECT_ID('tempdb..#tempFamilia') IS NOT NULL DROP TABLE #tempFamilia
	IF OBJECT_ID('tempdb..#TempBeneficiario') IS NOT NULL DROP TABLE #TempBeneficiario
	IF OBJECT_ID('tempdb..#TempTurnoEmpleado') IS NOT NULL DROP TABLE #TempTurnoEmpleado
	IF OBJECT_ID('tempdb..#tempContactEmpleado') IS NOT NULL DROP TABLE #tempContactEmpleado
	IF OBJECT_ID('tempdb..#tempCustomEmpleado') IS NOT NULL DROP TABLE #tempCustomEmpleado
	if object_id('tempdb..#tempContra') is not null drop table #tempContra    
		
	IF OBJECT_ID('tempdb..#tempDetallesArticulos') IS NOT NULL DROP TABLE #tempDetallesArticulos;
	IF OBJECT_ID('tempdb.dbo.#tempArticulo') IS NOT NULL DROP TABLE #tempArticulo
	IF OBJECT_ID('tempdb.dbo.#tempArticuloProps') IS NOT NULL DROP TABLE #tempArticuloProps
	
	IF OBJECT_ID('tempdb.dbo.##Extra') IS NOT NULL DROP TABLE ##Extra
	IF OBJECT_ID('tempdb.dbo.##TempFamiliares') IS NOT NULL DROP TABLE ##TempFamiliares  
	IF OBJECT_ID('tempdb.dbo.##TempBeneficiarios') IS NOT NULL DROP TABLE ##TempBeneficiarios 
	IF OBJECT_ID('tempdb.dbo.##tempContactoEmpleado') IS NOT NULL DROP TABLE ##tempContactoEmpleado 
	IF OBJECT_ID('tempdb.dbo.##tempCustomeEmpleado') IS NOT NULL DROP TABLE ##tempCustomeEmpleado

	insert into @dtFiltros(Catalogo,Value)
	values('Empleados',cast( @IDEmpleado as varchar(20)))

	insert into @empleados                  
	exec [RH].[spBuscarEmpleados] @FechaIni= @FechaIni,@Fechafin= @FechaFin, @dtFiltros = @dtFiltros  ,@IDUsuario=@IDUsuario

	if not exists (select top 1 1 from @empleados)
	begin
		insert into @empleados                  
		exec [RH].[spBuscarEmpleadosMaster]  @dtFiltros = @dtFiltros  ,@IDUsuario=@IDUsuario
	end

  
	select  ContratoEmpleado.IDContratoEmpleado
		,ContratoEmpleado.IDEmpleado
		,Isnull(documentos.IDDocumento,0) as IDDocumento             
		,UPPER(Isnull(documentos.Descripcion,'')) as Documento             
		,Isnull(tipoContrato.IDTipoContrato,0) as IDTipoContrato             
		,Isnull(tipoContrato.Codigo,'00') as TipoContratoCodigo             
		,UPPER(Isnull(tipoContrato.Descripcion,'')) as TipoContrato            
		,isnull(ContratoEmpleado.FechaIni,'1900-01-01') as FechaIniContrato          
		,isnull(ContratoEmpleado.FechaFin,'1900-01-01') as FechaFinContrato 
		,isnull(ContratoEmpleado.Duracion,0) as Duracion
	into #tempContra
	from [RH].[tblContratoEmpleado] ContratoEmpleado WITH(NOLOCK)              
		inner JOIN [RH].[tblCatDocumentos] documentos WITH(NOLOCK) ON ContratoEmpleado.IDDocumento = documentos.IDDocumento          
			and documentos.EsContrato = 1              
		inner JOIN [sat].[tblCatTiposContrato] tipoContrato WITH(NOLOCK) ON ContratoEmpleado.IDTipoContrato = tipoContrato.IDTipoContrato    
    where ContratoEmpleado.IDEmpleado = @IDEmpleado    

	Select top 1 e.IDEmpleado, t.IDTurno, t.Descripcion as Turno
	into #TempTurnoEmpleado
    from @empleados e
		inner join Asistencia.tblHorariosEmpleados he on e.IDEmpleado = he.IDEmpleado	
			and he.Fecha Between @FechaIni and @fechaFin
		inner join Asistencia.tblCatHorarios h on he.IDHorario = he.IDHorario
		inner join Asistencia.tblCatTurnos t on t.IDTurno = h.IDTurno
	order by he.Fecha desc

	select IDEmpleado, FechaAlta, FechaBaja,            
      case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso            
      ,IDMovAfiliatorio    
	into #tempMovAfil            
	from (select distinct tm.IDEmpleado,            
        case when(IDEmpleado is not null) then (select top 1 Fecha             
                 from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
                 where mAlta.IDEmpleado=tm.IDEmpleado and c.Codigo='A'              
                 Order By mAlta.Fecha Desc , c.Prioridad DESC ) end as FechaAlta,            
        case when (IDEmpleado is not null) then (select top 1 Fecha             
                 from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
                 where mBaja.IDEmpleado=tm.IDEmpleado and c.Codigo='B'              
                and mBaja.Fecha <= @FechaFin             
			order by mBaja.Fecha desc, C.Prioridad desc) end as FechaBaja,            
        case when (IDEmpleado is not null) then (select top 1 Fecha             
                 from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
                 where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'              
                and mReingreso.Fecha <= @FechaFin             
                order by mReingreso.Fecha desc, C.Prioridad desc) end as FechaReingreso              
        ,(Select top 1 mSalario.IDMovAfiliatorio from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
                 where mSalario.IDEmpleado=tm.IDEmpleado and c.Codigo in ('A','M','R')             
                 order by mSalario.Fecha desc ) as IDMovAfiliatorio                                             
	from [IMSS].[tblMovAfiliatorios] tm   WITH(NOLOCK)) mm    
	where mm.IDEmpleado = @IDEmpleado

	select 
   		E.IDEmpleado          
		,UPPER(E.ClaveEmpleado)AS ClaveEmpleado          
		,UPPER(E.RFC) AS RFC          
		,UPPER(E.CURP) AS CURP          
		,UPPER(E.IMSS) AS IMSS          
		,UPPER(E.Nombre) AS Nombre          
		,UPPER(E.SegundoNombre) AS SegundoNombre           
		,UPPER(E.Paterno) AS Paterno          
		,UPPER(E.Materno) AS Materno          
	--   ,UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) AS NOMBRECOMPLETO          
		,substring(UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+' '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,49 ) AS NombreCompleto          
		,ISNULL(E.IDLocalidadNacimiento,0) as IDLocalidadNacimiento          
		,UPPER(ISNULL(E.LocalidadNacimiento,'')) AS LocalidadNacimiento          
		,ISNULL(E.IDMunicipioNacimiento,0) as IDMunicipioNacimiento          
		,UPPER(ISNULL(E.MunicipioNacimiento,'')) AS MunicipioNacimiento          
		,ISNULL(E.IDEstadoNacimiento,0) as IDEstadoNacimiento          
		,UPPER(ISNULL(E.EstadoNacimiento,'')) AS EstadoNacimiento          
		,ISNULL(E.IDPaisNacimiento,0) as IDPaisNacimiento          
		,UPPER(ISNULL(E.PaisNacimiento,'')) AS PaisNacimiento 
		,CASE 
			WHEN E.EstadoNacimiento = 'EXTRANJERO' THEN 'extranjero (a)'  
			WHEN E.PaisNacimiento = 'MEXICO' THEN 'mexicano (a)'  
			WHEN E.PaisNacimiento = 'MÉXICO' THEN 'mexicano (a)'
			-- WHEN E.PaisNacimiento = 'ITALIA' THEN 'ITALIANO (A)'  
			-- WHEN E.PaisNacimiento = 'ESPAÑA' THEN 'ESPAÑOL (A)'  
			ELSE
				'extranjero (a)'
			END
		AS Nacionalidad 

		,convert(varchar(10),isnull(E.FechaNacimiento,'1900-01-01'),103)as FechaNacimiento     
		,Utilerias.fnDateToStringByFormat(E.FechaNacimiento,'FL',@IdiomaSQL) as FL_FechaNacimiento
		,Utilerias.fnDateToStringByFormat(E.FechaNacimiento,'FM',@IdiomaSQL) as FM_FechaNacimiento
		,UPPER(cast(DATEPART(day,isnull(E.FechaNacimiento,'1900-01-01')) as varchar(max))+'/'+ (cast(datepart(MONTH,isnull(E.FechaNacimiento,'1900-01-01')) as varchar)) +'/'+ cast(DATEPART(YEAR,isnull(E.FechaNacimiento,'1900-01-01'))as varchar) )as FC_FechaNacimiento

		--,DATEDIFF(YEAR,isnull(E.FechaNacimiento,'1900-01-01'),@FechaIni) as Edad 
		,CONVERT (int, DATEDIFF(DAY,isnull(E.FechaNacimiento,'1900-01-01'),@FechaIni) / 365.25 ) AS Edad
		,ISNULL(E.IDEstadoCiviL,0) AS IDEstadoCivil          
		,UPPER(ISNULL(E.EstadoCivil,'')) AS EstadoCivil          
		,E.Sexo  AS Sexo          
		,isnull(E.IDEscolaridad,0) as IDEscolaridad          
		,UPPER(isnull(E.Escolaridad,'')) as Escolaridad          
		,UPPER(E.DescripcionEscolaridad) AS DescripcionEscolaridad          
		,ISNULL(E.IDInstitucion,0) as IDInstitucion          
		,UPPER(isnull(E.Institucion,'')) as Institucion          
		,ISNULL(E.IDProbatorio,0) as IDProbatorio          
		,UPPER(isnull(e.Probatorio,'')) as Probatorio          
		,isnull(E.FechaPrimerIngreso,'1900-01-01') as FechaPrimerIngreso      

		,Utilerias.fnDateToStringByFormat(E.FechaPrimerIngreso,'FL',@IdiomaSQL) as FL_FechaPrimerIngreso
		,Utilerias.fnDateToStringByFormat(E.FechaPrimerIngreso,'FM',@IdiomaSQL) as FM_FechaPrimerIngreso
		,UPPER(cast(DATEPART(day,isnull(E.FechaPrimerIngreso,'1900-01-01')) as varchar(max))+'/'+ (cast(datepart(MONTH,isnull(E.FechaPrimerIngreso,'1900-01-01')) as varchar)) +'/'+ cast(DATEPART(YEAR,isnull(E.FechaPrimerIngreso,'1900-01-01'))as varchar) )as FC_FechaPrimerIngreso

		--,isnull(E.FechaIngreso,'1900-01-01') as FechaIngreso   
		,Utilerias.fnDateToStringByFormat(E.FechaIngreso,'FC',@IdiomaSQL) as FechaIngreso
		,Utilerias.fnDateToStringByFormat(E.FechaIngreso,'FL',@IdiomaSQL) as FL_FechaIngreso
		,Utilerias.fnDateToStringByFormat(E.FechaIngreso,'FM',@IdiomaSQL) as FM_FechaIngreso
	
		,UPPER(cast(DATEPART(day,isnull(E.FechaIngreso,'1900-01-01')) as varchar(max))+'/'+ (cast(datepart(MONTH,isnull(E.FechaIngreso,'1900-01-01')) as varchar)) +'/'+ cast(DATEPART(YEAR,isnull(E.FechaIngreso,'1900-01-01'))as varchar) )as FC_FechaIngreso
 
		,CASE WHEN M.FechaReingreso >= E.FechaAntiguedad THEN Utilerias.fnDateToStringByFormat( ISNULL(M.FechaReingreso,'1900-01-01') , 'FC',@IdiomaSQL )            
		ELSE Utilerias.fnDateToStringByFormat( E.FechaAntiguedad , 'FC',@IdiomaSQL )        
		END  as FechaAntiguedad  

		,Utilerias.fnDateToStringByFormat(CASE WHEN M.FechaReingreso >= E.FechaAntiguedad THEN ISNULL(M.FechaReingreso,'1900-01-01')  ELSE E.FechaAntiguedad END,'FL',@IdiomaSQL) as FL_FechaAntiguedad
		,Utilerias.fnDateToStringByFormat(CASE WHEN M.FechaReingreso >= E.FechaAntiguedad THEN ISNULL(M.FechaReingreso,'1900-01-01')  ELSE E.FechaAntiguedad END,'FM',@IdiomaSQL) as FM_FechaAntiguedad
	
		,UPPER(cast(DATEPART(day,isnull(CASE WHEN M.FechaReingreso >= E.FechaAntiguedad THEN ISNULL(M.FechaReingreso,'1900-01-01') ELSE E.FechaAntiguedad END,'1900-01-01')) as varchar(max))
		+'/'+ (cast(datepart(MONTH,isnull(CASE WHEN M.FechaReingreso >= E.FechaAntiguedad THEN ISNULL(M.FechaReingreso,'1900-01-01') ELSE E.FechaAntiguedad END,'1900-01-01')) as varchar)) 
		+'/'+ cast(DATEPART(YEAR,isnull(CASE WHEN M.FechaReingreso >= E.FechaAntiguedad THEN ISNULL(M.FechaReingreso,'1900-01-01') ELSE E.FechaAntiguedad END,'1900-01-01'))as varchar) )as FC_FechaAntiguedad
		
		,Utilerias.fnDateToStringByFormat( ISNULL(M.FechaBaja,'1900-01-01') , 'FC',@IdiomaSQL )  as FechaBaja  

		,Utilerias.fnDateToStringByFormat(ISNULL(M.FechaBaja,'1900-01-01'),'FL',@IdiomaSQL) as FL_FechaBaja
		,Utilerias.fnDateToStringByFormat(ISNULL(M.FechaBaja,'1900-01-01'),'FM',@IdiomaSQL) as FM_FechaBaja
	
		,UPPER(cast(DATEPART(day,isnull(M.FechaBaja,'1900-01-01')) as varchar(max))
		+'/'+ (cast(datepart(MONTH,isnull(M.FechaBaja,'1900-01-01')) as varchar)) 
		+'/'+ cast(DATEPART(YEAR,isnull(M.FechaBaja,'1900-01-01'))as varchar) )as FC_FechaBaja
		,MovRaz.Descripcion as RazonMovimiento
   		,MovRazBaja.Descripcion as RazonMovimientoBaja

   	
		,ISNULL(cast(getdate() as date),'1900-01-01') as FechaHoy  

		,Utilerias.fnDateToStringByFormat(ISNULL(cast(getdate() as date),'1900-01-01'),'FL',@IdiomaSQL) as FL_FechaHoy
		,Utilerias.fnDateToStringByFormat(ISNULL(cast(getdate() as date),'1900-01-01'),'FM',@IdiomaSQL) as FM_FechaHoy
	
		,UPPER(cast(DATEPART(day,isnull(cast(getdate() as date),'1900-01-01')) as varchar(max))
		+'/'+ (cast(datepart(MONTH,isnull(cast(getdate() as date),'1900-01-01')) as varchar)) 
		+'/'+ cast(DATEPART(YEAR,isnull(cast(getdate() as date),'1900-01-01'))as varchar) )as FC_FechaHoy

		,isnull(E.Sindicalizado,0) as Sindicalizado          
		,ISNULL(E.IDJornadaLaboral,0)AS IDJornadaLaboral          
		,UPPER(ISNULL(e.JornadaLaboral,'')) AS JornadaLaboral          
		,UPPER(E.UMF) AS UMF          
		,UPPER(E.CuentaContable) AS CuentaContable          
		,isnull(E.IDTipoRegimen,0) AS IDTipoRegimen          
		,UPPER(ISNULL(e.TipoRegimen,'')) AS TipoRegimen          
		,ISNULL(E.IDPreferencia,0) AS IDPreferencia          
		,isnull(e.IDDepartamento,0) as  IDDepartamento   
		,UPPER(isnull(E.Departamento,'')) as Departamento        
		
		------
		,isnull(E.IDSucursal,0) as  SucursalIDSucursal          
		,UPPER(isnull(E.Sucursal,'')) as Sucursal  
		,UPPER(isnull(S.Codigo,'')) as SucursalCodigo  
		,UPPER(isnull(S.CuentaContable,'')) as SucursalCuentaContable  
		,UPPER(isnull(S.Calle,'')) as SucursalCalle  
		,UPPER(isnull(S.Interior,'')) as SucursalInterior  
		,UPPER(isnull(S.Exterior,'')) as SucursalExterior  
		,UPPER(isnull(SucursalCodigoPostal.CodigoPostal,'')) as CodigoPostal  
		,UPPER(isnull(SucursalColonia.NombreAsentamiento,'')) as SucursalColonia  
		,UPPER(isnull(SucursalMunicipio.Descripcion,'')) as SucursalMunicipio  
		,UPPER(isnull(SucursalEstados.NombreEstado,'')) as SucursalEstado  
		,UPPER(isnull(SucursalPaises.Descripcion,'')) as SucursalPais  
		,UPPER(isnull(s.Telefono,'')) as SucursalTelefono  
		,UPPER(isnull(s.Responsable,'')) as SucursalResponsable  
		,UPPER(isnull(s.Email,'')) as SucursalEmail  
		,UPPER(isnull(s.ClaveEstablecimiento,'')) as SucursalClaveEstablecimiento         

		--------

		,isnull(E.IDPuesto,0) as  IDPuesto          
		,UPPER(isnull(E.Puesto,'')) as Puesto  
		,isnull(PuestoEmpleado.DescripcionPuesto ,'') as DescripcionPuesto          
		,isnull(E.IDCliente,0) as  IDCliente          
		,UPPER(isnull(E.Cliente,'')) as Cliente    

		---------
		,isnull(E.IdEmpresa,0) as  IDEmpresa          
		,UPPER(isnull(EMP.NombreComercial,'')) as Empresa    
		,UPPER(isnull(EMP.RFC,'')) as EmpresaRFC         
		,UPPER(isnull(EMP.RegInfonavit,'')) as EmpresaRegInfonavit         
		,UPPER(isnull(EMP.RegFonacot,'')) as EmpresaRegFonacot        
		,UPPER(isnull(EMP.RegSIEM,'')) as EmpresaRegSIEM        
		,UPPER(isnull(EMP.Calle,'')) as EmpresaCalle        
		,UPPER(isnull(EMP.Exterior,'')) as EmpresaExterior        
		,UPPER(isnull(EMP.Interior,'')) as EmpresaInterior        
		,UPPER(isnull(EmpresalCodigoPostal.CodigoPostal,'')) as EmpresaCodigoPostal       
		,UPPER(isnull(EmpresaColonia.NombreAsentamiento,'')) as EmpresaColonia        
		,UPPER(isnull(EmpresaMunicipio.Descripcion,'')) as EmpresaMunicipio        
		,UPPER(isnull(EmpresaEstados.NombreEstado,'')) as EmpresaEstado        
		,UPPER(isnull(EmpresaPaises.Descripcion,'')) as EmpresaPais        
		---------    
		,isnull(E.IDCentroCosto,0) as  IDCentroCosto          
		,UPPER(isnull(E.CentroCosto,'')) as CentroCosto          
		,isnull(E.IDArea,0) as  IDArea          
		,UPPER(isnull(E.Area,'')) as Area          
		,isnull(E.IDDivision,0) as  IDDivision          
		,UPPER(isnull(E.Division,'')) as Division          
		,isnull(E.IDRegion,0) as  IDRegion          
		,UPPER(isnull(E.Region,'')) as Region          
		,isnull(E.IDClasificacionCorporativa,0) as  IDClasificacionCorporativa          
		,UPPER(isnull(E.ClasificacionCorporativa,'')) as ClasificacionCorporativa 
		--------
		 ,isnull(E.IDRegPatronal,0) as  IDRegPatronal          
		,UPPER(isnull(E.RegPatronal,'')) as RegPatronal    
		,UPPER(isnull(RP.RegistroPatronal,'')) as RegPatronalRegistro    
		,UPPER(isnull(RP.ActividadEconomica,'')) as RegPatronalActividadEconomica    
		,UPPER(isnull(RP.RepresentanteLegal,'PRESENTANTE LEGAL')) as RegPatronalRepresentanteLegal  
		,UPPER(isnull(RP.OcupacionRepLegal,'')) as RegPatronalOcupacionRepLegal 
		,UPPER(isnull(RP.Calle,'')) as RegPatronalCalle        
		,UPPER(isnull(RP.Exterior,'')) as RegPatronalExterior        
		,UPPER(isnull(RP.Interior,'')) as RegPatronalInterior        
		,UPPER(isnull(RP.Telefono,'')) as RegPatronalTelefono       
		,UPPER(isnull(RegistroPatronalCodigoPostal.CodigoPostal,'')) as RegistroPatronalCodigoPostal        
		,UPPER(isnull(RegistroPatronalColonia.NombreAsentamiento,'')) as RegistroPatronalColonia        
		,UPPER(isnull(RegistroPatronalMunicipio.Descripcion,'')) as RegistroPatronalMunicipio        
		,UPPER(isnull(RegistroPatronalEstados.NombreEstado,'')) as RegistroPatronalEstados        
		,UPPER(isnull(RegistroPatronalPaises.Descripcion,'')) as RegistroPatronalPaises  
		--------

		,isnull(e.IDTipoNomina,0) as  IDTipoNomina          
		,UPPER(isnull(E.TipoNomina,'')) as TipoNomina   
		--SALARIO DIARIO       
		,ISNULL(MOV.SalarioDiario,0.00) as SalarioDiario  
		,[Utilerias].[fnConvertNumerosALetras](cast( ISNULL(MOV.SalarioDiario,0.00) as varchar(max))) L_SalarioDiario    
		,FORMAT(ISNULL(MOV.SalarioDiario,0.00),'N') as F_SalarioDiario 
		,case when ISNULL(MOV.SalarioDiario,0.00)> 0 then ISNULL(MOV.SalarioDiario,0.00) * 30 else 0.00 end as SalarioDiarioMensual   
		,[Utilerias].[fnConvertNumerosALetras](cast( case when ISNULL(MOV.SalarioDiario,0.00) > 0 then ISNULL(MOV.SalarioDiario,0.00) * 30 else 0.00 end as varchar(max))) L_SalarioDiarioMensual 
		,FORMAT(case when ISNULL(MOV.SalarioDiario,0.00)> 0 then ISNULL(MOV.SalarioDiario,0.00) * 30 else 0.00 end,'N') as F_SalarioDiarioMensual 
		
		--SALARIO REAL    
		,ISNULL(MOV.SalarioDiarioReal,0.00) as SalarioDiarioReal  
		,[Utilerias].[fnConvertNumerosALetras](cast( ISNULL(MOV.SalarioDiarioReal,0.00) as varchar(max))) L_SalarioDiarioReal     
		,FORMAT(ISNULL(MOV.SalarioDiarioReal,0.00),'N') as F_SalarioDiarioReal 
		,case when ISNULL(MOV.SalarioDiarioReal,0.00)> 0 then ISNULL(MOV.SalarioDiarioReal,0.00) * 30 else 0.00 end  as SalarioDiarioRealMensual   
		,[Utilerias].[fnConvertNumerosALetras](cast( case when ISNULL(MOV.SalarioDiarioReal,0.00)> 0 then ISNULL(MOV.SalarioDiarioReal,0.00) * 30 else 0.00 end as varchar(max))) L_SalarioDiarioRealMensual  
		,FORMAT(case when ISNULL(MOV.SalarioDiarioReal,0.00)> 0 then ISNULL(MOV.SalarioDiarioReal,0.00) * 30 else 0.00 end,'N') as F_SalarioDiarioRealMensual 

		--SALARIO INTEGRADO  
		,ISNULL(MOV.SalarioIntegrado,0.00)as SalarioIntegrado 
		,[Utilerias].[fnConvertNumerosALetras](cast( ISNULL(MOV.SalarioIntegrado,0.00) as varchar(max))) L_SalarioIntegrado 
		,FORMAT(ISNULL(MOV.SalarioIntegrado,0.00),'N') as F_SalarioIntegrado 
		,case when ISNULL(MOV.SalarioIntegrado,0.00)> 0 then ISNULL(MOV.SalarioIntegrado,0.00) * 30 else 0.00 end  as SalarioIntegradoMensual 
		,[Utilerias].[fnConvertNumerosALetras](cast( case when ISNULL(MOV.SalarioIntegrado,0.00)> 0 then ISNULL(MOV.SalarioIntegrado,0.00) * 30 else 0.00 end as varchar(max))) L_SalarioIntegradoMensual 
		,FORMAT(case when ISNULL(MOV.SalarioIntegrado,0.00)> 0 then ISNULL(MOV.SalarioIntegrado,0.00) * 30 else 0.00 end,'N') as F_SalarioIntegradoMensual 

		--SALARIO VARIABLE
		,ISNULL(MOV.SalarioVariable,0.00)as SalarioVariable     
		,[Utilerias].[fnConvertNumerosALetras](cast( ISNULL(MOV.SalarioVariable,0.00) as varchar(max))) L_SalarioVariable   
		,FORMAT(ISNULL(MOV.SalarioVariable,0.00),'N') as F_SalarioVariable 
		,case when ISNULL(MOV.SalarioVariable,0.00)> 0 then ISNULL(MOV.SalarioVariable,0.00) * 30 else 0.00 end  as SalarioVariableMensual
        ,[Utilerias].[fnConvertNumerosALetras](cast( case when ISNULL(MOV.SalarioVariable,0.00)> 0 then ISNULL(MOV.SalarioVariable,0.00) * 30 else 0.00 end as varchar(max))) L_SalarioVariableMensual  
		,FORMAT(case when ISNULL(MOV.SalarioVariable,0.00)> 0 then ISNULL(MOV.SalarioVariable,0.00) * 30 else 0.00 end,'N') as F_SalarioVariableMensual 
		---------
		,ISNULL(E.IDTipoPrestacion,0) as IDTipoPrestacion  
		,ISNULL(TipoPrestaciones.Descripcion,'') as TipoPrestacion  
		------
		,ISNULL(E.IDRazonSocial,0) as  IDRazonSocial          
		,UPPER(isnull(E.RazonSocial,'')) as RazonSocial          
		,UPPER(isnull(RazonSocial.RFC,'')) as RazonSocialRFC          
		,UPPER(isnull(RazonSocial.Calle,'')) as RazonSocialCalle         
		,UPPER(isnull(RazonSocial.Exterior,'')) as RazonSocialExterior         
		,UPPER(isnull(RazonSocial.Interior,'')) as RazonSocialInterior         
		,UPPER(isnull(RazonSocialColonia.NombreAsentamiento,'')) as RazonSocialColonia         
		,UPPER(isnull(RazonSocialMunicipio.Descripcion,'')) as RazonSocialMunicipio         
		,UPPER(isnull(RazonSocialEstados.NombreEstado,'')) as RazonSocialEstados         
		,UPPER(isnull(RazonSocialPaises.Descripcion,'')) as RazonSocialPais         
		,UPPER(isnull(RazonSocialCodigoPostal.CodigoPostal,'')) as RazonSocialCodigoPostal  
		--------
		,ISNULL(E.IDAfore,0) as  IDAfore          
		,UPPER(ISNULL(E.Afore,'')) as Afore          
		-------      
		,E.Vigente
		-------
		,NULL as [ClaveNombreCompleto]    
		,Isnull(E.PermiteChecar,0) as  PermiteChecar         
		,Isnull(E.RequiereChecar,0) as  RequiereChecar         
		,Isnull(E.PagarTiempoExtra,0) as  PagarTiempoExtra         
		,Isnull(E.PagarPrimaDominical,0) as  PagarPrimaDominical         
		,Isnull(E.PagarDescansoLaborado,0) as  PagarDescansoLaborado         
		,Isnull(E.PagarFestivoLaborado,0) as  PagarFestivoLaborado   
		-------------------------------   
		,Isnull(ContratoEmpleado.IDDocumento,0) as IDDocumento         
		,UPPER(Isnull(E.Documento,'')) as Documento         
		,Isnull(ContratoEmpleado.IDTipoContrato,0) as IDTipoContrato         
		,UPPER(Isnull(ContratoEmpleado.TipoContrato,'')) as TipoContrato   
		,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01') as FechaIniContrato      
		,Utilerias.fnDateToStringByFormat(ContratoEmpleado.FechaIniContrato,'FL',@IdiomaSQL) as FL_FechaIniContrato
		,Utilerias.fnDateToStringByFormat(ContratoEmpleado.FechaIniContrato,'FM',@IdiomaSQL) as FM_FechaIniContrato
		,UPPER(cast(DATEPART(day,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01')) as varchar(max))+'/'+ (cast(datepart(MONTH,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01')) as varchar)) +'/'+ cast(DATEPART(YEAR,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01'))as varchar) )as FC_FechaIniContrato
   
		, case when ContratoEmpleado.TipoContratoCodigo = '01' THEN isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01') ELSE dateadd(DAY,ISNULL(ContratoEmpleado.Duracion,0)-1,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01')) END as FechaFinContrato      
		,Utilerias.fnDateToStringByFormat(case when ContratoEmpleado.TipoContratoCodigo = '01' THEN isnull(ContratoEmpleado.FechaFinContrato,'1900-01-01') ELSE dateadd(DAY,ISNULL(ContratoEmpleado.Duracion,0)-1,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01'))END,'FL',@IdiomaSQL) as FL_FechaFinContrato
		,Utilerias.fnDateToStringByFormat(case when ContratoEmpleado.TipoContratoCodigo = '01' THEN isnull(ContratoEmpleado.FechaFinContrato,'1900-01-01') ELSE dateadd(DAY,ISNULL(ContratoEmpleado.Duracion,0)-1 ,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01'))END,'FM',@IdiomaSQL) as FM_FechaFinContrato
		
		,UPPER(cast(DATEPART(day,isnull(case when ContratoEmpleado.TipoContratoCodigo = '01' THEN isnull(ContratoEmpleado.FechaFinContrato,'1900-01-01') ELSE dateadd(DAY,ISNULL(ContratoEmpleado.Duracion,0)-1,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01'))END,'1900-01-01')) as varchar(max))
		+'/'+ (cast(datepart(MONTH,isnull(case when ContratoEmpleado.TipoContratoCodigo = '01' THEN isnull(ContratoEmpleado.FechaFinContrato,'1900-01-01') ELSE dateadd(DAY,ISNULL(ContratoEmpleado.Duracion,0)-1,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01'))END,'1900-01-01')) as varchar)) 
		+'/'+ cast(DATEPART(YEAR,isnull(case when ContratoEmpleado.TipoContratoCodigo = '01' THEN isnull(ContratoEmpleado.FechaFinContrato,'1900-01-01') ELSE dateadd(DAY,ISNULL(ContratoEmpleado.Duracion,0)-1,isnull(ContratoEmpleado.FechaIniContrato,'1900-01-01'))END,'1900-01-01'))as varchar) )as FC_FechaFinContrato
	   ,isnull(ContratoEmpleado.Duracion,0) as DuracionContrato   
	   ----
	      ,UPPER(Isnull(DireccionEmpleado.Calle,'')) as DireccionEmpleadoCalle
	   ,UPPER(Isnull(DireccionEmpleado.Exterior,'')) as DireccionEmpleadoExterior
	   ,UPPER(Isnull(DireccionEmpleado.Interior,'')) as DireccionEmpleadoInterior
	   ,UPPER(Isnull(CP.CodigoPostal,DireccionEmpleado.CodigoPostal)) as DireccionEmpleadoCodigoPostal
	   ,UPPER(Isnull(Colonias.NombreAsentamiento,DireccionEmpleado.Colonia)) as DireccionEmpleadoColonia
	   ,UPPER(Isnull(Municipios.Descripcion,DireccionEmpleado.Municipio)) as DireccionEmpleadoMunicipio
	   ,UPPER(Isnull(Estados.NombreEstado,DireccionEmpleado.Estado)) as DireccionEmpleadoEstado
	   ,UPPER(Isnull(Localidades.Descripcion,DireccionEmpleado.Localidad)) as DireccionEmpleadoLocalidad 
	   ,UPPER(Isnull(DireccionEmpleadoPais.Descripcion,DireccionEmpleadoPais.Descripcion)) as DireccionEmpleadoPais
	   ---- 
	  , ISNULL(TurnoEmpleado.IDTurno,0) as IDTurno
	  , UPPER(ISNULL(Turnoempleado.Turno,'')) as Turno 
	  -----
	  ,Utilerias.fnDateToStringByFormat( Documento.FechaIni, 'FC',@IdiomaSQL ) as DocumentoFechaIni
	  ,Utilerias.fnDateToStringByFormat( Documento.FechaFin, 'FC',@IdiomaSQL ) as DocumentoFechaFin
	  ,Utilerias.fnDateToStringByFormat( Documento.FechaGeneracion , 'FC',@IdiomaSQL ) as DocumentoFechaGeneracion
	  ,Utilerias.fnDateToStringByFormat( Documento.FechaIni,'FL',@IdiomaSQL) as FL_DocumentoFechaIni
      ,Utilerias.fnDateToStringByFormat (Documento.FechaIni,'FM',@IdiomaSQL) as FM_DocumentoFechaIni
	into #TempEmpleado 
	from @empleados E
		left join #tempMovAfil M on E.IDEmpleado = E.IDEmpleado
		LEFT JOIN [IMSS].[tblMovAfiliatorios] MOV WITH(NOLOCK) ON M.IDMovAfiliatorio = MOV.IDMovAfiliatorio 
		LEFT JOIN [IMSS].[tblCatRazonesMovAfiliatorios]	MovRaz on MOV.IDRazonMovimiento = MovRaz.IDRazonMovimiento
		LEFT JOIN [IMSS].[tblMovAfiliatorios] MOVBaja WITH(NOLOCK) ON M.IDEmpleado = MOVBaja.IDEmpleado 
			and m.FechaBaja = MOVBaja.Fecha
		LEFT JOIN [IMSS].[tblCatRazonesMovAfiliatorios]	MovRazBaja on MOVBaja.IDRazonMovimiento = MovRazBaja.IDRazonMovimiento
		LEFT JOIN [RH].[tblCatSucursales] S WITH(NOLOCK) ON E.IDSucursal = S.IDSucursal
		left join [sat].[tblCatColonias] SucursalColonia WITH(NOLOCK) on s.IDColonia = SucursalColonia.IDColonia
		left join [sat].[tblCatMunicipios] SucursalMunicipio WITH(NOLOCK) on s.IDMunicipio = SucursalMunicipio.IDMunicipio	 
		left join [sat].[tblCatEstados] SucursalEstados WITH(NOLOCK) on s.IDEstado = SucursalEstados.IDEstado	 
		left join [sat].[tblCatPaises] SucursalPaises WITH(NOLOCK) on s.IDPais = SucursalPaises.IDPais	
		left join [sat].[tblCatCodigosPostales] SucursalCodigoPostal WITH(NOLOCK) on s.IDCodigoPostal = SucursalCodigoPostal.IDCodigoPostal	
	--------
		LEFT JOIN [RH].[tblEmpresa] EMP WITH(NOLOCK) ON EMP.IdEmpresa = e.IDEmpresa 
		left join [sat].[tblCatColonias] EmpresaColonia WITH(NOLOCK) on EMP.IDColonia = EmpresaColonia.IDColonia
		left join [sat].[tblCatMunicipios] EmpresaMunicipio WITH(NOLOCK) on EMP.IDMunicipio = EmpresaMunicipio.IDMunicipio	 
		left join [sat].[tblCatEstados] EmpresaEstados WITH(NOLOCK) on EMP.IDEstado = EmpresaEstados.IDEstado	 
		left join [sat].[tblCatPaises] EmpresaPaises WITH(NOLOCK) on EMP.IDPais = EmpresaPaises.IDPais	
		left join [sat].[tblCatCodigosPostales] EmpresalCodigoPostal WITH(NOLOCK) on EMP.IDCodigoPostal = EmpresalCodigoPostal.IDCodigoPostal
	-------
		LEFT JOIN [RH].[tblCatRegPatronal] RP WITH(NOLOCK) ON RP.IDRegPatronal = E.IDRegPatronal   
		left join [sat].[tblCatColonias] RegistroPatronalColonia WITH(NOLOCK) on RP.IDColonia = RegistroPatronalColonia.IDColonia
		left join [sat].[tblCatMunicipios] RegistroPatronalMunicipio WITH(NOLOCK) on RP.IDMunicipio = RegistroPatronalMunicipio.IDMunicipio	 
		left join [sat].[tblCatEstados] RegistroPatronalEstados WITH(NOLOCK) on RP.IDEstado = RegistroPatronalEstados.IDEstado	 
		left join [sat].[tblCatPaises] RegistroPatronalPaises WITH(NOLOCK) on RP.IDPais = RegistroPatronalPaises.IDPais	
		left join [sat].[tblCatCodigosPostales] RegistroPatronalCodigoPostal WITH(NOLOCK) on RP.IDCodigoPostal = RegistroPatronalCodigoPostal.IDCodigoPostal	 
	-------
		LEFT JOIN [RH].[tblCatTiposPrestaciones] TipoPrestaciones WITH(NOLOCK) on E.IDTipoPrestacion = TipoPrestaciones.IDTipoPrestacion
	-------
		LEFT JOIN [RH].[tblCatRazonesSociales] RazonSocial WITH(NOLOCK) on RazonSocial.IDRazonSocial = E.IDRazonSocial
		left join [sat].[tblCatColonias] RazonSocialColonia WITH(NOLOCK) on RazonSocial.IDColonia = RazonSocialColonia.IDColonia
		left join [sat].[tblCatMunicipios] RazonSocialMunicipio WITH(NOLOCK) on RazonSocial.IDMunicipio = RazonSocialMunicipio.IDMunicipio	 
		left join [sat].[tblCatEstados] RazonSocialEstados WITH(NOLOCK) on RazonSocial.IDEstado = RazonSocialEstados.IDEstado	 
		left join [sat].[tblCatPaises] RazonSocialPaises WITH(NOLOCK) on RazonSocial.IDPais = RazonSocialPaises.IDPais	
		left join [sat].[tblCatCodigosPostales] RazonSocialCodigoPostal WITH(NOLOCK) on RazonSocial.IDCodigoPostal = RazonSocialCodigoPostal.IDCodigoPostal	
	 ------
		LEFT JOIN #tempContra ContratoEmpleado WITH(NOLOCK) ON ContratoEmpleado.IDEmpleado = E.IDEmpleado          
			and ContratoEmpleado.FechaIniContrato <= @Fechafin 
			and ContratoEmpleado.FechaFinContrato >= @Fechafin     
		--LEFT JOIN [sat].[tblCatTiposContrato] tipoContrato WITH(NOLOCK)          
		--		ON E.IDTipoContrato = tipoContrato.IDTipoContrato  
		-------
		left join [RH].[tblDireccionEmpleado] DireccionEmpleado WITH(NOLOCK) on e.IDEmpleado = DireccionEmpleado.IDEmpleado  
			AND DireccionEmpleado.FechaIni<= @Fechafin 
			and DireccionEmpleado.FechaFin >= @Fechafin  
		Left join Sat.tblCatCodigosPostales CP WITH(NOLOCK) on CP.IDCodigoPostal = DireccionEmpleado.IDCodigoPostal
		Left join Sat.tblCatEstados Estados WITH(NOLOCK) on DireccionEmpleado.IDEstado = Estados.IDEstado
		Left join Sat.tblCatMunicipios Municipios WITH(NOLOCK) on DireccionEmpleado.IDMunicipio = Municipios.IDMunicipio
		Left join Sat.tblCatColonias Colonias WITH(NOLOCK) on DireccionEmpleado.IDColonia = Colonias.IDColonia
		Left join Sat.tblCatPaises DireccionEmpleadoPais on DireccionEmpleado.IDPais = DireccionEmpleadoPais.IDPais
		Left join Sat.tblCatLocalidades Localidades WITH(NOLOCK) on DireccionEmpleado.IDLocalidad = Localidades.IDLocalidad  
	-------------
		left join #TempTurnoEmpleado TurnoEmpleado	WITH(NOLOCK) on e.IDEmpleado = TurnoEmpleado.IDEmpleado
	------------ 
		left join [RH].[tblContratoEmpleado] Documento WITH(NOLOCK) on Documento.IDEmpleado = E.IDEmpleado
			and Documento.IDContratoEmpleado = @IDContratoEmpleado
	------------
		left join [RH].[tblCatPuestos] PuestoEmpleado on E.IDPuesto = PuestoEmpleado.IDPuesto

	
	
	
	/*------------------------------------------------------------------------------------------------------------------------------------------------------------*/	
	-- SECCION ARTICULO ASIGNADO
	
	DECLARE @IDArticulo				INT = 0
			, @IDDetalleArticulo	INT = 0
			, @Propiedades			NVARCHAR(MAX)
			, @ASIGNADO				INT = 2			
			;
	
	-- IDENTIFICAMOS EL ARTICULO
	SELECT @IDArticulo = CAST(DETALLE.IDArticulo AS INT)
			, @IDDetalleArticulo = CAST(DETALLE.IDDetalleArticulo AS INT)			
	FROM [ControlEquipos].[tblEstatusArticulos] ASIGNACION
		INNER JOIN [ControlEquipos].[tblDetalleArticulos] DETALLE ON ASIGNACION.IDDetalleArticulo = DETALLE.IDDetalleArticulo		
	WHERE ASIGNACION.IDEstatusArticulo = @IDReferencia;	

	-- REVISION ID'S ARTICULO
	--SELECT @IDArticulo AS IDArticulo, @IDDetalleArticulo AS IDDetalleArticulo

	
	-- DETALLE DEL ARTICULO ASINADO
	SELECT DAA.IDDetalleArticulo
			, ARTICULO.Descripcion			
			, UPPER(DAA.Etiqueta) AS Etiqueta
			, DAA.FechaAlta
			, ISNULL(UPPER(DAA.IDGenero), '') AS IDGenero
			, DAA.Costo
			, ISNULL(UPPER(UDT.Nombre), '') AS UnidadTiempo
			, ISNULL(UPPER((SELECT JSON_VALUE(TC.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Nombre')))), '') AS TipoCaducidad
			, DAA.Tiempo
			--, DAA.IDArticulo
			--, EA.IDEstatusArticulo
			--, EA.IDCatEstatusArticulo
			, (
	   			SELECT JSON_VALUE(CP.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-','')), 'Nombre')) AS [NombrePropiedad]
						, CASE
	   						WHEN ISJSON(CP.[Data]) = 1 
								THEN
	   								(
	   								SELECT JSON_VALUE(item.Value, '$.Nombre')
	   								FROM OPENJSON(CP.[Data]) AS item
	   								WHERE JSON_VALUE(item.Value, '$.ID') = VP.Valor
	   								)
	   							ELSE
	   								ISNULL(VP.Valor, '') -- o cualquier otro valor por defecto que desees cuando [Data] no sea un JSON válido
	   						END AS [ValorPropiedad]
	   			FROM [ControlEquipos].[tblDetalleArticulos] DA
					INNER JOIN [ControlEquipos].[tblArticulos] A ON A.IDArticulo = DA.IDArticulo
					INNER JOIN [ControlEquipos].[tblCatTiposArticulos] TA ON TA.IDTipoArticulo = A.IDTipoArticulo
					INNER JOIN [ControlEquipos].[tblCatPropiedades] CP ON CP.IDTipoArticulo = TA.IDTipoArticulo
					LEFT JOIN  [ControlEquipos].[tblValoresPropiedades] VP ON VP.IDPropiedad = CP.IDPropiedad AND VP.IDDetalleArticulo = DA.IDDetalleArticulo					
				WHERE DAA.IDDetalleArticulo = DA.IDDetalleArticulo
	   			FOR JSON AUTO
			 ) AS Propiedades			
	INTO #tempDetallesArticulos
	FROM [ControlEquipos].[tblDetalleArticulos] DAA
		INNER JOIN [ControlEquipos].[tblEstatusArticulos] EA ON DAA.IDDetalleArticulo = EA.IDDetalleArticulo
		INNER JOIN [ControlEquipos].[tblArticulos] ARTICULO ON DAA.IDArticulo = ARTICULO.IDArticulo
		LEFT JOIN [App].[tblCatUnidadesDeTiempo] UDT ON DAA.IDUnidadDeTiempo = UDT.IDUnidadDeTiempo
		LEFT JOIN [ControlEquipos].[TblCatTiposCaducidad] TC ON DAA.IDCatTipoCaducidad = TC.IDCatTipoCaducidad
	WHERE DAA.IDArticulo = @IDArticulo
			AND DAA.IDDetalleArticulo = @IDDetalleArticulo
			AND EA.IDCatEstatusArticulo = @ASIGNADO

	-- REVISION DETALLE ARTICULO
	-- SELECT * FROM #tempDetallesArticulos	
	

	-- OBTENEMOS PROPIEDADES Y VALORES UNICOS DEL ARTICULO
	SELECT @Propiedades = Propiedades FROM #tempDetallesArticulos
		
	-- UNIMOS LA INFORMACION EN COLUMNA VERTICAL (GENERAL Y PROPS UNICAS)
	SELECT @IDEmpleado AS IDEmpleado
			, Columna
			, Valor
	INTO #tempArticuloProps
	FROM
	(
		-- PROPS EN COMÚN (TODOS LOS ARTICULOS)
		SELECT 'Articulo_DESCRIPCION' AS Columna, CAST(Descripcion AS VARCHAR(MAX)) AS Valor FROM #tempDetallesArticulos
		UNION ALL
		SELECT 'Articulo_ETIQUETA' AS Columna, CAST(Etiqueta AS VARCHAR(MAX)) AS Valor FROM #tempDetallesArticulos
		UNION ALL
		SELECT 'Articulo_FECHA_ALTA' AS Columna, CAST(FechaAlta AS VARCHAR(MAX)) AS Valor FROM #tempDetallesArticulos
		UNION ALL
		SELECT 'Articulo_ID_GENERO' AS Columna, CAST(IDGenero AS VARCHAR(MAX)) AS Valor FROM #tempDetallesArticulos
		UNION ALL
		SELECT 'Articulo_COSTO' AS Columna, CAST(Costo AS VARCHAR(MAX)) AS Valor FROM #tempDetallesArticulos
		UNION ALL
		SELECT 'Articulo_UNIDAD_TIEMPO' AS Columna, CAST(UnidadTiempo AS VARCHAR(MAX)) AS Valor FROM #tempDetallesArticulos
		UNION ALL
		SELECT 'Articulo_TIPO_CADUCIDAD' AS Columna, CAST(TipoCaducidad AS VARCHAR(MAX)) AS Valor FROM #tempDetallesArticulos
		UNION ALL
		SELECT 'Articulo_TIEMPO' AS Columna, CAST(Tiempo AS VARCHAR(MAX)) AS Valor FROM #tempDetallesArticulos
		UNION ALL
		-- PROPS UNICAS (DINAMICAS)
		SELECT 'Articulo_' + UPPER(TRANSLATE(REPLACE(Columna, ' ', '_'), 'ñáéíóúàèìòùãõâêîôôäëïöüçÑÁÉÍÓÚÀÈÌÒÙÃÕÂÊÎÔÛÄËÏÖÜÇ ', 'naeiouaeiouaoaeiooaeioucNAEIOUAEIOUAOAEIOOAEIOUC_')) AS Columna, UPPER(Valor) AS Valor
		FROM OPENJSON(@Propiedades)
		WITH (
			Columna NVARCHAR(MAX) '$.NombrePropiedad',
			Valor NVARCHAR(MAX) '$.ValorPropiedad'
		)
	) AS DataNormalizada;
	
	-- REVISION PROPS ARTICULO
	-- SELECT * FROM #tempArticuloProps


	-- NORMALIZAMOS COLUMNAS Y VALORES (HORIZONTAL)
	IF((SELECT COUNT(*) FROM #tempArticuloProps) > 0)
	BEGIN

		DECLARE @colsExtra AS NVARCHAR(MAX)
				, @queryExtra AS NVARCHAR(MAX)
				;

		SET @colsExtra = STUFF((SELECT DISTINCT ',' + QUOTENAME(C.Columna)
								FROM #tempArticuloProps C
								FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
				
		set @queryExtra = 'SELECT IDEmpleado,' + @colsExtra + '
						   INTO ##extra
						   FROM 
							(
								SELECT IDEmpleado
									   , Columna
									   , Valor
								FROM #tempArticuloProps
							) x
						   PIVOT 
							(
								MAX(Valor)
								FOR Columna IN (' + @colsExtra + ')
							) P ';

		EXECUTE(@queryExtra)
	END




	   	  
	-- RESULTADO FINAL
	SELECT * 
	FROM #TempEmpleado E 
		LEFT JOIN ##extra ART_GRL ON E.IDEmpleado = ART_GRL.IDEmpleado


END
GO
