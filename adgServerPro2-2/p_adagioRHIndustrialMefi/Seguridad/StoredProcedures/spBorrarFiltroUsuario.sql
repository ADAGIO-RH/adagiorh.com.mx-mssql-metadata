USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBorrarFiltroUsuario](    
 @IDFiltrosUsuarios int    
 ,@IDUsuarioLogin int    
)    
as    
 declare @IDUsuario int = 0,
         @OldJSON Varchar(Max),
		 @NewJSON Varchar(Max);

  


 select @IDUsuario = IDUsuario    
 from [Seguridad].[tblFiltrosUsuarios]    
 where IDFiltrosUsuarios = @IDFiltrosUsuarios  
 
   Select @OldJSON = (SELECT FU.*, U.IDEmpleado,U.Nombre, u.Apellido FROM Seguridad.tblFiltrosUsuarios FU  
     inner join Seguridad.TblUsuarios U on U.IDUsuario =FU.IDUsuario   
                WHERE FU.IDUsuario = @IDUsuario AND IDFiltrosUsuarios = @IDFiltrosUsuarios FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
 EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[Seguridad].[tblFiltrosUsuarios]','[Seguridad].[spBorrarFiltroUsuario]','DELETE',@NewJSON,@OldJSON

  BEGIN TRY  
 Delete [Seguridad].[tblFiltrosUsuarios]
 where IDFiltrosUsuarios = @IDFiltrosUsuarios  
  END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;
 
        
 exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuarioLogin
GO
