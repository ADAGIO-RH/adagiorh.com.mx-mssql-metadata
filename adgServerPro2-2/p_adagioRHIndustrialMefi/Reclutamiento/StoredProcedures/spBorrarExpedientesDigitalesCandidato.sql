USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Catálogo de Expedientes Digitales>
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Reclutamiento].[spBorrarExpedientesDigitalesCandidato]
(
	@IDExpedienteDigitalCandidato int	
)
AS
BEGIN
	-- DECLARE @OldJSON Varchar(Max),
	-- 	@NewJSON Varchar(Max)

	--     select @OldJSON = a.JSON from Reclutamiento.[tblExpedienteDigitalCandidato] b
	-- 	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	-- 	WHERE b.IDExpedienteDigitalCandidato = @IDExpedienteDigitalCandidato

	-- 	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblExpedienteDigitalCandidato]','[Reclutamiento].[spBorrarExpedientesDigitalesCandidato]','DELETE',@NewJSON,@OldJSON
		
	-- 	BEGIN TRY  
		 
			DELETE Reclutamiento.[tblExpedienteDigitalCandidato]
			WHERE IDExpedienteDigitalCandidato = @IDExpedienteDigitalCandidato

		-- END TRY  
		-- BEGIN CATCH  
		-- EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		-- 	return 0;
		-- END CATCH ;
END
GO
