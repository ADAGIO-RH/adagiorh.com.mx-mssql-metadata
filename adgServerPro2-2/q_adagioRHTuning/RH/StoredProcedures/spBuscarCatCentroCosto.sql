USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[RH].[spBuscarCatCentroCosto] @IDUsuario= 1
--GO
CREATE PROCEDURE [RH].[spBuscarCatCentroCosto](
	 @CentroCosto Varchar(50) = null   
	,@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF;  

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    
	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'CentrosCostos'  

	SELECT 
		IDCentroCosto
		,Codigo
		,Descripcion
		,CuentaContable
	FROM RH.[tblCatCentroCosto]
	WHERE (Codigo LIKE @CentroCosto+'%') OR(Descripcion LIKE @CentroCosto+'%') OR (@CentroCosto IS NULL)
		and (IDCentroCosto in  ( select ID from #TempFiltros)  
			OR Not Exists(select ID from #TempFiltros))  
	ORDER BY Descripcion ASC
END
GO
