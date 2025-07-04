USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spUICatTiposDocumento]
(
	@IDTipoDocumento int = 0
	,@Descripcion Varchar(255)
	,@IDUsuario int
)
AS
BEGIN
set @Descripcion = UPPER(@Descripcion)
	IF(ISNULL(@IDTipoDocumento,0) = 0)
	BEGIN
		insert into Docs.tblCatTiposDocumento(Descripcion)
		values(@Descripcion)
		set @IDTipoDocumento = @@IDENTITY
	END
	ELSE
	BEGIN
		UPDATE Docs.tblCatTiposDocumento 
			set Descripcion = @Descripcion
		where IDTipoDocumento = @IDTipoDocumento
	END
	Exec Docs.spBuscarCatTiposDocumento @IDTipoDocumento= @IDTipoDocumento, @IDUsuario=@IDUsuario
END;
GO
