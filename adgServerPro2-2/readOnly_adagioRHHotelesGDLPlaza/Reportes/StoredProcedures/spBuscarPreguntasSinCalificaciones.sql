USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





create proc Reportes.spBuscarPreguntasSinCalificaciones (
	@IDEmpleadoProyecto int
) as
--declare @IDEmpleadoProyecto int = 42303

--;

select cg.Nombre
	,ee.IDTipoRelacion
	,tp.Relacion
	, p.Descripcion as Pregunta
	,Respuesta = case 
					when p.IDTipoPregunta in (2,5) then prp.OpcionRespuesta
					when p.IDTipoPregunta = 3 then coalesce(rp.Respuesta,'0')+' de '+coalesce(prp3.OpcionRespuesta,'0')+' estrellas'
					when p.IDTipoPregunta = 6 then coalesce(rp.Respuesta,'0')+' de 100'
					 else rp.Respuesta end 
	--,p.IDTipoPregunta
	--,prp3.OpcionRespuesta
--	,p.IDPregunta
from [Evaluacion360].tblEvaluacionesEmpleados ee
	join Evaluacion360.tblCatTiposRelaciones tp on tp.IDTipoRelacion = ee.IDTipoRelacion
	join Evaluacion360.tblCatGrupos cg on cg.IDReferencia = ee.IDEvaluacionEmpleado and cg.TipoReferencia = 4
	join Evaluacion360.tblCatPreguntas p on p.IDGrupo = cg.IDGrupo
	join Evaluacion360.tblRespuestasPreguntas rp on rp.IDPregunta = p.IDPregunta
	left join Evaluacion360.tblPosiblesRespuestasPreguntas prp on prp.IDPregunta = p.IDPregunta and prp.IDPosibleRespuesta = case when p.IDTipoPregunta in (2,3,5) then rp.Respuesta else 0 end
	left join Evaluacion360.tblPosiblesRespuestasPreguntas prp3 on prp3.IDPregunta = p.IDPregunta and p.IDTipoPregunta =3

where ee.IDEmpleadoProyecto = @IDEmpleadoProyecto and isnull(p.Calificar,0) = 0 and p.IDTipoPregunta not in (1,8,9)
order by p.Descripcion

--select * from Evaluacion360.tblPosiblesRespuestasPreguntas where IDPregunta = 5448

--select * from Evaluacion360.tblCatTiposDePreguntas
GO
