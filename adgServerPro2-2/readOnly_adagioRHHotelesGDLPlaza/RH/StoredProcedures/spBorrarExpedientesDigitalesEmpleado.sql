USE [readOnly_adagioRHHotelesGDLPlaza]
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

create PROCEDURE [RH].[spBorrarExpedientesDigitalesEmpleado]
(
	@IDExpedienteDigitalEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	SELECT
		     [EDE].[IDExpedienteDigitalEmpleado]
			,[CED].[Codigo]
			,[CED].[Descripcion]
			,[CED].[Requerido]
			,[EDE].[IDEmpleado]
			,[EDE].[IDExpedienteDigital]
			,[EDE].[Name]
			,[EDE].[ContentType]
			,ROW_NUMBER()over(ORDER BY [IDExpedienteDigitalEmpleado])as ROWNUMBER
		FROM [RH].[ExpedienteDigitalEmpleado] EDE
		JOIN [RH].[tblCatExpedientesDigitales] CED ON EDE.IDExpedienteDigital = CED.IDExpedienteDigital
		WHERE ([IDExpedienteDigitalEmpleado] = @IDExpedienteDigitalEmpleado OR isnull(@IDExpedienteDigitalEmpleado,0) = 0)

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		/*select @OldJSON = a.JSON from [RH].[ExpedienteDigitalEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[ExpedienteDigitalEmpleado]','[RH].[spBorrarCatExpedientesDigitalesEmpleado]','DELETE','',@OldJSON*/


	DELETE [RH].[ExpedienteDigitalEmpleado]
	WHERE [IDExpedienteDigitalEmpleado] = @IDExpedienteDigitalEmpleado
END
GO
