USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spBuscarSubReportes] (
	@IDReporteBasico int = 0	
	,@IDUsuario int    
) as

     select * From Reportes.tblCatReportesBasicosSubReportes s where s.IDReporteBasico=@IDReporteBasico
GO
