USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Seguridad].[spIUPermisosPerfilesControllers](
	 @IDPerfil int 
	,@IDController int 
	,@IDTipoPermiso nvarchar(10) 
	,@IDUsuario int 
	) as

	if exists (select top 1 1 
				from  Seguridad.tblPermisosPerfilesControllers
				where IDPerfil = @IDPerfil and IDController= @IDController)
	begin
		update  Seguridad.tblPermisosPerfilesControllers
			set IDTipoPermiso = case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end
		where IDPerfil = @IDPerfil and IDController= @IDController
	end else
	begin
		insert into Seguridad.tblPermisosPerfilesControllers(IDPerfil,IDController,IDTipoPermiso)
		select @IDPerfil,@IDController,case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end
	end;
GO
