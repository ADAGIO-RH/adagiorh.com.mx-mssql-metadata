USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-09
-- Description:	stored procedure para Crear o Actualizar las Plantillas
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spUIPlantillas]
	(
		@IDPlantilla int = 0,
		@Descripcion varchar(50),
		@Contenido text,
		@Asunto text,
		@IDUsuario int
	)
AS
BEGIN
	if(@IDPlantilla = 0)
		INSERT INTO [Reclutamiento].[tblPlantillas]
				   ([Descripcion]
				   ,[Contenido]
				   ,[Asunto])
			 VALUES
				   (@Descripcion
				   ,@Contenido
				   ,@Asunto)
		else if(DATALENGTH(@Contenido) > 0 and DATALENGTH(@Descripcion) > 0)
		begin
		UPDATE [Reclutamiento].[tblPlantillas]
			   SET 
				   [Descripcion] = @Descripcion
				  ,[Contenido] = @Contenido
				  ,[Asunto] = @Asunto
			 WHERE [IDPlantilla] = @IDPlantilla
		end
END
GO
