USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Evaluacion360].[spBuscarPlanDeAccion](
	 @IDPlanDeAccion int = 0
	,@IDEmpleadoProyecto int-- = 128
	,@IDUsuario int-- = 1
) as

	select 
		 pda.IDPlanDeAccion
		,pda.IDEmpleadoProyecto
		,pda.IDTipoGrupo
		,ctg.Nombre as TipoGrupo
		,pda.Grupo
		,pda.CalificacionActual
		,pda.Acciones
		,pda.ResultadoEsperado
		,isnull(pda.FechaCompromiso,getdate()) as FechaCompromiso
		,pda.IDUsuario
		,pda.FechaHora
	from Evaluacion360.tblPlanDeAccion pda with (nolock)
		JOIN Evaluacion360.tblCatTipoGrupo ctg with (nolock) on ctg.IDTipoGrupo = pda.IDTipoGrupo
	where pda.IDEmpleadoProyecto = @IDEmpleadoProyecto and (pda.IDPlanDeAccion = @IDPlanDeAccion or @IDPlanDeAccion = 0)
	order by ctg.Orden asc, pda.Grupo asc
GO
