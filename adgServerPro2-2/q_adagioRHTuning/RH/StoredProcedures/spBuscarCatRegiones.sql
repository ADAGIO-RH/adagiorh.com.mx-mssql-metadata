USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatRegiones](
	@Region Varchar(50) = null   
	,@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF;  

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    
	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Regiones'  

	Select
		IDRegion
		,Codigo
		,Descripcion
		,CuentaContable
		,isnull(IDEmpleado,0) as IDEmpleado
		,JefeRegion
		,ROW_NUMBER()over(ORDER BY IDRegion)as ROWNUMBER
	From RH.tblCatRegiones
	where (Codigo like @Region+'%') OR(Descripcion like @Region+'%') OR(@Region is null)
		and (IDRegion in (select ID from #TempFiltros)  
			OR not Exists(select ID from #TempFiltros))  
	order by Descripcion ASC

END
GO
