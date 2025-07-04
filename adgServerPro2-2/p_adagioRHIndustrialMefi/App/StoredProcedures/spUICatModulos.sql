USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [App].[spUICatModulos]
(
	@IDModulo int = 0,
	@IDArea int,
	@Descripcion Varchar(50)

)
AS
BEGIN

	IF(isnull(@IDModulo,0) = 0 )
	BEGIN
		INSERT INTO [App].[tblCatModulos]
			   ([IDArea]
			   ,[Descripcion])
		 VALUES
			   (@IDArea
			   ,@Descripcion)

		SET @IDModulo = @@IDENTITY
	END
	ELSE
	BEGIN 

		UPDATE [App].[tblCatModulos]
			   SET [IDArea] = @IDArea
				  ,[Descripcion] = @Descripcion
			 WHERE [IDModulo] = @IDModulo
	END


	EXEC [App].[spBuscarModulosByID] @IDModulo = @IDModulo


END
GO
