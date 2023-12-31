USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   view [Reportes].[vwDashboardClimaLaboral] as
select 
	p.IDProyecto
	,p.Nombre as Proyecto
	,g.IDGrupo
	,g.IDTipoGrupo
	,g.Nombre as Grupo
	,g.IDReferencia
	,e.ClaveEmpleado as ClaveEvaluado
	,e.NOMBRECOMPLETO as Evaluado
	,d.Codigo as CodigoDepartamento
	,e.Departamento
	,s.Codigo as CodigoSucursal
	,e.Sucursal
	,pu.Codigo as CodigoPuesto
	,e.Puesto
	,div.Codigo as CodigoNivel
	,div.Descripcion as Nivel

	,eEvaluador.ClaveEmpleado	as ClaveEvaluador
	,eEvaluador.NOMBRECOMPLETO	as Evaluador
	,dEvaluador.Codigo			as CodigoDepartamentoEvaluador
	,eEvaluador.Departamento	as DepartamentoEvaluador
	,sEvaluador.Codigo			as CodigoSucursalEvaluador
	,eEvaluador.Sucursal		as SucursalEvaluador
	,puEvaluador.Codigo			as CodigoPuestoEvaluador
	,eEvaluador.Puesto			as PuestoEvaluador
	,divEvaluador.Codigo		as CodigoNivelEvaluador
	,divEvaluador.Descripcion	as NivelEvaluador
	,eEvaluador.Sexo as GeneroEvaluador
	,(CONVERT(int,CONVERT(char(8),getdate(),112))-CONVERT(char(8),eEvaluador.FechaAntiguedad,112))/10000 AS Antiguedad
	,eEvaluador.FechaNacimiento

	,isnull(g.TotalPreguntas			 , 0) as TotalPreguntas
	,isnull(g.MaximaCalificacionPosible	 , 0) as MaximaCalificacionPosible
	,isnull(g.CalificacionObtenida		 , 0) as CalificacionObtenida
	,isnull(g.CalificacionMinimaObtenida , 0) as CalificacionMinimaObtenida
	,isnull(g.CalificacionMaxinaObtenida , 0) as CalificacionMaxinaObtenida
	,isnull(g.Promedio	, 0) as Promedio
	,isnull(g.Porcentaje, 0) as Porcentaje
	--,pre.IDPregunta
	--,pre.IDTipoPregunta
	--,pre.IDGrupo
	,pre.Descripcion as Pregunta
	,isnull(rp.Respuesta , 0) as Respuesta
	,isnull(rp.ValorFinal, 0) as ValorFinal
	,indicadores.Indicador
	--,(select top 1 indicadores.indicador from bk.tempPreguntasIndicadores indicadores where REPLACE(rtrim(ltrim(indicadores.Pregunta)), char(9), '') like REPLACE(ltrim(rtrim(pre.Descripcion)), char(9), '') +'%') Indicador
--INTO bk.tblPreguntas5To4
from Evaluacion360.tblCatProyectos p
	join Evaluacion360.tblEmpleadosProyectos ep on ep.IDProyecto = p.IDProyecto
	join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
	join Evaluacion360.tblCatGrupos g on g.IDReferencia = ee.IDEvaluacionEmpleado and g.TipoReferencia = 4
	join Evaluacion360.tblCatPreguntas pre on pre.IDGrupo = g.IDGrupo
	join RH.tblEmpleadosMaster e on e.IDEmpleado = ep.IDEmpleado
	left join RH.tblCatDepartamentos d on d.IDDepartamento = e.IDDepartamento
	left join RH.tblCatSucursales s on s.IDSucursal = e.IDSucursal
	left join RH.tblCatPuestos pu on pu.IDPuesto = e.IDPuesto
	left join RH.tblCatDivisiones div on div.IDDivision = e.IDDivision

	join RH.tblEmpleadosMaster eEvaluador on eEvaluador.IDEmpleado = ee.IDEvaluador
	left join RH.tblCatDepartamentos	dEvaluador on dEvaluador.IDDepartamento = eEvaluador.IDDepartamento
	left join RH.tblCatSucursales		sEvaluador on sEvaluador.IDSucursal = eEvaluador.IDSucursal
	left join RH.tblCatPuestos			puEvaluador on puEvaluador.IDPuesto = eEvaluador.IDPuesto
	left join RH.tblCatDivisiones		divEvaluador on divEvaluador.IDDivision = eEvaluador.IDDivision

	left join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = pre.IDPregunta
	left join bk.tempPreguntasIndicadores indicadores on App.fnRemoveVarcharSpace(indicadores.Pregunta)= App.fnRemoveVarcharSpace(pre.Descripcion)
where p.IDProyecto in (
		20,
		21,
		22,
		23
	)
--and g.IDTipoGrupo <> 3
--and indicadores.Indicador is null
--and g.MaximaCalificacionPosible = 5
--2. LA ORGANIZACIÓN CUMPLE CON LO QUE PROMETE. 
--SATISFACCIÓN EN EL PUESTO: COMPATIBILIDAD DE LAS FUNCIONES DEL PUESTO CON LAS MOTIVACIONES DEL  COLABORADOR

GO
