USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [Reportes].[spReporteBasicoCatalogoEstadosSTPS] 
(
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)
AS
BEGIN
	Select 
	 Codigo
	,Descripcion       
	from STPS.tblCatEstados
	
END
GO
