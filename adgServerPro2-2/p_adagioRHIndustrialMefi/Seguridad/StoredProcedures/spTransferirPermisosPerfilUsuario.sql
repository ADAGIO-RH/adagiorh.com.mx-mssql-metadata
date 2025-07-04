USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spTransferirPermisosPerfilUsuario] (  
	@IDUsuario int  
	,@IDUsuarioLogueado int  
	,@IDPerfil int = null
)  
AS  
begin  
   
	if (@IDPerfil is null) 
	begin
		select @IDPerfil = IDPerfil
		from [Seguridad].[tblUsuarios] with (nolock)
		where IDUsuario = @IDUsuario
	end;	

DECLARE @OldJSON Varchar(Max),
            @NewJSON Varchar(Max);

	/* START PermisosUsuarioControllers */
        Select @OldJSON = (SELECT PC.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosUsuarioControllers PC 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PC.IDUsuario  
                    WHERE PC.IDUsuario = @IDUsuario FOR JSON PATH)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosUsuarioControllers]','[Seguridad].[spTransferirPermisosPerfilUsuario]','DELETE','',@OldJSON

	delete Seguridad.tblPermisosUsuarioControllers 
	where IDUsuario = @IDUsuario 
	  AND PermisoPersonalizado <> 1
  
	insert into Seguridad.tblPermisosUsuarioControllers(IDUsuario,IDController,IDTipoPermiso)  
	select @IDUsuario,tppc.IDController,tppc.IDTipoPermiso   
	from Seguridad.tblPermisosPerfilesControllers  tppc
	where tppc.IDPerfil = @IDPerfil  
	  AND tppc.IDController NOT IN (
									select tpuc.IDController 
									from [Seguridad].[tblPermisosUsuarioControllers] tpuc
									where tpuc.IDController = tppc.IDController
										--and tpuc.PermisoPersonalizado = 1
										and tpuc.IDUsuario = @IDUsuario 
								    ) 

     Select @NewJSON =(SELECT PC.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosUsuarioControllers PC 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PC.IDUsuario  
                    WHERE PC.IDUsuario = @IDUsuario FOR JSON PATH)

        EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosUsuarioControllers]','[Seguridad].[spTransferirPermisosPerfilUsuario]','INSERT',@NewJSON,''

    /* END PermisosUsuarioControllers */

	/* START PermisosEspecialesUsuarios */
        Select @OldJSON =(SELECT PE.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosEspecialesUsuarios PE
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PE.IDUsuario  
                    WHERE PE.IDUsuario = @IDUsuario FOR JSON PATH)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosEspecialesUsuarios]','[Seguridad].[spRestaurarPermisosPerfilUsuario]','DELETE','',@OldJSON
	
	delete Seguridad.tblPermisosEspecialesUsuarios 
		where IDUsuario = @IDUsuario  
		  AND PermisoPersonalizado <> 1
  
	insert into Seguridad.tblPermisosEspecialesUsuarios(IDUsuario, IDPermiso)  
	select @IDUsuario,IDPermiso  
	from Seguridad.tblPermisosEspecialesPerfiles tpep
	where IDPerfil = @IDPerfil  
	  AND tpep.IDPermiso NOT IN (select tpeu.IDPermiso 
									from [Seguridad].[tblPermisosEspecialesUsuarios] tpeu
									where tpeu.IDPermiso = tpep.IDPermiso
										--and tpeu.PermisoPersonalizado = 1
										and tpeu.IDUsuario = @IDUsuario 
								 )

     Select @NewJSON = left ((SELECT PE.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosEspecialesUsuarios PE
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PE.IDUsuario  
                    WHERE PE.IDUsuario = @IDUsuario FOR JSON PATH),8000)

        EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosUsuarioControllers]','[Seguridad].[spTransferirPermisosPerfilUsuario]','INSERT',@NewJSON,''

    /* END PermisosEspecialesUsuarios */

	/* START AplicacionUsuario */

            Select @OldJSON =  (SELECT AU.*, U.Nombre, u.Apellido FROM App.tblAplicacionUsuario AU 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =AU.IDUsuario  
                    WHERE AU.IDUsuario = @IDUsuario FOR JSON PATH)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[App].[tblAplicacionUsuario]','[Seguridad].[spRestaurarPermisosPerfilUsuario]','DELETE','',@OldJSON
	

	delete App.tblAplicacionUsuario 
	where IDUsuario = @IDUsuario  
      AND AplicacionPersonalizada <> 1
  
	insert into App.tblAplicacionUsuario(IDAplicacion,IDUsuario)  
	select IDAplicacion,@IDUsuario  
	from App.tblAplicacionPerfiles tap
	where IDPerfil = @IDPerfil  
	  AND tap.IDAplicacion NOT IN (select tau.IDAplicacion 
									from App.tblAplicacionUsuario tau
									where tau.IDAplicacion = tap.IDAplicacion
										--and tau.AplicacionPersonalizada = 1
										and tau.IDUsuario = @IDUsuario 
								 )

     Select @NewJSON =  (SELECT AU.*, U.Nombre, u.Apellido FROM App.tblAplicacionUsuario AU 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =AU.IDUsuario  
                    WHERE AU.IDUsuario = @IDUsuario FOR JSON PATH)

        EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[App].[tblAplicacionUsuario]','[Seguridad].[spTransferirPermisosPerfilUsuario]','INSERT',@NewJSON,''

	/* END AplicacionUsuario */

	/* START PermisosReportesUsuarios */
                Select @OldJSON = (SELECT PR.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosReportesUsuarios PR 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PR.IDUsuario  
                    WHERE PR.IDUsuario = @IDUsuario FOR JSON PATH)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosReportesUsuarios]','[Seguridad].[spRestaurarPermisosPerfilUsuario]','DELETE','',@OldJSON
	
	delete Seguridad.tblPermisosReportesUsuarios 
	where IDUsuario = @IDUsuario 
	  and PermisoPersonalizado <> 1

	insert into Seguridad.tblPermisosReportesUsuarios(IDReporteBasico,IDUsuario,Acceso)
	select prp.IDReporteBasico,@IDUsuario,1
	From Seguridad.tblPermisosReportesPerfiles prp
	where IDPerfil = @IDPerfil AND prp.IDReporteBasico NOT IN (
									select pru.IDReporteBasico 
									from [Seguridad].tblPermisosReportesUsuarios pru
									where pru.IDUsuario = @IDUsuario 
									--and pru.PermisoPersonalizado = 1
										 
								) 

         Select @NewJSON = (SELECT PR.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosReportesUsuarios PR 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PR.IDUsuario  
                    WHERE PR.IDUsuario = @IDUsuario FOR JSON PATH)

        EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosReportesUsuarios]','[Seguridad].[spTransferirPermisosPerfilUsuario]','INSERT',@NewJSON,''

	/* END PermisosReportesUsuarios */
END
GO
