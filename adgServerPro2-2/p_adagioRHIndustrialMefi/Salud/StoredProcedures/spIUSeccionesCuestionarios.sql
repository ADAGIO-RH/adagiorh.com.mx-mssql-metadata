USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Salud.spIUSeccionesCuestionarios
(
	@IDSeccion int = 0,
	@IDCuestionario int,
	@Nombre Varchar(255),
	@Descripcion Varchar(max),
	@IDUsuario int
)
AS
BEGIN
SET @Nombre = Upper(@Nombre)
SET @Descripcion = Upper(@Descripcion)
	
	IF(@IDSeccion = 0)
	BEGIN
		insert into Salud.tblSecciones(IDCuestionario, Nombre,Descripcion,FechaCreacion,IDUsuario)
		Values(@IDCuestionario, @Nombre, @Descripcion, Getdate(), @IDUsuario)
		SET @IDSeccion = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE Salud.tblSecciones
			set Nombre = @Nombre,
				Descripcion = @Descripcion
		Where IDCuestionario = @IDCuestionario and IDSeccion = @IDSeccion
	END

	Exec Salud.spBuscarSeccionesCuestionarios @IDCuestionario = @IDCuestionario, @IDSeccion = @IDSeccion, @IDUsuario = @IDUsuario

END
GO
