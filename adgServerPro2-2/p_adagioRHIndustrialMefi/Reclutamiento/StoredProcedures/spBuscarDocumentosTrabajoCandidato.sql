USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reclutamiento].[spBuscarDocumentosTrabajoCandidato]
(
	@IDDocumentoTrabajoCandidato int = 0
)
AS
BEGIN

	SELECT [IDDocumentoTrabajoCandidato]
		  ,[IDDocumentoTrabajo]
		  ,[IDCandidato]
		  ,[Validacion]
		  ,ROW_NUMBER()over(ORDER BY [IDDocumentoTrabajoCandidato])as ROWNUMBER

	  FROM [Reclutamiento].[tblDocumentosTrabajoCandidato]
	  WHERE ([IDDocumentoTrabajoCandidato] = @IDDocumentoTrabajoCandidato OR isnull(@IDDocumentoTrabajoCandidato,0) = 0)

END
GO
