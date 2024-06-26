USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarPermisoEspecialUsuarioPorCodigo](
	@CodigoPermiso varchar(100),
	@IDUsuario int
) as
	if exists (select top 1 1
				from Seguridad.tblPermisosEspecialesUsuarios peu with (nolock)
					join App.tblCatPermisosEspeciales cpe with (nolock) on cpe.IDPermiso = peu.IDPermiso
				where peu.IDUsuario = @IDUsuario and cpe.Codigo = @CodigoPermiso)
	begin
		select @CodigoPermiso as CodigoPermiso
			,@IDUsuario as IDUsuario
			,cast(1 as bit) TienePermiso
	end else 
	begin 
		select @CodigoPermiso as CodigoPermiso
			,@IDUsuario as IDUsuario
			,cast(0 as bit) TienePermiso
	end
GO
