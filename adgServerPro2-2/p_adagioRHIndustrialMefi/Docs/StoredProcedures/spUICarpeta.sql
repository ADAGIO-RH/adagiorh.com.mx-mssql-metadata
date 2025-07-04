USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spUICarpeta]
(
	 @IDItem int = 0
	,@TipoItem int
	,@IDParent int = 0
	,@Nombre Varchar(254)
	,@Descripcion Varchar(max) = null
	,@Icono Varchar(max) = null
	,@Color varchar(max) = null
	,@IDUsuario int
)
AS
BEGIN

SET @Nombre = UPPER(@Nombre);
SET @Descripcion = UPPER(@Descripcion);

	IF(isnull(@IDItem,0) = 0 )
	BEGIN
		Insert into Docs.tblCarpetasDocumentos(TipoItem,IDParent,Nombre, Descripcion, Icono, Color, IDAutor)
		Values(0,@IDParent,@Nombre, @Descripcion, @Icono, @Color, @IDUsuario)
		set @IDItem = @@IDENTITY
	END
	ELSE
	BEGIN
		Update Docs.tblCarpetasDocumentos
			set Nombre = @Nombre,
				IDParent = @IDParent,
				TipoItem = @TipoItem,
				Descripcion = @Descripcion,
				Icono = @Icono,
				Color = @Color,
				FechaUltimaActualizacion = getdate()
		where IDItem = @IDItem
	END

	
	Exec Docs.spBuscarCarpetasDocumentos @IDItem = @IDItem
END
GO
