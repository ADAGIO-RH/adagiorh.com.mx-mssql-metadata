USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Seguridad].[spTransferirPermisosPerfilUsuario] (  
	@IDUsuario int  
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

	/* START PermisosUsuarioControllers */
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
    /* END PermisosUsuarioControllers */

	/* START PermisosEspecialesUsuarios */
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

    /* END PermisosEspecialesUsuarios */

	/* START AplicacionUsuario */
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

	/* END AplicacionUsuario */

	/* START PermisosReportesUsuarios */
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
	/* END PermisosReportesUsuarios */
END
GO
