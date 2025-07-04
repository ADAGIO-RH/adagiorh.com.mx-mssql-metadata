USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [RH].[vwEmpleados] WITH SCHEMABINDING 
AS

Select 
E.IDEmpleado
			,UPPER(E.ClaveEmpleado)AS ClaveEmpleado
			,UPPER(E.RFC) AS RFC
			,UPPER(E.CURP) AS CURP
			,UPPER(E.IMSS) AS IMSS
			,UPPER(E.Nombre) AS Nombre
			,UPPER(E.SegundoNombre) AS SegundoNombre 
			,UPPER(E.Paterno) AS Paterno
			,UPPER(E.Materno) AS Materno
--			,UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')) AS NOMBRECOMPLETO
			,substring(UPPER(COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+', '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'')),1,49 ) AS NOMBRECOMPLETO
			,ISNULL(E.IDMunicipioNacimiento,0) as IDMunicipioNacimiento
			,UPPER(ISNULL(MUNICIPIO.Descripcion,'NINGUNO')) AS MunicipioNacimiento
			,ISNULL(E.IDEstadoNacimiento,0) as IDEstadoNacimiento
			,UPPER(ISNULL(ESTADOS.NombreEstado,'NINGUNO')) AS EstadoNacimiento
			,ISNULL(E.IDPaisNacimiento,0) as IDPaisNacimiento
			,UPPER(ISNULL(PAISES.Descripcion,'NINGUNO')) AS PaisNacimiento
			,isnull(E.FechaNacimiento,'1900-01-01') as FechaNacimiento
			,ISNULL(E.IDEstadoCiviL,0) AS IDEstadoCivil
			,UPPER(ISNULL(CIVILES.Descripcion,'NINGUNO')) AS EstadoCivil
			,CASE WHEN E.Sexo = 'M' THEN 'MASCULINO'
				  ELSE 'FEMENINO'
				  END AS Sexo
			,isnull(E.IDEscolaridad,0) as IDEscolaridad
			,UPPER(isnull(ESTUDIOS.Descripcion,'NINGUNO')) as Escolaridad
			,UPPER(E.DescripcionEscolaridad) AS DescripcionEscolaridad
			,ISNULL(E.IDInstitucion,0) as IDInstitucion
			,UPPER(isnull(I.Descripcion,'NINGUNO')) as Institucion
			,ISNULL(E.IDProbatorio,0) as IDProbatorio
			,UPPER(isnull(Probatorio.Descripcion,'NINGUNO')) as Probatorio
			,isnull(E.FechaPrimerIngreso,'1900-01-01') as FechaPrimerIngreso
			,isnull(E.FechaIngreso,'1900-01-01') as FechaIngreso
			,isnull(E.FechaAntiguedad,'1900-01-01') as FechaAntiguedad
			,isnull(E.Sindicalizado,0) as Sindicalizado
			,ISNULL(E.IDJornadaLaboral,0)AS IDJornadaLaboral
			,UPPER(ISNULL(JORNADA.Descripcion,'NINGUNA')) AS JornadaLaboral
			,UPPER(E.UMF) AS UMF
			,UPPER(E.CuentaContable) AS CuentaContable
			,isnull(E.IDTipoRegimen,0) AS IDTipoRegimen
			,UPPER(ISNULL(TR.Descripcion,'NINGUNO')) AS TipoRegimen
			,ISNULL(E.IDPreferencia,0) AS IDPreferencia
				,isnull(afore.IDAfore,0) as  IDAfore
			,UPPER(isnull(afore.Descripcion,'NINGUNO')) as Afore
			--,[RH].[fnFueVigente](e.IDEmpleado
			--			 ,getdate()
			--			 ,getdate()) as Vigente		
			,cast(0 as bit) as Vigente	
FROM [RH].[tblEmpleados] E 
		LEFT JOIN SAT.tblCatTiposRegimen TR 
			on E.IDTipoRegimen = TR.IDTipoRegimen
		LEFT JOIN SAT.tblCatMunicipios MUNICIPIO 
			ON E.IDMunicipioNacimiento = MUNICIPIO.IDMunicipio
		LEFT JOIN SAT.tblCatEstados ESTADOS 
			ON E.IDEstadoNacimiento = ESTADOS.IDEstado
		LEFT JOIN SAT.tblCatPaises PAISES 
			ON E.IDPaisNacimiento = PAISES.IDPais
		LEFT JOIN RH.tblCatEstadosCiviles CIVILES 
			ON E.IDEstadoCivil = CIVILES.IDEstadoCivil
		LEFT JOIN STPS.tblCatEstudios ESTUDIOS 
			ON E.IDEscolaridad = ESTUDIOS.IDEstudio
		LEFT JOIN STPS.tblCatInstituciones I 
			on I.IDInstitucion = E.IDInstitucion
		LEFT JOIN STPS.tblCatProbatorios Probatorio 
			on Probatorio.IDProbatorio = e.IDProbatorio
		LEFT JOIN SAT.tblCatTiposJornada JORNADA 
			ON E.IDJornadaLaboral = JORNADA.IDTipoJornada
	     LEFT JOIN [RH].[tblCatAfores] afore 
			ON afore.IDAfore = e.IDAfore
GO
