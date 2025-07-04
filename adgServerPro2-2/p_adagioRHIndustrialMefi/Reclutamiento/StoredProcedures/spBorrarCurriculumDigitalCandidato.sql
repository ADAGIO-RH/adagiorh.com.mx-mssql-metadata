USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Curriculum Digital de candidato>
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

CREATE PROCEDURE [Reclutamiento].[spBorrarCurriculumDigitalCandidato]
(
	@IDCurriculumDigitalCandidato int,
	@IDUsuario int = 0
)
AS
BEGIN
	
		BEGIN TRY  
			DELETE [Reclutamiento].[tblCurriculumDigitalCandidato]
			WHERE IDCurriculumDigitalCandidato = @IDCurriculumDigitalCandidato

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
