USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [IMSS].[spBuscarCatTipoMovimientosAfiliatorios]
(
	@IDUsuario int = 0
)
as
	IF OBJECT_ID('tempdb..#TempTipoMovAfiliatorios') IS NOT NULL DROP TABLE #TempTipoMovAfiliatorios  

	SELECT ID   
		Into #TempTipoMovAfiliatorios  
	FROM Seguridad.tblFiltrosUsuarios  WITH(NOLOCK)
	WHERE IDUsuario = @IDUsuario and Filtro = 'TiposMovAfiliatorios'  

    SELECT 
		IDTipoMovimiento
		,Codigo
		,Descripcion
		,Prioridad
    FROM [IMSS].[tblCatTipoMovimientos] WITH(NOLOCK)
	WHERE ((IDTipoMovimiento in  ( SELECT ID FROM #TempTipoMovAfiliatorios)) OR NOT EXISTS(SELECT ID FROM #TempTipoMovAfiliatorios)) 
    ORDER BY Prioridad
GO
