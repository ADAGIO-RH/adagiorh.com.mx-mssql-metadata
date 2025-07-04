USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [App].[spIUAplicacionUsuario](  
	 @IDUsuario int  
	,@IDAplicacion nvarchar(100)  
	,@Permiso bit  
	,@PermisoPersonalizado bit = null
    ,@IDUsuarioLogin int 
) as  

DECLARE 
		@OldJSON varchar(Max),
		@NewJSON varchar(Max),
		@IDIdioma varchar(20)
	;

	IF EXISTS (SELECT TOP 1 1   
				FROM [App].[tblAplicacionUsuario]   
				WHERE IDUsuario = @IDUsuario AND IDAplicacion = @IDAplicacion)  
	BEGIN  
		IF (@Permiso = 1)   
		BEGIN
            SELECT @OldJSON = (SELECT * FROM [App].[tblAplicacionUsuario] WHERE IDUsuario = @IDUsuario AND IDAplicacion = @IDAplicacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER); 

                INSERT INTO [App].[tblAplicacionUsuario](IDUsuario,IDAplicacion,AplicacionPersonalizada)  
                SELECT @IDUsuario, @IDAplicacion, @PermisoPersonalizado   

            SELECT @NewJSON = (SELECT * FROM [App].[tblAplicacionUsuario] WHERE IDUsuario = @IDUsuario AND IDAplicacion = @IDAplicacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);   
            EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[App].[tblAplicacionUsuario]','[App].[spIUAplicacionUsuario]','UPDATE',@NewJSON,@OldJSON
		END ELSE  
		BEGIN
            SELECT @OldJSON = (SELECT * FROM [App].[tblAplicacionUsuario] WHERE IDUsuario = @IDUsuario AND IDAplicacion = @IDAplicacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);  

                DELETE   
                FROM [App].[tblAplicacionUsuario]   
                WHERE IDUsuario = @IDUsuario AND IDAplicacion = @IDAplicacion  

            EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[App].[tblAplicacionUsuario]','[App].[spIUAplicacionUsuario]','DELETE','',@OldJSON
		END;  
	END ELSE  
	BEGIN  
		IF (@Permiso = 1)   
		BEGIN  
            
                INSERT INTO [App].[tblAplicacionUsuario](IDUsuario,IDAplicacion,AplicacionPersonalizada)  
                SELECT @IDUsuario, @IDAplicacion, @PermisoPersonalizado  

            SELECT @NewJSON = (SELECT * FROM [App].[tblAplicacionUsuario] WHERE IDUsuario = @IDUsuario AND IDAplicacion = @IDAplicacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);   
            EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[App].[tblAplicacionUsuario]','[App].[spIUAplicacionUsuario]','INSERT',@NewJSON,''
		END  
	END
GO
