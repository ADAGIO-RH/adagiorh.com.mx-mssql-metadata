USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC  [Reportes].[spReporteBasicoCatalogoAfore] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as

SELECT IDAfore as [ID Afore],
		   Descripcion
	FROM RH.tblCatAfores
GO
