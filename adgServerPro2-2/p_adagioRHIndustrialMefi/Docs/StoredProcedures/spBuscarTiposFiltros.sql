USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Docs].[spBuscarTiposFiltros]  
AS  
BEGIN  
	Select * 
	from Seguridad.tblCatTiposFiltros  
	where Filtro in (
		'Usuarios',
		'Excluir Usuarios',
		'Departamentos',
		'Sucursales',
		'Puestos'
	)
	order by Filtro asc  
END
GO
