USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [APP].[spIUNavegadores](
	@IDNavegador INT = 0,
	@Codigo VARCHAR(20),
	@Nombre VARCHAR(30),
	@IDUsuario INT
)  
AS  
BEGIN  
  	
	DECLARE
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	SELECT
		@Codigo = UPPER(@Codigo),
		@Nombre = UPPER(@Nombre );

  	IF(@Codigo IS NULL)   
		BEGIN 
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302004'  
			RETURN 0;  
		END;  
  
	IF(@Nombre IS NULL)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302005'  
			RETURN 0;  
		END;  
	
	
	-- REGISTRAR NAVEGADOR
	IF(@IDNavegador = 0 OR @IDNavegador IS NULL)  
		BEGIN  
			IF EXISTS(SELECT TOP 1 1 FROM APP.[tblNavegadores] WHERE Codigo = @Codigo)  
			BEGIN  
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
				RETURN 0;  
			END  
  
			INSERT INTO [APP].[tblNavegadores](  
				[Codigo],
				[Nombre] 
		   )  
			VALUES (  
				@Codigo,
				@Nombre  
		   )  
    
			SET @IDNavegador = @@identity  

			SELECT @NewJSON = a.JSON FROM [APP].[tblNavegadores] b
			CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (Select b.* For XML Raw)) ) a
			WHERE b.IDNavegador = @IDNavegador

			EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[APP].[tblNavegadores]', '[APP].[spIUNavegadores]', 'INSERT', @NewJSON, ''
		END  
	ELSE  
	-- ACTUALIZAR NAVEGADOR
	BEGIN  
		IF EXISTS(SELECT TOP 1 1 FROM APP.[tblNavegadores] WHERE Codigo = @Codigo AND IDNavegador <> @IDNavegador)  
		BEGIN  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'  
			RETURN 0;  
		END  

		SELECT @OldJSON = a.JSON FROM [APP].[tblNavegadores] b
		CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (Select b.* For XML Raw)) ) a
		WHERE b.IDNavegador = @IDNavegador

		UPDATE [APP].[tblNavegadores]  
		SET  
			[Codigo] = @Codigo,
			[Nombre] = @Nombre
		WHERE [IDNavegador] = @IDNavegador  
  	
		SELECT @NewJSON = a.JSON FROM [APP].[tblNavegadores] b
		CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (Select b.* For XML Raw)) ) a
		WHERE b.IDNavegador = @IDNavegador

		EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[APP].[tblNavegadores]', '[APP].[spIUNavegadores]', 'UPDATE', @NewJSON, @OldJSON
	END  
	

	/*
	exec [RH].[spBuscarCatSucursales] @IDSucursal=@IDSucursal, @IDUsuario=@IDUsuario

	EXEC [Seguridad].[spIUFiltrosUsuarios] 
		 @IDFiltrosUsuarios = 0  
		 ,@IDUsuario = @IDUsuario   
		 ,@Filtro = 'Sucursales'  
		 ,@ID = @IDSucursal   
		 ,@Descripcion = @Descripcion
		 ,@IDUsuarioLogin = @IDUsuario 

	exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuario 
	*/
  
END
GO
