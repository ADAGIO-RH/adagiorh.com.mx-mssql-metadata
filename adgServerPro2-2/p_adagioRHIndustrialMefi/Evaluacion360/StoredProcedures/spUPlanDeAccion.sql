USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spUPlanDeAccion](
	@IDPlanDeAccion int
	,@Acciones varchar(max)
	,@ResultadoEsperado decimal(18,2)
	,@FechaCompromiso date
	,@IDUsuario int
) as
	update Evaluacion360.tblPlanDeAccion
		set Acciones			= upper(@Acciones)
			,ResultadoEsperado	= @ResultadoEsperado
			,FechaCompromiso	= @FechaCompromiso
	where IDPlanDeAccion = @IDPlanDeAccion
GO
