USE [p_adagioRHMinutoAntes]
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

CREATE PROCEDURE [RH].[spBorrarCatExpedientesDigitales]
(
	@IDExpedienteDigital int,
	@IDUsuario int
)
AS
BEGIN

		SELECT
			[IDExpedienteDigital]
			,[Codigo]
			,[Descripcion]
			,[Requerido]
			,ROW_NUMBER()over(ORDER BY [IDExpedienteDigital])as ROWNUMBER
		FROM [RH].[tblCatExpedientesDigitales]
		WHERE IDExpedienteDigital = @IDExpedienteDigital

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatExpedientesDigitales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDExpedienteDigital] = @IDExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatExpedienteDigital]','[RH].[spBorrarCatExpedientesDigitales]','DELETE','',@OldJSON


	DELETE [RH].[tblCatExpedientesDigitales]
	WHERE IDExpedienteDigital = @IDExpedienteDigital
END
GO
