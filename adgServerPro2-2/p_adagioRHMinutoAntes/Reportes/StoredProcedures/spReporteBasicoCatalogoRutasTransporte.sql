USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC  [Reportes].[spReporteBasicoCatalogoRutasTransporte] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as

SELECT IDRuta as [ID Ruta],
		   Descripcion
	FROM RH.tblCatRutasTransporte
GO
