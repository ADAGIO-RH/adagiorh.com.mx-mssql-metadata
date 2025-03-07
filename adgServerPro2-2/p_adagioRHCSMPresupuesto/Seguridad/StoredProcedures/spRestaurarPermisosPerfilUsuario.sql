USE [p_adagioRHCSMPresupuesto]
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
	  AND PermisoPersonalizado = 1

    /* END PermisosUsuarioControllers */

	/* START PermisosEspecialesUsuarios */
	delete Seguridad.tblPermisosEspecialesUsuarios 
		where IDUsuario = @IDUsuario  
		  AND PermisoPersonalizado = 1
  
    /* END PermisosEspecialesUsuarios */

	/* START AplicacionUsuario */
	delete App.tblAplicacionUsuario 
	where IDUsuario = @IDUsuario  
      AND AplicacionPersonalizada = 1
  

	/* END AplicacionUsuario */

	/* START PermisosReportesUsuarios */
	delete Seguridad.tblPermisosReportesUsuarios 
	where IDUsuario = @IDUsuario 
	  and PermisoPersonalizado = 1
      
	/* END PermisosReportesUsuarios */
END
GO
