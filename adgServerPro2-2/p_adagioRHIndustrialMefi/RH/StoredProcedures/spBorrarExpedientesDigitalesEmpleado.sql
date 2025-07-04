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

CREATE PROCEDURE [RH].[spBorrarExpedientesDigitalesEmpleado]
(
	@IDExpedienteDigitalEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	    select @OldJSON = a.JSON from RH.[tblExpedienteDigitalEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblExpedienteDigitalEmpleado]','[RH].[spBorrarExpedientesDigitalesEmpleado]','DELETE',@NewJSON,@OldJSON
		
		BEGIN TRY  
		 
			DELETE RH.[tblExpedienteDigitalEmpleado]
			WHERE IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado

		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
