USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Seguridad.spIUCatFiltroUsuario(
	 @IDCatFiltroUsuario int = 0	
	,@IDUsuario int			
	,@Nombre varchar(255)	
	,@IDUsuarioCreo int		
) as

	if (ISNULL(@IDCatFiltroUsuario,0) = 0)
	begin
		insert Seguridad.tblCatFiltrosUsuarios(IDUsuario,Nombre,IDUsuarioCreo)
		values (@IDUsuario,@Nombre,@IDUsuarioCreo)

		set @IDCatFiltroUsuario = @@IDENTITY
	end else
	begin
		update Seguridad.tblCatFiltrosUsuarios
			set Nombre = @Nombre
		where IDCatFiltroUsuario = @IDCatFiltroUsuario
	end;

	exec Seguridad.spBuscarCatFiltrosUsuario @IDCatFiltroUsuario = @IDCatFiltroUsuario, @IDUsuario = @IDUsuario
GO
