USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [Nomina].[spIUTabuladorNivelSalarialCompensaciones]
(
	 @IDTabuladorNivelSalarialCompensaciones int = 0
	,@Ejercicio int
	,@Descripcion varchar(max)
	,@IDUsuario int
) AS
BEGIN
	DECLARE 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP varchar(max) = '[Nomina].[spIUTabuladorNivelSalarialCompensaciones]',
		@Tabla varchar(max) = '[Nomina].[tblTabuladorNivelSalarialCompensaciones]',
		@Accion varchar(20) = '';

	SET @Descripcion = UPPER(@Descripcion);

	IF (@IDTabuladorNivelSalarialCompensaciones = 0 OR @IDTabuladorNivelSalarialCompensaciones IS NULL)
	BEGIN
        IF EXISTS(SELECT TOP 1 1 FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones] WHERE Ejercicio = @Ejercicio)
        BEGIN
            
            RAISERROR('El valor de Ejercicio ya existe. No se puede insertar el mismo valor.', 16, 1);
            RETURN;  
        END

		INSERT INTO [Nomina].[tblTabuladorNivelSalarialCompensaciones] (Ejercicio, Descripcion)
		VALUES (@Ejercicio, @Descripcion);

		SELECT @IDTabuladorNivelSalarialCompensaciones = @@IDENTITY;

		SELECT @NewJSON = a.JSON,
			   @Accion = 'INSERT'
		FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones] b
			CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
		WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;
	END
	ELSE
	BEGIN
		
		SELECT @OldJSON = a.JSON,
			   @Accion = 'UPDATE'
		FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones] b
			CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
		WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;


		UPDATE [Nomina].[tblTabuladorNivelSalarialCompensaciones]
		SET Ejercicio   = @Ejercicio,
			Descripcion = @Descripcion
		WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;
		
		SELECT @NewJSON = a.JSON
		FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones] b
			CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
		WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;
	END;

	
	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario      = @IDUsuario,
		@Tabla          = @Tabla,
		@Procedimiento  = @NombreSP,
		@Accion         = @Accion,
		@NewData        = @NewJSON,
		@OldData        = @OldJSON;

	
	SELECT * 
	FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones]
	WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;
END;
GO
