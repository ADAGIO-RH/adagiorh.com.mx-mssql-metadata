USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [App].[spUICatUrl]
(
	@IDUrl int,
    @IDModulo int,
    @Descripcion varchar(255),
    @URL varchar(255),
    @Tipo char(1),
    @IDTipoPermiso nvarchar(10),
    @IDController int
)

AS
BEGIN
	declare @AlreadyExists bit;

	SET @AlreadyExists =
	(SELECT
	CASE
		WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblCatUrls] WHERE IDUrl = @IDUrl ) THEN 1
		ELSE 0
	END);


	IF(@AlreadyExists = 0)
		BEGIN
		
		INSERT INTO [App].[tblCatUrls]
			   ([IDUrl]
			   ,[IDModulo]
			   ,[Descripcion]
			   ,[URL]
			   ,[Tipo]
			   ,[IDTipoPermiso]
			   ,[IDController])
		 VALUES
			   (@IDUrl
			   ,@IDModulo
			   ,@Descripcion
			   ,@URL
			   ,@Tipo
			   ,@IDTipoPermiso
			   ,@IDController)

			   SET @IDUrl = @@IDENTITY;
		END
	ELSE
	BEGIN

		UPDATE [App].[tblCatUrls]
		   SET [IDModulo] = @IDModulo
			  ,[Descripcion] = @Descripcion
			  ,[URL] = @URL
			  ,[Tipo] = @Tipo
			  ,[IDTipoPermiso] = @IDTipoPermiso
			  ,[IDController] = @IDController
		 WHERE [IDUrl] = @IDUrl 

	END


	exec [App].[spBuscarUrlsByID] @IDUrl = @IDUrl

END
GO
