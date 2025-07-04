USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spUICatAreas]
(
	@IDArea int = 0,
	@Descripcion Varchar(MAX)
)
AS
BEGIN

	IF(@IDArea = 0)
	BEGIN
		
		INSERT INTO [App].[tblCatAreas]
			   ([IDArea]
			   ,[Descripcion])
		 VALUES
			   (@IDArea
			   ,@Descripcion)

		SET @IDArea = @@IDENTITY

	END
	ELSE
	BEGIN

	UPDATE [App].[tblCatAreas]
	   SET [Descripcion] = @Descripcion
	 WHERE [IDArea] = @IDArea

	END
	
	SELECT [IDArea]
      ,[Descripcion]
	FROM [App].[tblCatAreas]
	WHERE [IDArea] = @IDArea


END
GO
