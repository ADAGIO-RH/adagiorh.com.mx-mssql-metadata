USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Seguridad.spBuscarTiposFiltros  
AS  
BEGIN  
	Select * 
	from Seguridad.tblCatTiposFiltros  
	order by Filtro asc  
END
GO
