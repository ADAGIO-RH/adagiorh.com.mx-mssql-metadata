USE [p_adagioRHEdman]
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
CREATE PROCEDURE [Reclutamiento].[spBuscarFamiliarCandidato]
(
	@IDFamiliarCandidato int = 0
)
AS
BEGIN

SELECT [IDFamiliarCandidato]
      ,[IDCandidato]
      ,Candidato.[IDParentesco]
      ,[NombreFamiliar]
      ,[FechaNacimientoFamiliar]
      ,[Vivo]
	  ,Parentescos.Descripcion as [NombreParentesco]
	  ,ROW_NUMBER()over(ORDER BY [IDFamiliarCandidato])as ROWNUMBER
  FROM [Reclutamiento].[tblFamiliaresCandidato] Candidato
  join [RH].[TblCatParentescos] Parentescos on  Candidato.IDParentesco = Parentescos.IDParentesco
  	  WHERE ([IDFamiliarCandidato] = @IDFamiliarCandidato OR isnull(@IDFamiliarCandidato,0) = 0)


END
GO
