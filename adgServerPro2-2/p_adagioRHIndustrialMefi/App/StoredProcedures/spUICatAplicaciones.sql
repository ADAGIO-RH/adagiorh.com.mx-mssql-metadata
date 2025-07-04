USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [App].[spUICatAplicaciones]
(
	@IDAplicacion nvarchar(100),
	@Descripcion nvarchar(max),
	@Orden int,
	@Icon varchar(255),
	@Url varchar(max)
)
AS
BEGIN
	declare @AlreadyExists bit;

	SET @AlreadyExists =
	(SELECT
	CASE
		WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblCatAplicaciones] WHERE IDAplicacion = @IDAplicacion ) THEN 1
		ELSE 0
	END);

    IF(@AlreadyExists = 0)
    BEGIN
		INSERT INTO [App].[tblCatAplicaciones]
			   ([IDAplicacion]
			   ,[Descripcion]
			   ,[Orden]
			   ,[Icon]
			   ,[Url])
		 VALUES
			   (@IDAplicacion
			   ,@Descripcion
			   ,@Orden
			   ,@Icon
			   ,@Url)

		SET @IDAplicacion = @@IDENTITY
    END
    ELSE
    BEGIN

		UPDATE [App].[tblCatAplicaciones]
		   SET [Descripcion] = @Descripcion
			  ,[Orden] = @Orden
			  ,[Icon] = @Icon
			  ,[Url] = @Url
		 WHERE [IDAplicacion] = @IDAplicacion

    END

	SELECT [IDAplicacion]
		  ,[Descripcion]
		  ,[Orden]
		  ,[Icon]
		  ,[Url]
		  ,ROW_NUMBER()over(ORDER BY [IDAplicacion]) as ROWNUMBER
		  ,@AlreadyExists
	  FROM [App].[tblCatAplicaciones]
	  WHERE [IDAplicacion] = @IDAplicacion

END
GO
