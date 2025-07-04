USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spIUCatTipoArticulo](@IDTipoArticulo int          = 0
										   ,@Nombre         varchar(255)
										   ,@Descripcion    varchar(500)
										   ,@Disponible     bit          = 0
										   ,@IDUsuario      int
										   )
as
	select 
		@Nombre = upper(@Nombre)
		,@Descripcion = upper(@Descripcion);

	if (isnull(@IDTipoArticulo,0) = 0)
	begin
		insert into [Comedor].[TblCatTiposArticulos](
			[Nombre]
			,[Descripcion]
			,[Disponible]
			,[Fechahora])
		select 
			@Nombre
			,@Descripcion
			,@Disponible
			,getdate()

		set @IDTipoArticulo = @@Identity
	end
	else
	begin
		update [Comedor].[tblCatTiposArticulos]
			set 
				[Nombre] = @Nombre,
				[Descripcion] = @Descripcion,
				[Disponible] = @Disponible 
		where [IDTipoArticulo] = @IDTipoArticulo
	end;

	select @IDTipoArticulo as [IDTipoArticulo]
GO
