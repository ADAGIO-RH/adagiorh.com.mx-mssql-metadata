USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spBuscarCatTiposPreguntasGrupos](
	@IDTipoPreguntaGrupo int = 0
) as

	select *
	from [Evaluacion360].[tblCatTiposPreguntasGrupos]
	where (IDTipoPreguntaGrupo = @IDTipoPreguntaGrupo or @IDTipoPreguntaGrupo = 0)
	order by Orden
GO
