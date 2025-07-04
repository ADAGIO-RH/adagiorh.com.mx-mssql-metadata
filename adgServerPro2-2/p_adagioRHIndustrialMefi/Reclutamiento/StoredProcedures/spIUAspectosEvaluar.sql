USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-06-02
-- Description:	sp para generar crear/actualizar los aspectos a evaluar
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spIUAspectosEvaluar]
(
	@IDAspectoEvaluar int = 0,
	@IDPlaza int,
	@Descripcion varchar(200),
	@Detalles text
)
AS
BEGIN

	UPDATE [Reclutamiento].[tblAspectosEvaluar]
	   SET [IDPlaza] = @IDPlaza
		  ,[Descripcion] = @Descripcion
		  ,[Detalles] = @Detalles
	 WHERE IDAspectoEvaluar = @IDAspectoEvaluar

	IF @@ROWCOUNT = 0
		INSERT INTO [Reclutamiento].[tblAspectosEvaluar]
				   ([IDPlaza]
				   ,[Descripcion]
				   ,[Detalles])
			 VALUES
				   (@IDPlaza
				   ,@Descripcion
				   ,@Detalles)

END
GO
