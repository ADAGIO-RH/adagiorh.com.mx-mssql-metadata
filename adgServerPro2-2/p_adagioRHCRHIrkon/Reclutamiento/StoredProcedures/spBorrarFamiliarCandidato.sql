USE [p_adagioRHCRHIrkon]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Catálogo de Expedientes Digitales>
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

CREATE PROCEDURE [Reclutamiento].[spBorrarFamiliarCandidato]
(
	@IDFamiliarCandidato int
	,@IDUsuario int
)
AS
BEGIN

	SELECT [IDFamiliarCandidato]
      ,[IDCandidato]
      ,Parentescos.IDParentesco
      ,[NombreFamiliar]
      ,[FechaNacimientoFamiliar]
      ,[Vivo]
	  ,Parentescos.Descripcion as [NombreParentesco]
	  ,ROW_NUMBER()over(ORDER BY [IDFamiliarCandidato])as ROWNUMBER
	  FROM [Reclutamiento].[tblFamiliaresCandidato] candidato
	  inner join [RH].[TblCatParentescos] Parentescos on  Candidato.IDParentesco = Parentescos.IDParentesco
  	  WHERE ([IDFamiliarCandidato] = @IDFamiliarCandidato OR isnull(@IDFamiliarCandidato,0) = 0)


		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Reclutamiento].[tblFamiliaresCandidato] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDFamiliarCandidato = @IDFamiliarCandidato

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblFamiliaresCandidato]','[Reclutamiento].[Reclutamiento].[spBorrarFamiliarCandidato]','DELETE','',@OldJSON

		DELETE FROM [Reclutamiento].[tblFamiliaresCandidato]
		WHERE [IDFamiliarCandidato] = @IDFamiliarCandidato

END
GO
