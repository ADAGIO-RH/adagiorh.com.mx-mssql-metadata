USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca los documentos pendientes por firmar.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-16
** Paremetros		: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROC [Legal].[spBuscarDocumentosPorFirmar]
(
	@IDUsuario INT,
	@VistaPrevia BIT = 0
)
AS
	DECLARE @Publicado INT = 2;
	DECLARE @False BIT = 0;

	;WITH TblDoc (IDDocumento, IDVersionDocumento, IDTipoDocumento, IDEstatus, IDGroup) 
	AS ( 
		SELECT  D.IDDocumento,
				V.IDVersionDocumento,
				D.IDTipoDocumento,
				V.IDEstatus,
				ROW_NUMBER() OVER( PARTITION BY D.IDTipoDocumento ORDER BY V.IDVersionDocumento DESC ) AS IDGroup
		FROM [Legal].[tblDocumentos] D 
			INNER JOIN [Legal].[tblVersionesDocumentos] V ON D.IDDocumento = V.IDDocumento 
		WHERE V.IDEstatus = @Publicado
		) 
	SELECT D.IDDocumento, 
		   D.IDVersionDocumento, 
		   D.IDTipoDocumento, 
		   D.IDEstatus,
		   V.Template, 
		   ISNULL(F.Firma, 0) AS IsFirmado,
		   TD.Descripcion
	FROM TblDoc D 
		LEFT JOIN [Legal].[tblVersionesDocumentos] V ON V.IDDocumento = D.IDDocumento 
		LEFT JOIN [Legal].[tblFirmas] F ON D.IDDocumento = F.IDDocumento AND 
										   V.IDVersionDocumento = F.IDVersionDocumento AND 
										   F.IDUsuario = CASE WHEN (@VistaPrevia = @False) THEN @IDUsuario ELSE NULL END
		INNER JOIN [Legal].[tblCatTiposDocumentos] TD ON D.IDTipoDocumento = TD.IDTipoDocumento
	WHERE D.IDGroup = 1 AND
		  ISNULL(F.Firma, 0) = 0
		ORDER BY D.IDTipoDocumento
GO
