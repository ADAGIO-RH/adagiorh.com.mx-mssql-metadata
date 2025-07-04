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

CREATE PROCEDURE [Reclutamiento].[spBorrarDocumentosTrabajo]
(
	@IDDocumentoTrabajo int
	,@IDUsuario int
)
AS
BEGIN
		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		SELECT 
			[IDDocumentoTrabajo]
			,[Descripcion]
		FROM [Reclutamiento].[tblCatDocumentosTrabajo]
		WHERE ([IDDocumentoTrabajo] = @IDDocumentoTrabajo)

		select @OldJSON = a.JSON from [Reclutamiento].[tblCatDocumentosTrabajo] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDDocumentoTrabajo] = @IDDocumentoTrabajo

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblCatDocumentosTrabajo]','[Reclutamiento].[spBorrarDocumentosTrabajo]','DELETE','',@OldJSON

		DELETE FROM [Reclutamiento].[tblCatDocumentosTrabajo]
        WHERE [IDDocumentoTrabajo] = @IDDocumentoTrabajo;
END
GO
