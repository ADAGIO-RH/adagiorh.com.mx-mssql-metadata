USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--===============================================
 --Tipo Referencia
 -- 0: Cuestionarios Default
 -- 1: IDPrueba
 -- 2: IDPruebaEmpleado
--===============================================


CREATE PROCEDURE [Salud].[spIUCuestionarios]
(
	@IDCuestionario int = 0,
	@Nombre Varchar(255),
	@Descripcion Varchar(MAX) = '',
	@TipoReferencia int = 0,
	@IDReferencia int = 0,
	@isDefault bit = 0,
	@IDUsuario int
)
AS
BEGIN
set @Nombre = UPPER(@Nombre)
set @Descripcion = UPPER(@Descripcion)

	IF(@IDCuestionario = 0)
	BEGIN
		INSERT INTO  Salud.tblCuestionarios (Nombre, Descripcion, TipoReferencia, IDReferencia, isDefault, IDUsuario, FechaCreacion)
		VALUES(@Nombre, @Descripcion, @TipoReferencia, @IDReferencia, @isDefault, @IDUsuario, GETDATE())

		set @IDCuestionario = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE Salud.tblCuestionarios
			SET Nombre = @Nombre,
				Descripcion = Descripcion,
				TipoReferencia = @TipoReferencia,
				IDReferencia = @IDReferencia,
				isDefault = @isDefault
		WHERE IDCuestionario = @IDCuestionario
	END

	Exec Salud.spBuscarCuestionarioPrueba @IDCuestionario = @IDCuestionario,@IDUsuario=@IDUsuario
	
END;
GO
