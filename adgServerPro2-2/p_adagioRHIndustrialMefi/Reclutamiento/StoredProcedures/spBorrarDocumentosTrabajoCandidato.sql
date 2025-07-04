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

create PROCEDURE [Reclutamiento].[spBorrarDocumentosTrabajoCandidato]
(
	@IDDocumentoTrabajoCandidato int
	,@IDUsuario int
)
AS
BEGIN

		SELECT 
		   [IDDocumentoTrabajoCandidato]
		  ,[IDDocumentoTrabajo]
		  ,[IDCandidato]
		  ,[Validacion]
		 FROM [Reclutamiento].[tblDocumentosTrabajoCandidato]
		 WHERE ([IDDocumentoTrabajoCandidato] = @IDDocumentoTrabajoCandidato)


		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Reclutamiento].[tblDocumentosTrabajoCandidato] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDDocumentoTrabajoCandidato] = @IDDocumentoTrabajoCandidato

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblDocumentosTrabajoCandidato]','[Reclutamiento].[spBorrarDocumentosTrabajoCandidato]','DELETE','',@OldJSON

		DELETE FROM [Reclutamiento].[tblDocumentosTrabajoCandidato]
		WHERE ([IDDocumentoTrabajoCandidato] = @IDDocumentoTrabajoCandidato)

END
GO
