USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: RestaurarPermisosPerfilUsuario
** Autor			: Julio Castillo
** Email			: jcastillo@adagio.com.mx
** FechaCreacion	: 2023-11-07
** Paremetros		:              
** Versión 1 

** DataTypes Relacionados: 

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2023-11-07          Julio Castillo      Este procedimiento tiene como funcion elmiminar cualquier permiso 
                                        PERSONALIZADO lo cual restablece los permisos al PERFIL que tenga
                                        asignado.  
    
***************************************************************************************************/
CREATE PROCEDURE [Seguridad].[spRestaurarPermisosPerfilUsuario] (  
	@IDUsuario int  
	,@IDPerfil int = null
    ,@IDUsuarioLogueado int
)  
AS  
begin  
   
	if (@IDPerfil is null) 
	begin
		select @IDPerfil = IDPerfil
		from [Seguridad].[tblUsuarios] with (nolock)
		where IDUsuario = @IDUsuario
	end;	
  DECLARE @OldJSON Varchar(Max);
	/* START PermisosUsuarioControllers */
Select @OldJSON = (SELECT PC.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosUsuarioControllers PC 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PC.IDUsuario  
                    WHERE PC.IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosUsuarioControllers]','[Seguridad].[spRestaurarPermisosPerfilUsuario]','DELETE','',@OldJSON
	
    delete Seguridad.tblPermisosUsuarioControllers 
	where IDUsuario = @IDUsuario 
	  --AND PermisoPersonalizado = 1

    /* END PermisosUsuarioControllers */

	/* START PermisosEspecialesUsuarios */
    Select @OldJSON =(SELECT PE.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosEspecialesUsuarios PE
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PE.IDUsuario  
                    WHERE PE.IDUsuario = @IDUsuario FOR JSON PATH)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosEspecialesUsuarios]','[Seguridad].[spRestaurarPermisosPerfilUsuario]','DELETE','',@OldJSON
	
	delete Seguridad.tblPermisosEspecialesUsuarios 
		where IDUsuario = @IDUsuario  
		  --AND PermisoPersonalizado = 1
  
    /* END PermisosEspecialesUsuarios */

	/* START AplicacionUsuario */
    Select @OldJSON = (SELECT AU.*, U.Nombre, u.Apellido FROM App.tblAplicacionUsuario AU 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =AU.IDUsuario  
                    WHERE AU.IDUsuario = @IDUsuario FOR JSON PATH)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[App].[tblAplicacionUsuario]','[Seguridad].[spRestaurarPermisosPerfilUsuario]','DELETE','',@OldJSON
	
	delete App.tblAplicacionUsuario 
	where IDUsuario = @IDUsuario  
      --AND AplicacionPersonalizada = 1
  

	/* END AplicacionUsuario */

	/* START PermisosReportesUsuarios */
    Select @OldJSON = (SELECT PR.*, U.Nombre, u.Apellido FROM Seguridad.tblPermisosReportesUsuarios PR 
                    inner join Seguridad.TblUsuarios U on U.IDUsuario =PR.IDUsuario  
                    WHERE PR.IDUsuario = @IDUsuario FOR JSON PATH)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogueado,'[Seguridad].[tblPermisosReportesUsuarios]','[Seguridad].[spRestaurarPermisosPerfilUsuario]','DELETE','',@OldJSON
	
	delete Seguridad.tblPermisosReportesUsuarios 
	where IDUsuario = @IDUsuario 
	  --and PermisoPersonalizado = 1
      
	/* END PermisosReportesUsuarios */


    
END
GO
