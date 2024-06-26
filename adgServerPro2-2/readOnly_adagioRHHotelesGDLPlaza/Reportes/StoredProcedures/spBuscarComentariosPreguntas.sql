USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spBuscarComentariosPreguntas](
	@IDEmpleadoProyecto int 
) as
--declare
--	@IDProyecto int = 64
--	,@IDEmpleadoProyecto int = 42282
--	;

	declare @dtUsuarios [Seguridad].[dtUsuarios]

	insert @dtUsuarios
	exec [Seguridad].[spBuscarUsuario]

	--select * from @dtUsuarios
	--select * from Evaluacion360.tblCatProyectos

select 
	coalesce(ctr.Relacion,'')+': '+pre.Descripcion as Pregunta
	--,ctr.Relacion
	--,u.Nombre
	,CreadoPor = coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'')--+' ('+coalesce(ctr.Relacion,'')+')'
	,cp.Comentario
	,ctr.Relacion
from Evaluacion360.tblEmpleadosProyectos p 
	join Evaluacion360.tblEvaluacionesEmpleados ee on p.IDEmpleadoProyecto = ee.IDEmpleadoProyecto
	join [Evaluacion360].[tblCatGrupos] g on g.TipoReferencia = 4 and g.IDReferencia = ee.IDEvaluacionEmpleado
	join [Evaluacion360].[tblCatPreguntas] pre on pre.IDGrupo = g.IDGrupo
	join [Evaluacion360].[tblComentariosPregunta] cp on cp.IDPregunta = pre.IDPregunta
	join [Evaluacion360].[tblCatTiposRelaciones] ctr on ee.IDTipoRelacion = ctr.IDTipoRelacion
	join @dtUsuarios u on cp.IDUsuario = u.IDUsuario
where p.IDEmpleadoProyecto = @IDEmpleadoProyecto
order by pre.Descripcion asc
GO
