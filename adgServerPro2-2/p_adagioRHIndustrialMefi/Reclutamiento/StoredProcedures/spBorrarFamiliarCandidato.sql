USE [p_adagioRHIndustrialMefi]
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
	,@IDUsuario int = 0
)
AS
BEGIN
 DECLARE
 @IDIdioma varchar(225)  ;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT [IDFamiliarCandidato]
      ,[IDCandidato]
      ,Parentescos.IDParentesco
      ,[NombreFamiliar]
      ,[FechaNacimientoFamiliar]
      ,[Vivo]
	  ,JSON_VALUE(Parentescos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [NombreParentesco]
	  ,ROW_NUMBER()over(ORDER BY [IDFamiliarCandidato])as ROWNUMBER
	  FROM [Reclutamiento].[tblFamiliaresCandidato] candidato
	  inner join [RH].[TblCatParentescos] Parentescos on  Candidato.IDParentesco = Parentescos.IDParentesco
  	  WHERE ([IDFamiliarCandidato] = @IDFamiliarCandidato OR isnull(@IDFamiliarCandidato,0) = 0)
	BEGIN TRY  
		   DELETE FROM [Reclutamiento].[tblFamiliaresCandidato]
		WHERE [IDFamiliarCandidato] = @IDFamiliarCandidato
	END TRY  
	BEGIN CATCH  
		DECLARE @ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT;

	SELECT
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (@ErrorMessage, -- Message text.
				@ErrorSeverity, -- Severity.
				@ErrorState -- State.
				);
	END CATCH ;


END
GO
