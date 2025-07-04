USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-26
-- Description:	sp para eliminar los Candidatos relacionados con una plaza cuando aplican
-- =============================================
CREATE PROCEDURE Reclutamiento.spBorrarCandidatoPlaza
	(
		@IDCandidato int = 0,
		@IDPlaza int = 0
	)
AS
BEGIN
	if(@IDCandidato > 0 and @IDPlaza > 0)
	delete from Reclutamiento.tblCandidatoPlaza 
		where IDCandidato = @IDCandidato AND IDPlaza = @IDPlaza

END
GO
