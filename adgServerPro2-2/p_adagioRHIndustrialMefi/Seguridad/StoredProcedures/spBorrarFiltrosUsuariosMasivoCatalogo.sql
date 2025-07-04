USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo](    
  @IDFiltrosUsuarios int    
 ,@IDUsuario int     
 ,@Filtro varchar(255)     
 ,@ID varchar(255)     
 ,@Descripcion varchar(255)    
 ,@IDUsuarioLogin int    
) as    
 begin   
    
  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

    Select @OldJSON = (SELECT * FROM Seguridad.tblFiltrosUsuarios WHERE IDFiltrosUsuarios = @IDFiltrosUsuarios FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[Seguridad].[tblFiltrosUsuarios]','[Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo]','DELETE',@NewJSON,@OldJSON
 BEGIN TRY  
	   DELETE Seguridad.tblFiltrosUsuarios
		where Filtro = @Filtro
		and ID = @ID  
    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;

EXEC Seguridad.spSchedulerActualizarFiltrosUsuarios @IDUsuario = @IDUsuarioLogin
      
   
end
GO
