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

CREATE PROCEDURE [Reclutamiento].[spBorrarEstatusProceso]
(
	@IDEstatusProceso int
	,@IDUsuario int
)
AS
BEGIN
		DECLARE @OldJSON Varchar(Max)

		select @OldJSON = a.JSON from [Reclutamiento].[tblCatEstatusProceso] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDEstatusProceso] = @IDEstatusProceso

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCatEstatusProceso]','[Reclutamiento].[spBorrarEstatusProceso]','DELETE','',@OldJSON

		BEGIN TRY  
			DELETE FROM [Reclutamiento].[tblCatEstatusProceso]
			WHERE ([IDEstatusProceso] = @IDEstatusProceso)
		END TRY  
		BEGIN CATCH  
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO
