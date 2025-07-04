USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Evaluacion360].[spIUDetalleEscalaValoracion]
(
	@IDDetalleEscalaValoracion	INT	= 0
	, @IDEscalaValoracion		INT	 
	, @Nombre					VARCHAR(100)
	, @Valor					DECIMAL(18,2)
	, @IDUsuario				INT
) AS
	
	SET @Nombre = UPPER(@Nombre);

	IF(@IDDetalleEscalaValoracion = 0)
		BEGIN

			IF EXISTS
			(
				SELECT TOP 1 1 
				FROM [Evaluacion360].[tblDetalleEscalaValoracion] 
				WHERE IDEscalaValoracion = @IDEscalaValoracion AND (Nombre = @Nombre OR Valor = @Valor)
			)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003', @CustomMessage= 'El Nombre y el Valor no se puede repetir.'
				RETURN 0;
			END;
		 
			INSERT INTO [Evaluacion360].[tblDetalleEscalaValoracion](IDEscalaValoracion, Nombre, Valor)
			SELECT @IDEscalaValoracion, @Nombre, @Valor
		
			SELECT @IDDetalleEscalaValoracion = @@IDENTITY

		END
	ELSE
		BEGIN

			IF EXISTS
			(
				SELECT TOP 1 1 
				FROM [Evaluacion360].[tblDetalleEscalaValoracion]
				WHERE IDEscalaValoracion = @IDEscalaValoracion 
						AND (Nombre = @Nombre OR Valor = @Valor) 
						AND IDDetalleEscalaValoracion <> @IDDetalleEscalaValoracion
			)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003', @CustomMessage= 'El Nombre y el Valor no se puede repetir.'
				RETURN 0;
			END;

			UPDATE [Evaluacion360].[tblDetalleEscalaValoracion]
			SET Nombre = @Nombre
				, Valor = @Valor
			WHERE IDDetalleEscalaValoracion = @IDDetalleEscalaValoracion
		END;


	EXEC [Evaluacion360].[spBuscarDetalleEscalaValoracion] @IDDetalleEscalaValoracion = @IDDetalleEscalaValoracion
GO
