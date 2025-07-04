USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBuscarTiposFiltrosLectores]  
AS  
BEGIN  
	Select 
		Filtro
		,DOMElementID
		,Descripcion
		,Orden
		,Prefijo
	from Seguridad.tblCatTiposFiltros  
	where Filtro not in (
		'Usuarios',
		'Excluir Usuarios',
		'Subordinados',
		'IncidenciasAusentismos',
		'Solo Vigentes'
	)
	order by Filtro asc  
END
GO
