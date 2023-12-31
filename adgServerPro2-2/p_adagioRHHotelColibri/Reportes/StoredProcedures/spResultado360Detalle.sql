USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   proc [Reportes].[spResultado360Detalle](
	@IDProyecto int,
	@IDUsuario int
) as
    SET NOCOUNT ON;  
     IF 1=0 BEGIN  
       SET FMTONLY OFF  
     END  

	--declare 
	--	@IDProyecto int = 24
	--;

	select 
		ee.IDTipoRelacion,
		tp.Relacion,
		ep.IDEmpleadoProyecto,
		colaborador.ClaveEmpleado,
		colaborador.NOMBRECOMPLETO as Colaborador,
		ep.IDEmpleado,
		ee.IDEvaluacionEmpleado,
		ee.IDEvaluador,
		evaluador.ClaveEmpleado as ClaveEvaluador,
		evaluador.NOMBRECOMPLETO as Evaluador,
		g.IDGrupo,
		g.Nombre as Grupo,
		p.Descripcion as Pregunta,
		rp.Respuesta,
		ValorFinal = case when rp.ValorFinal = -1 then null else rp.ValorFinal end
	from Evaluacion360.tblEmpleadosProyectos ep
		join RH.tblEmpleadosMaster colaborador on colaborador.IDEmpleado = ep.IDEmpleado
		join Evaluacion360.tblEvaluacionesEmpleados ee on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join RH.tblEmpleadosMaster evaluador on evaluador.IDEmpleado = ee.IDEvaluador
		join Evaluacion360.tblCatTiposRelaciones tp on tp.IDTipoRelacion = ee.IDTipoRelacion
		join Evaluacion360.tblCatGrupos g on g.IDReferencia = ee.IDEvaluacionEmpleado and g.TipoReferencia = 4
		join Evaluacion360.tblCatPreguntas p on p.IDGrupo = g.IDGrupo
		left join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
	where ep.IDProyecto = @IDProyecto --and ep.IDEmpleadoProyecto = 1427
GO
