USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Sat].[spBuscarTiposContrato](
	@TipoContrato Varchar(50) = '',
	@IDUsuario int
)
AS
BEGIN
	SET FMTONLY OFF;  

	IF OBJECT_ID('tempdb..#TempFiltros') IS NOT NULL DROP TABLE #TempFiltros;
    
	select ID   
	Into #TempFiltros  
	from Seguridad.tblFiltrosUsuarios  with(nolock) 
	where IDUsuario = @IDUsuario and Filtro = 'TiposContratacion'  

	IF(@TipoContrato = '' or @TipoContrato is null)
	BEGIN
		select 
			IDTipoContrato
			,UPPER(Codigo) as Codigo
			,UPPER(Descripcion)  as Descripcion
		From [Sat].[tblCatTiposContrato]
		where (IDTipoContrato in  ( select ID from #TempFiltros)  
			OR Not Exists(select ID from #TempFiltros))  

	END
	ELSE
	BEGIN
		select 
			IDTipoContrato
			,UPPER(Codigo) as Codigo
			,UPPER(Descripcion)  as Descripcion
		From [Sat].[tblCatTiposContrato]
		where (Descripcion like @TipoContrato +'%'
			OR Codigo like @TipoContrato+'%')
			and (IDTipoContrato in  ( select ID from #TempFiltros)  
				OR Not Exists(select ID from #TempFiltros))  
	END
END
GO
