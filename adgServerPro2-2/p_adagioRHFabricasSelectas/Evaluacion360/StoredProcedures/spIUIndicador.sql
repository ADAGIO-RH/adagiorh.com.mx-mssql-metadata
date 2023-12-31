USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc Evaluacion360.spIUIndicador(
	 @IDIndicador	int = 0
	,@Nombre		varchar(255)
	,@Descripcion	varchar(max)
	,@IsDefault		bit
	,@NombreIcono	varchar(255)
	,@IDUsuario int
) as

	if (isnull(@IDIndicador, 0) = 0)
	begin
		insert Evaluacion360.tblCatIndicadores(Nombre, Descripcion, IsDefault, NombreIcono)
		values(@Nombre, @Descripcion, isnull(@IsDefault, 0), @NombreIcono)
	end else
	begin
		update Evaluacion360.tblCatIndicadores
			set
				Nombre = @Nombre,
				Descripcion = @Descripcion,
				NombreIcono = @NombreIcono
		where IDIndicador = @IDIndicador
	end
GO
