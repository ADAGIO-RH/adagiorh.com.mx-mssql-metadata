USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spBuscarEscalasValoracionGruposPorEvaluacionEmpleado](
	@IDEvaluacionEmpleado int
) as

	declare @orderAsc bit = 0;

	select evg.IDEscalaValoracionGrupo
		,evg.IDGrupo
		,evg.Nombre
		,evg.Descripcion
		,isnull(evg.Valor,0) as Valor
	from Evaluacion360.tblCatGrupos cg
		join [Evaluacion360].[tblEscalasValoracionesGrupos] evg on cg.IDGrupo = evg.IDGrupo
	where cg.TipoReferencia = 4 and cg.IDReferencia = @IDEvaluacionEmpleado
		and cg.IDTipoPreguntaGrupo in (2,3)
	ORDER BY cg.IDGrupo,
	  CASE @orderAsc WHEN 1 THEN isnull(Valor,0) ELSE '' END ASC,
	  CASE @orderAsc WHEN 0 THEN isnull(Valor,0) ELSE '' END DESC
GO
