USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc App.spIUIdioma(
	 @IDIdioma		varchar	(10	) = null
	,@Idioma		varchar	(50	)
	,@SQL			varchar	(100)
	,@Traduccion	nvarchar(max)
	,@Orden			int = null
	,@Activo		bit 
	,@IDUsuario		int
) as

	if not exists(
		select top 1 1
		from App.tblIdiomas
		where IDIdioma = @IDIdioma
	)
	begin
		if (@Orden is null)
			set @Orden = (select max(Orden) + 1 from App.tblIdiomas)

		insert App.tblIdiomas(IDIdioma, Idioma, [SQL], Traduccion, Orden, Activo)
		select @IDIdioma, @Idioma, @SQL, @Traduccion, @Orden, @Activo
	end else
	begin
		update App.tblIdiomas
			set
				Idioma = @Idioma,
				[SQL] = @SQL,
				Traduccion = @Traduccion,
				Orden = @Orden,
				Activo = @Activo
		where IDIdioma = @IDIdioma
	end
GO
