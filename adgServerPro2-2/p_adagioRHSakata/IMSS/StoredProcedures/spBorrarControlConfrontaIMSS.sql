USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: BORRAR lista de Controles de Confronta IMSS
** Autor			: JOSE ROMAN
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2025-02-07
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROCEDURE [IMSS].[spBorrarControlConfrontaIMSS]
(
	@IDControlConfrontaIMSS int,
	@IDUsuario int
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


		select @NewJSON = (SELECT *
                FROM  [IMSS].[tblControlConfrontaIMSS]
                WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblControlConfrontaIMSS]','[IMSS].[spBorrarControlConfrontaIMSS]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  

			DELETE IMSS.tblDetalleConfrontaEBASUA
			WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

			DELETE IMSS.tblDetalleConfrontaEBAIDSE
			WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

			DELETE IMSS.tblDetalleConfrontaEMASUA
			WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS 
			
			DELETE IMSS.tblDetalleConfrontaEMAIDSE
			WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

			DELETE IMSS.[tblControlConfrontaIMSS]
			WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

		END TRY  
		BEGIN CATCH  
		DECLARE @Message Varchar(100)
			SELECT @Message =  ERROR_MESSAGE();  

			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002', @CustomMessage = @Message
			return 0;
		END CATCH ;
END
GO
