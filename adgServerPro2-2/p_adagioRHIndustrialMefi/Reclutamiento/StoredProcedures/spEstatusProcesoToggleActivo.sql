USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create   proc [Reclutamiento].[spEstatusProcesoToggleActivo](
	@IDEstatusProceso int,
	@IDUsuario int
) as
	update [Reclutamiento].[tblCatEstatusProceso]
		set
			Activa = case when isnull(Activa, 0) = 1 then 0 else 1 end
	where IDEstatusProceso = @IDEstatusProceso
GO
