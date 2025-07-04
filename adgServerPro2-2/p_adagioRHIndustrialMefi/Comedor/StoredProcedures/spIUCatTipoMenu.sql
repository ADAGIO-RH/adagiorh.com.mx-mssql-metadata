USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spIUCatTipoMenu](@IDTipoMenu               int          = 0
									   ,@Nombre                   varchar(255)
									   ,@Descripcion              varchar(500)
									   ,@HoraDisponibilidadInicio time
									   ,@HoraDisponibilidadFin    time
									   ,@Disponible               bit          = 0
									   ,@IDUsuario                int
									   )
as
	 select 
		@Nombre = upper(@Nombre)
		,@Descripcion = upper(@Descripcion);

	if(isnull(@IDTipoMenu,0) = 0)
	begin
		insert into [Comedor].[tblCatTiposMenus](
			[Nombre]
			,[Descripcion]
			,[Horadisponibilidadinicio]
			,[Horadisponibilidadfin]
			,[Disponible]
			,[Fechahora])
		select 
			@Nombre
			,@Descripcion
			,@HoraDisponibilidadInicio
			,@HoraDisponibilidadFin
			,@Disponible
			,getdate();

		set @IDTipoMenu = @@Identity
	end;
	else
	begin
		update [Comedor].[tblCatTiposMenus]
		set 
			[Nombre] = @Nombre,
			[Descripcion] = @Descripcion,
			[Horadisponibilidadinicio] = @HoraDisponibilidadInicio,
			[Horadisponibilidadfin] = @HoraDisponibilidadFin,
			[Disponible] = @Disponible
		where 
			[IDTipoMenu] = @IDTipoMenu;
	end;

	select @IDTipoMenu as IDTipoMenu
GO
