USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatAreas](
	@IDArea int = 0,
	@Area Varchar(50) = null,
	@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF;  

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    
	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'Areas'  

	SELECT 
		IDArea
		,Codigo
		,Descripcion
		,CuentaContable
		,isnull(IDEmpleado,0) as IDEmpleado
		,JefeArea 
	FROM RH.tblCatArea
	WHERE (IDArea = @IDArea or isnull(@IDArea, 0) = 0) 
		and (IDArea in (select ID from #TempFiltros)  
			OR Not Exists(select ID from #TempFiltros))  
	--and
	--	(Codigo LIKE @Area+'%') OR(Descripcion LIKE @Area+'%') OR (@Area IS NULL)
	order by RH.tblCatArea.Descripcion asc
END
GO
