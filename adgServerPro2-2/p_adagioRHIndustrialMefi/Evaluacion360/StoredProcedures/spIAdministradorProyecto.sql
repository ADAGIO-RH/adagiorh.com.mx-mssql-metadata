USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Evaluacion360].[spIAdministradorProyecto](
	@IDProyecto	int
	,@IDUsuario	int
	,@IDUsuarioCrea	int
) as

	if exists(select top 1 1
			from Evaluacion360.tblAdministradoresProyecto
			where IDProyecto = @IDProyecto and IDUsuario = @IDUsuario)
	begin
		raiserror('El usuario ya existe como editor de la prueba', 16, 1)
		return
	end

	insert Evaluacion360.tblAdministradoresProyecto(
		IDProyecto
		,IDUsuario
		,CreadoPorIDUsuario
	)
	values(@IDProyecto, @IDUsuario, @IDUsuarioCrea)
GO
