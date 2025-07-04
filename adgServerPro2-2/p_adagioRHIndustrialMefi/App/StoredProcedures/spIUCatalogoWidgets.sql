USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [App].[spIUCatalogoWidgets](
     @IDWidget VARCHAR (100)
    ,@IDAplicacion nvarchar (100)
    ,@Component VARCHAR(100)
    ,@Nombre VARCHAR(100)
    ,@Activo bit
    ,@Orden int
    ,@IDUsuario int

)
AS BEGIN
    	declare @AlreadyExists bit;

	SET @AlreadyExists =
	(SELECT
	CASE
		WHEN EXISTS ( SELECT TOP 1 1 FROM [App].[tblCatWidgets] WHERE IDWidget = @IDWidget ) THEN 1
		ELSE 0
	END);

    IF(@AlreadyExists = 0)
    BEGIN
		INSERT INTO [App].[tblCatWidgets]
			   (IDWidget
               ,[IDAplicacion]
			   ,[Component]
			   ,[Orden]
               ,[Activo]
			   ,[Nombre]
			 )
		 VALUES
			   (@IDWidget
               ,@IDAplicacion
			   ,@Component
			   ,@Orden
               ,@Activo
			   ,@Nombre)		
    END
    ELSE
    BEGIN

		UPDATE [App].[tblCatWidgets]
		   SET [IDAplicacion]=@IDAplicacion
              ,[Component] = @Component
			  ,[Orden] = @Orden	
              ,[Activo]	= @Activo
			  ,[Nombre]=@Nombre
		 WHERE [IDWidget] = @IDWidget

    END

	-- SELECT [IDAplicacion]
	-- 	  ,[Descripcion]
	-- 	  ,[Orden]
	-- 	  ,[Icon]
	-- 	  ,[Url]
	-- 	  ,ROW_NUMBER()over(ORDER BY [IDAplicacion]) as ROWNUMBER
	-- 	  ,@AlreadyExists
	--   FROM [App].[tblCatAplicaciones]
	--   WHERE [IDAplicacion] = @IDAplicacion

    
END
GO
