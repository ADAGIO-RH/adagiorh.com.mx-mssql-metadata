USE [p_adagioRHDXN-Mexico]
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
CREATE PROCEDURE [Reclutamiento].[spBuscarFamiliarCandidatoPorIDCandidato]
(
	@IDCandidato int = 0
)
AS
BEGIN




SELECT [IDFamiliarCandidato]
      ,[IDCandidato]
      ,Candidato.[IDParentesco]
      ,[NombreFamiliar]
	  ,isnull([FechaNacimientoFamiliar],'1900-01-01') as [FechaNacimientoFamiliar]
      ,[Vivo]
	  ,Parentesco.Descripcion as [NombreParentesco]
	  ,ROW_NUMBER()over(ORDER BY [IDFamiliarCandidato])as ROWNUMBER
  FROM [Reclutamiento].[tblFamiliaresCandidato] Candidato
  join RH.TblCatParentescos Parentesco on Candidato.IDParentesco = Parentesco.IDParentesco
  	  WHERE ([IDCandidato] = @IDCandidato OR isnull(@IDCandidato,0) = 0)


END
GO
