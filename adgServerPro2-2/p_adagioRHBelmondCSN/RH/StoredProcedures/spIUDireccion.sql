USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [RH].[spIUDireccion](
	@IDDireccion	INT = 0,
	@Codigo			VARCHAR(20),
	@Descripcion	VARCHAR(50),
	@CuentaContable VARCHAR(50),
	@IDUsuario		INT
)
AS
BEGIN
	
	SET @Codigo         = UPPER(@Codigo)
	SET @Descripcion	= UPPER(@Descripcion)
	SET @CuentaContable	= UPPER(@CuentaContable)
	
	DECLARE @OldJSON VARCHAR(MAX),
			@NewJSON VARCHAR(MAX);

	IF(@IDDireccion = 0)
		BEGIN			
			
			IF EXISTS(SELECT TOP 1 1 FROM [RH].[tblCatDirecciones] WHERE Codigo = @Codigo)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
				RETURN 0;
			END

			INSERT INTO [RH].[tblCatDirecciones] VALUES(@Codigo, @Descripcion, @CuentaContable)
			SET @IDDireccion = @@IDENTITY

			SELECT @NewJSON = a.JSON FROM [RH].[tblCatDirecciones] b
			CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
			WHERE b.IDDireccion = @IDDireccion;

			EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[RH].[tblCatDirecciones]', '[RH].[spIUDireccion]', 'INSERT', @NewJSON, '';
			
		END
	ELSE
		BEGIN

			IF EXISTS(SELECT TOP 1 1 FROM [RH].[tblCatDirecciones] WHERE IDDireccion <> @IDDireccion AND Codigo = @Codigo)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
				RETURN 0;
			END

			SELECT @OldJSON = a.JSON FROM [RH].[tblCatDirecciones] b
			CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
			WHERE b.IDDireccion = @IDDireccion;

			UPDATE [RH].[tblCatDirecciones]
				SET Codigo = @Codigo,
					Descripcion = @Descripcion,
					CuentaContable = @CuentaContable
				WHERE IDDireccion = @IDDireccion

			SELECT @NewJSON = a.JSON FROM [RH].[tblCatDirecciones] b
			CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
			WHERE b.IDDireccion = @IDDireccion;

			EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[RH].[tblCatDirecciones]', '[RH].[spIUDireccion]', 'UPDATE', @NewJSON, @OldJSON
			
		END
END
GO
