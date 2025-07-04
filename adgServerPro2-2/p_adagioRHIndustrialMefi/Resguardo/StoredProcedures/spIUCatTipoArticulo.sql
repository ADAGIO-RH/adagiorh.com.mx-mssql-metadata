USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Resguardo].[spIUCatTipoArticulo](
	 @IDTipoArticulo int = 0
	,@Nombre varchar(100)
	,@Descripcion varchar(255)
	,@IDUsuario int
) as
	select 
		@Nombre = UPPER(@Nombre)
		,@Descripcion = UPPER(@Descripcion)

	if (@IDTipoArticulo = 0)
	begin
		insert [Resguardo].[tblCatTiposArticulos](Nombre,Descripcion)
		values(@Nombre,@Descripcion)

		set @IDTipoArticulo = @@IDENTITY
	end else
	begin
		update [Resguardo].[tblCatTiposArticulos]
			set
				Nombre = @Nombre
				,Descripcion = @Descripcion
		where IDTipoArticulo = @IDTipoArticulo
	end

	exec [Resguardo].[spBuscarCatTiposArticulos] @IDTipoArticulo=@IDTipoArticulo,@IDUsuario=@IDUsuario
GO
