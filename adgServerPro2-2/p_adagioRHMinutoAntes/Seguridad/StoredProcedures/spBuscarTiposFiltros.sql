USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Seguridad].[spBuscarTiposFiltros]  
AS  
BEGIN  
	Select 
		Filtro
		,DOMElementID
		,Descripcion
		,isnull(Orden, 0) as Orden
	from Seguridad.tblCatTiposFiltros  
	order by Orden asc  
END
GO
