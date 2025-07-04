USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comedor].[spIUCatCategoria](@IDCategoria int = 0
										,@Nombre      varchar(250)
										,@IDUsuario   int)
as
	select 
		@Nombre = upper(@Nombre)
	;

	if (isnull(@IDCategoria,0) = 0)
	begin
		insert into [Comedor].[TblCatCategorias]([Nombre])
		select 
			@Nombre

		set @IDCategoria = @@Identity
	end
	else
	begin
		update [Comedor].[TblCatCategorias]
			set [Nombre] = @Nombre
		where [IDCategoria] = @IDCategoria
	end;

	select @IDCategoria as [IDCategoria]
GO
