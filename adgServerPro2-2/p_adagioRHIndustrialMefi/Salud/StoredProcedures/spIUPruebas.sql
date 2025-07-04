USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Salud].[spIUPruebas](
	@IDPrueba int = 0,
	@Nombre varchar(255),
	@Descripcion Varchar(max),
	@RevisionTemperatura bit = 0,
	@Liberado bit = 0,
	@IDUsuario int
)
AS
BEGIN

	select @Nombre = UPPER(@Nombre)
			,@Descripcion = UPPER(@Descripcion)

	IF(ISNULL(@IDPrueba,0) = 0)
	BEGIN
		INSERT INTO Salud.tblPruebas(
							Nombre
							,Descripcion
							,FechaCreacion
							,RevisionTemperatura
							,IDUsuario
							,Liberado)
			VALUES( @Nombre
					,@Descripcion
					,GETDATE()
					,@RevisionTemperatura
					,@IDUsuario
					,@Liberado)

			SET @IDPrueba = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE Salud.tblPruebas
			SET Nombre = @Nombre,
				Descripcion = @Descripcion,
				RevisionTemperatura = @RevisionTemperatura,
				Liberado = @Liberado
		WHERE IDPrueba = @IDPrueba
	END

	EXEC [Salud].[spBuscarPruebas] @IDPrueba = @IDPrueba
END;
GO
