USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-30
-- Description:	sp para Buscar
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBorrarAspectosEvaluar]
	(
		@IDAspectosEvaluar int = 0
	)
AS
BEGIN
	if(@IDAspectosEvaluar > 0)
		delete from [Reclutamiento].[tblAspectosEvaluar] where [IDAspectoEvaluar] = @IDAspectosEvaluar

END
GO
