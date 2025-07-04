USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Docs].[spAsignarEmpleadosADocumentosPorFiltroMasivo](
	@IDUsuario int = 0
)
AS
BEGIN
	
	DECLARE @IDUsuarioAdmin int,
	@IDDocumento int;	

	IF OBJECT_ID('tempdb..#TempDocumentos') IS NOT NULL DROP TABLE #TempDocumentos

	select @IDUsuarioAdmin = Valor from App.tblConfiguracionesGenerales with (nolock) where IDConfiguracion = 'IDUsuarioAdmin'

	select u.IDItem as IDDocumento
		into #TempDocumentos
	FROM Docs.tblCarpetasDocumentos U with (nolock)
	
	ORDER BY u.IDItem ASC

	select @IDDocumento = MIN(IDDocumento) from #TempDocumentos
	select * from #TempDocumentos order by IDDocumento asc
	WHILE @IDDocumento <= (Select MAX(IDDocumento) from #TempDocumentos)
	BEGIN
		print '@IDDocumento:' +cast(@IDDocumento as varchar(10))
		exec [Docs].[spAsignarEmpleadosADocumentosPorFiltro] @IDDocumento = @IDDocumento
		select @IDDocumento = MIN(IDDocumento) FROM #TempDocumentos where IDDocumento > @IDDocumento
	END
END
GO
