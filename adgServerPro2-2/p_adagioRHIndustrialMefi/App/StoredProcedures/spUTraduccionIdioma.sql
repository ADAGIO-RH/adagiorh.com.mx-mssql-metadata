USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc App.spUTraduccionIdioma(
	@IDIdioma varchar(10),
	@Traduccion nvarchar(max),
	@IDUsuario int
) as
	if ISJSON(@Traduccion) = 0
	begin
		raiserror('La traducción no tiene un formato JSON válido', 16, 1)
		return
	end

	update App.tblIdiomas
		set
			Traduccion = @Traduccion
	where IDIdioma = @IDIdioma
GO
