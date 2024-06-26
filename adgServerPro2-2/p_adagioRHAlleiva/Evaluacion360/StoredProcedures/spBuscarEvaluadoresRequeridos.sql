USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarEvaluadoresRequeridos](
	@IDEvaluadorRequerido int = 0
	,@IDProyecto int
) as

	select 
	er.IDEvaluadorRequerido
	,er.IDProyecto
	,er.IDTipoRelacion
	,ctr.Relacion
	,er.Minimo
	,er.Maximo
	from [Evaluacion360].[tblEvaluadoresRequeridos] er
		join  Evaluacion360.tblCatTiposRelaciones ctr on er.IDTipoRelacion = ctr.IDTipoRelacion
	where (er.IDProyecto = @IDProyecto or @IDProyecto = 0) and (er.IDEvaluadorRequerido = @IDEvaluadorRequerido or @IDEvaluadorRequerido = 0)
GO
