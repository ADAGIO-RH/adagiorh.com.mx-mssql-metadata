USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc App.spBuscarAdgFiles(
	@IDAdgFile int,
	@IDUsuario int = 0
) as

	select
		IDAdgFile
		,[name]
		,extension
		,pathFile
		,relativePath
		,downloadURL
		,requiereAutenticacion
	from App.tblAdgFiles
	where IDAdgFile = @IDAdgFile
GO
