USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [Reportes].[spReporteBasicoCatalogoCapacitacionesSTPS] 
(
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)
AS
BEGIN
	select
		Codigo
		,UPPER(Codigo) +' - '+ UPPER(Descripcion) as Descripcion     
From [STPS].[tblCatCapacitaciones]
	
END
GO
