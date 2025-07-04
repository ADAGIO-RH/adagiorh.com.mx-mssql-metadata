USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spBuscarDocumentosTrabajoCandidatoByCandidato]
(
	@IDCandidato int = 0
)
AS
BEGIN

	SELECT [IDDocumentoTrabajoCandidato]
		  ,[c].[IDDocumentoTrabajo]
		  ,[IDCandidato]
		  ,[Validacion]
          ,a.Descripcion
		  ,ROW_NUMBER()over(ORDER BY [IDDocumentoTrabajoCandidato])as ROWNUMBER

	  FROM [Reclutamiento].[tblDocumentosTrabajoCandidato] AS C
      inner join Reclutamiento.tblCatDocumentosTrabajo as a on a.IDDocumentoTrabajo=c.IDDocumentoTrabajo
	  WHERE ([IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)

END
GO
