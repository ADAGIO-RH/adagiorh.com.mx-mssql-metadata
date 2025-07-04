USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Docs].[spBorrarAprobador](
	@IDAprobadorDocumento int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @IDDocumento int 
	select top 1 @IDDocumento = IDDocumento from Docs.tblAprobadoresDocumentos where IDAprobadorDocumento = @IDAprobadorDocumento

	Delete Docs.tblAprobadoresDocumentos
	where IDAprobadorDocumento = @IDAprobadorDocumento

	IF NOT EXISTS(select top 1 1 from Docs.tblAprobadoresDocumentos where IDDocumento = @IDDocumento and Aprobacion <> 1)
	BEGIN
		exec [Docs].[spAsignarEmpleadosADocumentosPorFiltro] @IDDocumento
	END
END
GO
