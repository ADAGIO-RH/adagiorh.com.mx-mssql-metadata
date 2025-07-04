USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [App].[spUICatAreas]
(
	@IDArea int,
	@Descripcion Varchar(MAX),
	@PrefijoURL int,
	@IDAplicacion Varchar(MAX)

)
AS
BEGIN
	declare @AlreadyExists bit;
	declare @AreaAplicacionAlreadyExists bit;

	SET @AlreadyExists =
	(SELECT
	CASE
		WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblCatAreas] WHERE IDArea = @IDArea ) THEN 1
		ELSE 0
	END);


	IF(@AlreadyExists = 0)
	BEGIN
		
		INSERT INTO [App].[tblCatAreas]
			   ([IDArea]
			   ,[Descripcion]
			   ,[PrefijoURL])
		 VALUES
			   (@IDArea
			   ,@Descripcion
			   ,@PrefijoURL)


		IF(@IDAplicacion is not null)
		BEGIN
			INSERT INTO [App].[tblAplicacionAreas]
			   ([IDAplicacion]
			   ,[IDArea])
		 VALUES
			   (@IDAplicacion
			   ,@IDArea)
		END
	END
	ELSE
	BEGIN

	UPDATE [App].[tblCatAreas]
	   SET [Descripcion] = @Descripcion,
	       [PrefijoURL]  = @PrefijoURL
	 WHERE [IDArea] = @IDArea

	 IF(@IDAplicacion is null)
	 BEGIN
		DELETE FROM [App].[tblAplicacionAreas]
     	WHERE [IDArea] = @IDArea
	 END
	 ELSE
	 BEGIN


		 SET @AreaAplicacionAlreadyExists =
		(SELECT
		CASE
			WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblAplicacionAreas] WHERE IDArea = @IDArea ) THEN 1
			ELSE 0
		END);

		if(@AreaAplicacionAlreadyExists = 1)
		BEGIN 
		UPDATE [App].[tblAplicacionAreas]
		   SET [IDAplicacion] = @IDAplicacion
		 WHERE [IDArea] = @IDArea
		END
		ELSE
		BEGIN
			iNSERT INTO [App].[tblAplicacionAreas]
				   ([IDAplicacion]
				   ,[IDArea])
			 VALUES
				   (@IDAplicacion
				   ,@IDArea)
		END	
	 END

	END
	
	SELECT ca.IDArea
      ,[Descripcion]
	  ,[PrefijoURL] 
	  ,AA.IDAplicacion
	FROM [App].[tblCatAreas] ca
	left join App.tblAplicacionAreas  aa on ca.IDArea = aa.IDArea
	WHERE ca.IDArea = @IDArea


END
GO
