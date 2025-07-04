USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [Legal].[spReadVersionesDocumento]    Script Date: 27/1/2023 11:25:04 ******/
/**************************************************************************************************** 
** Descripción		: Busca las versiones (Avisos de privacidad - Terminos y condiciones)
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-09
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE PROC [Legal].[spBuscarVersionesDocumento]
(
	@IDTipoDocumento INT
)
AS	
	BEGIN		

		SELECT D.IDTipoDocumento,
			   V.IDVersionDocumento,
			   V.Template
		FROM [Legal].[tblDocumentos] D
			INNER JOIN [Legal].[tblVersionesDocumentos] V ON D.IDDocumento = V.IDDocumento
		WHERE D.IDTipoDocumento = @IDTipoDocumento
		ORDER BY V.IDVersionDocumento ASC

	END
GO
