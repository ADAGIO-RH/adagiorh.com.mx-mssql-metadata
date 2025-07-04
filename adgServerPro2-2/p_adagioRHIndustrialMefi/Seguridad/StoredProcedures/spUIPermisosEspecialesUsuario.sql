USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spUIPermisosEspecialesUsuario]--  1,1
(
	@IDUsuario int
	,@IDUsuarioLogin int
	,@IDPermiso int
	,@PermisoPersonalizado bit = 0
)
AS
BEGIN
    DECLARE @NewJSON Varchar(Max),
    @CodigoParent varchar(255) = (Select CodigoParent from App.tblCatPermisosEspeciales where IDPermiso = @IDPermiso)



	if not exists(select 1 from Seguridad.tblPermisosEspecialesUsuarios where IDUsuario = @IDUsuario and IDPermiso = @IDPermiso)
	Begin

        IF(@CodigoParent is null OR (Select ISNULL(TienePermiso,0) from Seguridad.vwPermisosEspecialesUsuarios peu where IDUsuario = @IDUsuario and codigoPermiso = @CodigoParent) = 1)
        BEGIN   
                 
                insert into Seguridad.tblPermisosEspecialesUsuarios(IDUsuario,IDPermiso,PermisoPersonalizado)
                select @IDUsuario,@IDPermiso,@PermisoPersonalizado

                Select @NewJSON = (SELECT PE.*, U.IDEmpleado,U.Nombre, u.Apellido FROM Seguridad.tblPermisosEspecialesUsuarios PE 
                            inner join Seguridad.TblUsuarios U on U.IDUsuario =PE.IDUsuario  
                            WHERE PE.IDUsuario = @IDUsuario and PE.IDPermiso = @IDPermiso FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

            EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[Seguridad].[tblPermisosEspecialesUsuarios]','[Seguridad].[spUIPermisosEspecialesUsuario]','INSERT',@NewJSON,''
        END
        ELSE RAISERROR('El Permiso leleccionado depende de su permiso padre', 16,1)
	END
END
GO
