USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reclutamiento].[spBuscarCandidatosProceso]
(
	@IDCandidatoProceso int = 0,
	@IDCandidato int = 0
)
AS
BEGIN

	SELECT [IDCandidatoProceso]
		  ,[IDCandidato]
		  ,[VacanteDeseada]
		  ,[SueldoDeseado]
		  ,[IDPuestoPreasignado]
		  ,[SueldoPreasignado]
		  ,[IDEstatusProceso]
		  ,ROW_NUMBER()over(ORDER BY [IDCandidatoProceso])as ROWNUMBER
	  FROM [Reclutamiento].[tblCandidatosProceso]
	   WHERE 
	   ([IDCandidatoProceso] = @IDCandidatoProceso OR isnull(@IDCandidatoProceso,0) = 0)
	   AND ([IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)
	 

END
GO
