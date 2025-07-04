USE [p_adagioRHIndustrialMefi]
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

    DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	if exists (select top 1 1 
				from  Seguridad.tblPermisosPerfilesControllers
				where IDPerfil = @IDPerfil and IDController= @IDController)
	begin
        Select @OldJSON = (SELECT * FROM Seguridad.tblPermisosPerfilesControllers WHERE IDPerfil = @IDPerfil and IDController= @IDController FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		update  Seguridad.tblPermisosPerfilesControllers
			set IDTipoPermiso = case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end
		where IDPerfil = @IDPerfil and IDController= @IDController

        
              Select @NewJSON = (SELECT * FROM Seguridad.tblPermisosPerfilesControllers WHERE IDPerfil = @IDPerfil and IDController= @IDController FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosPerfilesControllers]','[Seguridad].[spIUPermisosPerfilesControllers]','UPDATE',@NewJSON,@OldJSON

	end else
	begin
		insert into Seguridad.tblPermisosPerfilesControllers(IDPerfil,IDController,IDTipoPermiso)
		select @IDPerfil,@IDController,case when @IDTipoPermiso <> '0' then @IDTipoPermiso else null end

          Select @NewJSON = (SELECT * FROM Seguridad.tblPermisosPerfilesControllers WHERE IDPerfil = @IDPerfil and IDController= @IDController FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
          EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblPermisosPerfilesControllers]','[Seguridad].[spIUPermisosPerfilesControllers]','INSERT',@NewJSON,''

	end;
GO
