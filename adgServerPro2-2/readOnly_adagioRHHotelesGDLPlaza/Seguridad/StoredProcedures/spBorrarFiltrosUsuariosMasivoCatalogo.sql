USE [readOnly_adagioRHHotelesGDLPlaza]
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
