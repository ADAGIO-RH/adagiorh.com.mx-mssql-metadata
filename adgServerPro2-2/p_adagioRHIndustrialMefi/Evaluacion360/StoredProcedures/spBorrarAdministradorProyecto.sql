USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Evaluacion360.spBorrarAdministradorProyecto(
	@IDAdministradorProyecto int = 0
	,@IDUsuario				 int
) as
	delete Evaluacion360.tblAdministradoresProyecto
	where IDAdministradorProyecto = @IDAdministradorProyecto
GO
