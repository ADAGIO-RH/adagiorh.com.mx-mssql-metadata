USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Evaluacion360].[spBuscarEscalasValoracionGruposPorProyecto](
	@IDProyecto int
) as
	select evg.IDEscalaValoracionGrupo
		,evg.IDGrupo
		,evg.Nombre
		,evg.Descripcion
		,isnull(evg.Valor,0) as Valor
	from Evaluacion360.tblCatGrupos cg
		join [Evaluacion360].[tblEscalasValoracionesGrupos] evg on cg.IDGrupo = evg.IDGrupo
	where cg.TipoReferencia = 1 and cg.IDReferencia = @IDProyecto
		and cg.IDTipoPreguntaGrupo in (2,3)
GO
