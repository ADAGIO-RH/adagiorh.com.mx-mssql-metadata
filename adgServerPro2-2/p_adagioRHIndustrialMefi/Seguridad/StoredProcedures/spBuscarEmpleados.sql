USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spBuscarEmpleados]              
(              
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
	
	declare
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tempMovAfil') is not null drop table #tempMovAfil;
	if object_id('tempdb..#tempContra') is not null drop table #tempContra    
    
	select IDEmpleado, FechaAlta, FechaBaja,            
		case when ((FechaBaja is not null and FechaReingreso is not null) and FechaReingreso > FechaBaja) then FechaReingreso else null end as FechaReingreso            
		,FechaReingresoAntiguedad
		,IDMovAfiliatorio    
	into #tempMovAfil            
	from (
        SELECT 
        DISTINCT tm.IDEmpleado,            
	            CASE WHEN(IDEmpleado is not null) 
                THEN (
                                                        select top 1 Fecha             
	    			                                           from [IMSS].[tblMovAfiliatorios]  mAlta WITH(NOLOCK)            
	    		                                               join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
                                                                     on mAlta.IDTipoMovimiento=c.IDTipoMovimiento            
	    			                                           where mAlta.IDEmpleado=tm.IDEmpleado 
                                                                    and c.Codigo='A'              
	    			                                           Order By mAlta.Fecha Desc , c.Prioridad DESC 
                ) END AS FechaAlta,            
	            CASE WHEN (IDEmpleado is not null) 
                THEN (
                                                        select top 1 Fecha             
	    			                                           from [IMSS].[tblMovAfiliatorios]  mBaja WITH(NOLOCK)            
	    		                                               join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
                                                                    on mBaja.IDTipoMovimiento=c.IDTipoMovimiento            
	    			                                           where mBaja.IDEmpleado=tm.IDEmpleado 
                                                                    and c.Codigo='B'              
	    		                                                    and mBaja.Fecha <= @FechaFin             
	                                                           order by mBaja.Fecha desc, C.Prioridad desc
                ) END AS FechaBaja,            
	            CASE WHEN (IDEmpleado is not null) 
                THEN (
                                                        select top 1 Fecha             
	    			                                            from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
	    		                                                join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
                                                                    on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
	    			                                            where mReingreso.IDEmpleado=tm.IDEmpleado and c.Codigo='R'              
	    		                                                      and mReingreso.Fecha <= @FechaFin 
	    		                                                      and isnull(mReingreso.RespetarAntiguedad,0) <> 1              
	    		                                                order by mReingreso.Fecha desc, C.Prioridad desc
                ) END AS FechaReingreso,
	            CASE WHEN (IDEmpleado is not null) 
                THEN (
                                                        select top 1 Fecha             
	    			                                           from [IMSS].[tblMovAfiliatorios]  mReingreso WITH(NOLOCK)            
	    		                                               join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
                                                                   on mReingreso.IDTipoMovimiento=c.IDTipoMovimiento            
	    			                                           where mReingreso.IDEmpleado=tm.IDEmpleado 
                                                                     and c.Codigo='R'
	    		                                                     and mReingreso.Fecha <= @FechaFin 
	    		                                                     and isnull(mReingreso.RespetarAntiguedad,0) <> 1              
                                                               order by mReingreso.Fecha desc, C.Prioridad desc
                )END AS FechaReingresoAntiguedad,
	            (
                                                        Select top 1 mSalario.IDMovAfiliatorio 
                                                               from [IMSS].[tblMovAfiliatorios]  mSalario WITH(NOLOCK)            
	    		                                               join [IMSS].[tblCatTipoMovimientos]   c  WITH(NOLOCK) 
                                                                    on mSalario.IDTipoMovimiento=c.IDTipoMovimiento            
	    		                                        	   where mSalario.IDEmpleado=tm.IDEmpleado 
                                                                     and c.Codigo in ('A','M','R')      
	    		                                        	         and mSalario.Fecha <= @FechaFin          
	    		                                        	  order by mSalario.Fecha desc 
                )  IDMovAfiliatorio                                             
	    from [IMSS].[tblMovAfiliatorios]  tm 
    ) mm     
  
  
	select  
		ContratoEmpleado.IDContratoEmpleado
		,ContratoEmpleado.IDEmpleado
		,Isnull(documentos.IDDocumento,0) as IDDocumento             
		,UPPER(Isnull(documentos.Descripcion,'')) as Documento             
		,Isnull(tipoContrato.IDTipoContrato,0) as IDTipoContrato             
		,UPPER(Isnull(tipoContrato.Descripcion,'')) as TipoContrato            
		,isnull(ContratoEmpleado.FechaIni,'1900-01-01') as FechaIniContrato          
		,isnull(ContratoEmpleado.FechaFin,'1900-01-01') as FechaFinContrato 
		,ROW_NUMBER()OVER(partition by ContratoEmpleado.IDEmpleado order by ContratoEmpleado.FechaIni desc) as RN
	into #tempContra
	from [RH].[tblContratoEmpleado] ContratoEmpleado WITH(NOLOCK)              
		inner JOIN [RH].[tblCatDocumentos] documentos WITH(NOLOCK)              
			ON ContratoEmpleado.IDDocumento = documentos.IDDocumento          
			and documentos.EsContrato = 1              
		inner JOIN [sat].[tblCatTiposContrato] tipoContrato WITH(NOLOCK)              
			ON ContratoEmpleado.IDTipoContrato = tipoContrato.IDTipoContrato    
        
	delete #tempContra where RN > 1

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
		--   ,UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) AS NOMBRECOMPLETO              
		,SUBSTRING(UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+' '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,49 ) AS NOMBRECOMPLETO              
		,ISNULL(E.IDLocalidadNacimiento,0) as IDLocalidadNacimiento              
		,UPPER(ISNULL(ISNULL(LOCALIDAD.Descripcion,E.LocalidadNacimiento),'')) AS LocalidadNacimiento              
                 
		,ISNULL(E.IDMunicipioNacimiento,0) as IDMunicipioNacimiento              
		,UPPER(ISNULL(ISNULL(MUNICIPIO.Descripcion,E.MunicipioNacimiento),'')) AS MunicipioNacimiento              
                 
		,ISNULL(E.IDEstadoNacimiento,0) as IDEstadoNacimiento              
		,UPPER(ISNULL(ISNULL(ESTADOS.NombreEstado,E.EstadoNacimiento),'')) AS EstadoNacimiento              
              
		,ISNULL(E.IDPaisNacimiento,0) as IDPaisNacimiento              
		,UPPER(ISNULL(ISNULL(PAISES.Descripcion,E.PaisNacimiento),'')) AS PaisNacimiento              
              
		,ISNULL(E.FechaNacimiento,'1900-01-01') as FechaNacimiento              
		,ISNULL(E.IDEstadoCiviL,0) AS IDEstadoCivil              
		--,UPPER(ISNULL(CIVILES.Descripcion,'')) AS EstadoCivil              
		--,CASE WHEN E.Sexo = 'M' THEN 'MASCULINO'              
		--	ELSE 'FEMENINO'              
		--	END AS Sexo     
		,JSON_VALUE(CIVILES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstadoCivil
		,JSON_VALUE(SEXOS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Sexo
		,ISNULL(E.IDEscolaridad,0) as IDEscolaridad              
		,UPPER(ISNULL(ESTUDIOS.Descripcion,'')) as Escolaridad              
		,UPPER(E.DescripcionEscolaridad) AS DescripcionEscolaridad              
		,ISNULL(E.IDInstitucion,0) as IDInstitucion              
		,UPPER(ISNULL(I.Descripcion,'')) as Institucion              
		,ISNULL(E.IDProbatorio,0) as IDProbatorio              
		,UPPER(ISNULL(Probatorio.Descripcion,'')) as Probatorio              
		,ISNULL(E.FechaPrimerIngreso,'1900-01-01') as FechaPrimerIngreso              
		,ISNULL(E.FechaIngreso,'1900-01-01') as FechaIngreso              
		,CASE WHEN isnull(M.FechaReingresoAntiguedad,'1900-01-01') >= M.FechaAlta THEN ISNULL(M.FechaReingresoAntiguedad,'1900-01-01')              
			ELSE M.FechaAlta              
			END  as FechaAntiguedad 
		--,E.FechaAntiguedad as  FechaAntiguedad            
		,ISNULL(E.Sindicalizado,0) as Sindicalizado              
		,ISNULL(E.IDJornadaLaboral,0)AS IDJornadaLaboral              
		,UPPER(ISNULL(JORNADA.Descripcion,'')) AS JornadaLaboral              
		,UPPER(E.UMF) AS UMF              
		,UPPER(E.CuentaContable) AS CuentaContable              
		,ISNULL(E.IDTipoRegimen,0) AS IDTipoRegimen              
		,UPPER(ISNULL(TR.Descripcion,'')) AS TipoRegimen              
		,ISNULL(E.IDPreferencia,0) AS IDPreferencia              
		,ISNULL(D.IDDepartamento,0) as  IDDepartamento              
		,UPPER(isnull(JSON_VALUE(D.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'SIN DEPARTAMENTO')) as Departamento              
		,ISNULL(S.IDSucursal,0) as  IDSucursal              
		,UPPER(ISNULL(S.Descripcion,'SIN SUCURSAL')) as Sucursal              
		,ISNULL(P.IDPuesto,0) as  IDPuesto              
		,UPPER(ISNULL(JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) ,'SIN PUESTOS')) as Puesto             
		,ISNULL(C.IDCliente,0) as  IDCliente              
		,UPPER(ISNULL(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')),'SIN CLIENTE')) as Cliente              
		,ISNULL(EMP.IdEmpresa,0) as  IDEmpresa              
		,SUBSTRING(UPPER(ISNULL(EMP.NombreComercial,'SIN EMPRESA')),1,49) as Empresa              
		,ISNULL(CC.IDCentroCosto,0) as  IDCentroCosto              
		,UPPER(isnull(JSON_VALUE(CC.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'SIN CENTRO DE COSTO')) as CentroCosto              
		,ISNULL(A.IDArea,0) as  IDArea              
		,UPPER(isnull(JSON_VALUE(A.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'SIN ÁREA')) as Area              
		,ISNULL(DV.IDDivision,0) as  IDDivision              
		,UPPER(isnull(JSON_VALUE(DV.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'SIN DIVISIÓN')) as Division              
		,ISNULL(R.IDRegion,0) as  IDRegion              
		,UPPER(isnull(JSON_VALUE(R.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'SIN REGIÓN')) as Region              
		,ISNULL(CP.IDClasificacionCorporativa,0) as  IDClasificacionCorporativa              
		,UPPER(isnull(JSON_VALUE(CP.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'SIN CLASIFICACIÓN CORPORATIVA')) as ClasificacionCorporativa              
		,ISNULL(RP.IDRegPatronal,0) as  IDRegPatronal              
		,UPPER(ISNULL(RP.RazonSocial,'SIN REG. PATRONAL')) as RegPatronal              
		,ISNULL(TipoNomina.IDTipoNomina,0) as  IDTipoNomina       
		,UPPER(ISNULL(TipoNomina.Descripcion,'SIN TIPO DE NÓMINA')) as TipoNomina              
		,ISNULL(MOV.SalarioDiario,0.00) as SalarioDiario              
		,ISNULL(MOV.SalarioDiarioReal,0.00) as SalarioDiarioReal              
		,ISNULL(MOV.SalarioIntegrado,0.00)as SalarioIntegrado              
		,ISNULL(MOV.SalarioVariable,0.00)as SalarioVariable              
		,ISNULL(Prestaciones.IDTipoPrestacion,0) as IDTipoPrestacion              
		,ISNULL(RazonSocial.IDRazonSocial,0) as  IDRazonSocial              
		,UPPER(ISNULL(RazonSocial.RazonSocial,'SIN RAZÓN SOCIAL')) as RazonSocial              
		,ISNULL(afore.IDAfore,0) as  IDAfore              
		,UPPER(ISNULL(afore.Descripcion,'SIN AFORE')) as Afore              
		--,[RH].[fnFueVigente](e.IDEmpleado              
		--    ,getdate()              
		--    ,getdate()) as Vigente                
		,CAST(0 as bit) as Vigente               
		--,ROW_NUMBER()OVER(order by e.ClaveEmpleado asc) as RowNumber              
		,0 as RowNumber          
		,NULL as [ClaveNombreCompleto]            
		,ISNULL(E.PermiteChecar,0) as			PermiteChecar             
		,ISNULL(E.RequiereChecar,0) as			RequiereChecar             
		,ISNULL(E.PagarTiempoExtra,0) as		PagarTiempoExtra             
		,ISNULL(E.PagarPrimaDominical,0) as		PagarPrimaDominical             
		,ISNULL(E.PagarDescansoLaborado,0) as	PagarDescansoLaborado             
		,ISNULL(E.PagarFestivoLaborado,0) as	PagarFestivoLaborado          
		----------          
		,ISNULL(contratos.IDDocumento,0) as					IDDocumento             
		,UPPER(ISNULL(contratos.Documento,'')) as			Documento             
		,ISNULL(contratos.IDTipoContrato,0) as				IDTipoContrato             
		,UPPER(ISNULL(contratos.TipoContrato,'')) as		TipoContrato            
		,ISNULL(contratos.FechaIniContrato,'1900-01-01') as FechaIniContrato          
		,ISNULL(contratos.FechaFinContrato,'1900-01-01') as FechaFinContrato          
   ---------  
		,isnull(CatPrestaciones.Descripcion,'SIN PRESTACION') as TiposPrestacion
		,isnull(catTipoTrabajador.Descripcion,'SIN TIPO DE TRABAJADOR') as tipoTrabajadorEmpleado        
	FROM [RH].[tblEmpleados] E WITH(NOLOCK)   
		LEFT JOIN SAT.tblCatTiposRegimen TR WITH(NOLOCK)		ON E.IDTipoRegimen = TR.IDTipoRegimen              
		LEFT JOIN SAT.tblCatLocalidades LOCALIDAD WITH(NOLOCK)	ON E.IDLocalidadNacimiento = LOCALIDAD.IDLocalidad              
		LEFT JOIN SAT.tblCatMunicipios MUNICIPIO WITH(NOLOCK)	ON E.IDMunicipioNacimiento = MUNICIPIO.IDMunicipio              
		LEFT JOIN SAT.tblCatEstados ESTADOS WITH(NOLOCK)		ON E.IDEstadoNacimiento = ESTADOS.IDEstado              
		LEFT JOIN SAT.tblCatPaises PAISES WITH(NOLOCK)			ON E.IDPaisNacimiento = PAISES.IDPais              
		LEFT JOIN RH.tblCatEstadosCiviles CIVILES WITH(NOLOCK)	ON E.IDEstadoCivil = CIVILES.IDEstadoCivil     
		LEFT JOIN RH.tblCatGeneros SEXOS WITH(NOLOCK)			ON E.Sexo = SEXOS.IDGenero
		LEFT JOIN STPS.tblCatEstudios ESTUDIOS WITH(NOLOCK)		ON E.IDEscolaridad = ESTUDIOS.IDEstudio              
		LEFT JOIN STPS.tblCatInstituciones I WITH(NOLOCK)		ON I.IDInstitucion = E.IDInstitucion              
		LEFT JOIN STPS.tblCatProbatorios Probatorio WITH(NOLOCK)	ON Probatorio.IDProbatorio = e.IDProbatorio              
		LEFT JOIN SAT.tblCatTiposJornada JORNADA WITH(NOLOCK)		ON E.IDJornadaLaboral = JORNADA.IDTipoJornada              
		LEFT JOIN [RH].[tblCatAfores] afore  with (nolock)			ON afore.IDAfore = e.IDAfore              
		LEFT JOIN [RH].[tblDepartamentoEmpleado] DE WITH(NOLOCK)	ON E.IDEmpleado = DE.IDEmpleado AND DE.FechaIni<= @Fechafin and dE.FechaFin >= @Fechafin               
		LEFT JOIN [RH].[tblCatDepartamentos] D WITH(NOLOCK)			ON D.IDDepartamento = DE.IDDepartamento              
		LEFT JOIN [RH].[tblSucursalEmpleado] SE WITH(NOLOCK)		ON SE.IDEmpleado = E.IDEmpleado AND SE.FechaIni<= @Fechafin and SE.FechaFin >= @Fechafin               
		LEFT JOIN [RH].[tblCatSucursales] S WITH(NOLOCK)			ON SE.IDSucursal = S.IDSucursal              
		LEFT JOIN [RH].[tblPuestoEmpleado] PE WITH(NOLOCK)			ON PE.IDEmpleado = E.IDEmpleado AND PE.FechaIni<= @Fechafin and PE.FechaFin >= @Fechafin               
		LEFT JOIN [RH].[tblCatPuestos] P WITH(NOLOCK)               ON P.IDPuesto = PE.IDPuesto              
		LEFT JOIN [RH].[tblClienteEmpleado] CE WITH(NOLOCK)			ON CE.IDEmpleado = E.IDEmpleado AND CE.FechaIni<= @Fechafin and CE.FechaFin >= @Fechafin               
		LEFT JOIN [RH].[tblCatClientes] C WITH(NOLOCK)              ON C.IDCliente = CE.IDCliente              
		LEFT JOIN [RH].[tblEmpresaEmpleado] EMPE WITH(NOLOCK)		ON EMPE.IDEmpleado = E.IDEmpleado AND EMPE.FechaIni<= @Fechafin and EMPE.FechaFin >= @Fechafin              
		LEFT JOIN [RH].[tblEmpresa] EMP WITH(NOLOCK)				ON EMP.IdEmpresa = EMPE.IDEmpresa              
		LEFT JOIN [RH].[tblCentroCostoEmpleado] CCE WITH(NOLOCK)	ON CCE.IDEmpleado = E.IDEmpleado AND CCE.FechaIni<= @Fechafin and CCE.FechaFin >= @Fechafin              
		LEFT JOIN [RH].[tblCatCentroCosto] CC WITH(NOLOCK)			ON CC.IDCentroCosto = CCE.IDCentroCosto              
		LEFT JOIN [RH].[tblAreaEmpleado] AE WITH(NOLOCK)			ON AE.IDEmpleado = E.IDEmpleado AND AE.FechaIni<= @Fechafin and AE.FechaFin >= @Fechafin              
		LEFT JOIN [RH].[tblCatArea] A WITH(NOLOCK)					ON A.IDArea = AE.IDArea              
		LEFT JOIN [RH].[tblDivisionEmpleado] DVE WITH(NOLOCK)		ON DVE.IDEmpleado = E.IDEmpleado AND DVE.FechaIni<= @Fechafin and DVE.FechaFin >= @Fechafin              
		LEFT JOIN [RH].[tblCatDivisiones] DV WITH(NOLOCK)			ON DV.IDDivision = DVE.IDDivision              
		LEFT JOIN [RH].[tblRegionEmpleado] RE WITH(NOLOCK)			ON RE.IDEmpleado = E.IDEmpleado AND RE.FechaIni<= @Fechafin and RE.FechaFin >= @Fechafin              
		LEFT JOIN [RH].[tblCatRegiones] R WITH(NOLOCK)              ON R.IDRegion = RE.IDRegion              
		LEFT JOIN [RH].[tblClasificacionCorporativaEmpleado] CPE WITH(NOLOCK)	ON CPE.IDEmpleado = E.IDEmpleado AND CPE.FechaIni<= @Fechafin and CPE.FechaFin >= @Fechafin              
		LEFT JOIN [RH].[tblCatClasificacionesCorporativas] CP WITH(NOLOCK)		ON CP.IDClasificacionCorporativa = CPE.IDClasificacionCorporativa              
		LEFT JOIN [RH].[tblRegPatronalEmpleado] RPE WITH(NOLOCK)				ON RPE.IDEmpleado = E.IDEmpleado AND RPE.FechaIni<= @Fechafin and RPE.FechaFin >= @Fechafin              
		LEFT JOIN [RH].[tblCatRegPatronal] RP WITH(NOLOCK)						ON RP.IDRegPatronal = RPE.IDRegPatronal              
		LEFT JOIN [RH].[tblTipoNominaEmpleado] TipoNominaEmpleado WITH(NOLOCK)	ON e.IDEmpleado = TipoNominaEmpleado.IDEmpleado AND TipoNominaEmpleado.FechaIni<= @Fechafin and TipoNominaEmpleado.FechaFin >= @Fechafin              
		LEFT JOIN [Nomina].[tblCatTipoNomina] TipoNomina WITH(NOLOCK)			ON TipoNomina.IDTipoNomina = TipoNominaEmpleado.IDTipoNomina              
		LEFT JOIN [RH].[tblRazonSocialEmpleado] RazonSocialEmpleado WITH(NOLOCK)ON e.IDEmpleado = RazonSocialEmpleado.IDEmpleado AND RazonSocialEmpleado.FechaIni<= @Fechafin and RazonSocialEmpleado.FechaFin >= @Fechafin              
		LEFT JOIN [RH].[tblCatRazonesSociales] RazonSocial WITH(NOLOCK)			ON RazonSocial.IDRazonSocial = RazonSocialEmpleado.IDRazonSocial            
		------------          
		-- LEFT JOIN [RH].[tblContratoEmpleado] ContratoEmpleado WITH(NOLOCK)              
		-- ON ContratoEmpleado.IDEmpleado = E.IDEmpleado              
		--  AND ContratoEmpleado.FechaIni<= @Fechafin and ContratoEmpleado.FechaFin >= @Fechafin            
            
		--left JOIN [RH].[tblCatDocumentos] documentos WITH(NOLOCK)              
		-- ON ContratoEmpleado.IDDocumento = documentos.IDDocumento          
		--and documentos.EsContrato = 1              
		-- LEFT JOIN [sat].[tblCatTiposContrato] tipoContrato WITH(NOLOCK)              
		-- ON ContratoEmpleado.IDTipoContrato = tipoContrato.IDTipoContrato    
		LEFT JOIN #tempContra contratos ON contratos.IDEmpleado = e.IDEmpleado
			AND --(contratos.FechaIniContrato<= @Fechafin and contratos.FechaFinContrato >= @Fechafin    
				   getdate() Between contratos.FechaIniContrato and contratos.FechaFinContrato--)        
	   ------------          
		LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK)	ON Prestaciones.IDEmpleado = E.IDEmpleado              
			AND Prestaciones.FechaIni<= @Fechafin and Prestaciones.FechaFin >= @Fechafin     
				 LEFT JOIN [RH].[tblCatTiposPrestaciones] CatPrestaciones WITH(NOLOCK) ON Prestaciones.IDTipoPrestacion = CatPrestaciones.IDTipoPrestacion
		LEFT JOIN [RH].[tblTipoTrabajadorEmpleado] tipoTrabajadorEmpleado WITH(NOLOCK) ON tipoTrabajadorEmpleado.IDEmpleado = E.IDEmpleado
		LEFT JOIN [IMSS].[tblCatTipoTrabajador] catTipoTrabajador WITH(NOLOCK) ON tipoTrabajadorEmpleado.IDTipoTrabajador = catTipoTrabajador.IDTipoTrabajador         
		,(
			select * 
			from #tempMovAfil ) M               
				LEFT JOIN [IMSS].[tblMovAfiliatorios] MOV WITH(NOLOCK) ON M.IDMovAfiliatorio = MOV.IDMovAfiliatorio  
	  --LEFT JOIN (select M.IDEmpleado              
	  --      ,M.SalarioDiario              
	  --      ,M.SalarioDiarioReal              
	  --      ,m.SalarioIntegrado              
	  --      ,m.SalarioVariable              
	  --      ,MAX(M.Fecha) as Fecha              
	  --   from imss.tblMovAfiliatorios m              
	  --   inner join imss.tblCatTipoMovimientos t              
	  --    on m.IDTipoMovimiento = t.IDTipoMovimiento              
	  --  where t.Codigo in ('A','R','M')                     
	  --   AND m.Fecha BETWEEN @FechaIni and @Fechafin              
	  -- -- ORDER BY m.Fecha Desc              
	  --  GROUP BY M.IDEmpleado              
	  --      ,M.SalarioDiario              
	  --      ,M.SalarioDiarioReal              
	  --      ,m.SalarioIntegrado              
	  --      ,m.SalarioVariable              
	  --    ) MOV ON  E.IDEmpleado = MOV.IDEmpleado              
	WHERE (E.ClaveEmpleado BETWEEN @EmpleadoIni AND @EmpleadoFin )              
	   and ((TipoNomina.IDTipoNomina = @IDTipoNomina) OR (@IDTipoNomina = 0))              
	   and E.IDEmpleado = m.IDEmpleado and ( (M.FechaAlta<=@FechaFin and (M.FechaBaja>=@FechaIni or M.FechaBaja is null)) or (M.FechaReingreso<=@FechaFin))                            
	   and ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Empleados'),','))               
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Empleados' and isnull(Value,'')<>''))))              
	   and ((D.IDDepartamento in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Departamentos'),','))               
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Departamentos' and isnull(Value,'')<>''))))              
	   and ((S.IDSucursal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Sucursales'),','))               
		  or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Sucursales' and isnull(Value,'')<>''))))              
	   and ((P.IDPuesto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Puestos'),','))               
		 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Puestos' and isnull(Value,'')<>''))))              
	   and ((Prestaciones.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Prestaciones'),',')))               
		 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Prestaciones' and isnull(Value,'')<>'')))           
	   and ((C.IDCliente in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')))               
		 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Clientes' and isnull(Value,'')<>'')))          
	   and ((contratos.IDTipoContrato in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TiposContratacion'),',')))               
		 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'TiposContratacion' and isnull(Value,'')<>'')))        
	   and ((EMP.IdEmpresa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RazonesSociales'),',')))               
		 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RazonesSociales' and isnull(Value,'')<>'')))        
		and ((RP.IDRegPatronal in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'RegPatronales'),',')))               
		 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'RegPatronales' and isnull(Value,'')<>'')))       
	   and ((DV.IDDivision in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Divisiones'),',')))               
		 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Divisiones' and isnull(Value,'')<>'')))        
		and ((CP.IDClasificacionCorporativa in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClasificacionesCorporativas'),',')))               
		 or (Not exists(Select 1 from @dtFiltros where Catalogo = 'ClasificacionesCorporativas' and isnull(Value,'')<>'')))      
		and ((              
		((COALESCE(E.ClaveEmpleado,'')+' '+ COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) like '%'+(Select top 1 Value from @dtFiltros where Catalogo = 'NombreClaveFilter')+'%')                
			) or (Not exists(Select 1 from @dtFiltros where Catalogo = 'NombreClaveFilter' and isnull(Value,'')<>'')))              
  --ORDER BY COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'') ASC                
    ORDER BY E.ClaveEmpleado ASC         
END
GO
