USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Buscar el Catálogo de ExpedientesDigitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spBuscarDocumentosTrabajo]
(
	@IDDocumentoTrabajo int = 0
)
AS
BEGIN


	SELECT [IDDocumentoTrabajo]
		  ,[Descripcion]
		  ,ROW_NUMBER()over(ORDER BY [IDDocumentoTrabajo])as ROWNUMBER
	  FROM [Reclutamiento].[tblCatDocumentosTrabajo]

	  WHERE ([IDDocumentoTrabajo] = @IDDocumentoTrabajo OR isnull(@IDDocumentoTrabajo,0) = 0)
	  and [Descripcion] <> 'PASAPORTE'

END
GO
