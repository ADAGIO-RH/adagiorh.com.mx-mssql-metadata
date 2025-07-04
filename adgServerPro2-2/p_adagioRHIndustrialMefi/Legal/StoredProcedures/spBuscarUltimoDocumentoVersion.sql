USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca el ultimo documento con su ultima version de template.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-06
** Paremetros		: @IDTipoDocumento	(1.- Aviso de privacidad / 2.- Terminos y Condiciones)
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROC [Legal].[spBuscarUltimoDocumentoVersion](
	@IDTipoDocumento INT
)
AS
	;WITH TblDoc (IDDocumento, Fecha, IDTipoDocumento) 
	AS ( 
		SELECT TOP 1 D.IDDocumento, 
			   D.Fecha, 
			   D.IDTipoDocumento 
		FROM [Legal].[tblDocumentos] D 
		WHERE D.IDTipoDocumento = @IDTipoDocumento
		ORDER BY D.IDDocumento DESC 
		) 
	SELECT D.IDDocumento, 
		   D.Fecha, 
		   D.IDTipoDocumento, 
		   V.IDVersionDocumento, 
		   V.Template, 
		   V.FechaActualizacion, 
		   V.IDEstatus,
		   TD.Descripcion
	FROM TblDoc D 
		LEFT JOIN [Legal].[tblVersionesDocumentos] V ON V.IDDocumento = D.IDDocumento
		INNER JOIN [Legal].[tblCatTiposDocumentos] TD ON D.IDTipoDocumento = TD.IDTipoDocumento
	ORDER BY V.IDVersionDocumento DESC
GO
