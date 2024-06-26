USE [readOnly_adagioRHHotelesGDLPlaza]
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
CREATE PROCEDURE [RH].[spBuscarExpedientesDigitalesEmpleado]
(
	@IDExpedienteDigitalEmpleado int = 0,
	@IDEmpleado int = 0
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
		AND ([IDEmpleado] = @IDEmpleado)

END
GO
