USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
[Seguridad].[spBuscarPermisoEspecialUsuarioPorCodigo] 'CALENDARIO0009',5062
*/
CREATE proc [Seguridad].[spBuscarPermisoEspecialUsuarioPorCodigo](
	@CodigoPermiso varchar(100),
	@IDUsuario int
) as
	if exists (select top 1 1
				from [Seguridad].[vwPermisosEspecialesUsuarios] peu with (nolock)
					join App.tblCatPermisosEspeciales cpe with (nolock) on cpe.IDPermiso = peu.IDPermiso
				where peu.IDUsuario = @IDUsuario and peu.TienePermiso = 1 and cpe.Codigo = @CodigoPermiso )
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
