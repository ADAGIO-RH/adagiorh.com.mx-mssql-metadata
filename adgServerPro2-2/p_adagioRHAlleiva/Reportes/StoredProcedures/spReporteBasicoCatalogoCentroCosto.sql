USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [Reportes].[spReporteBasicoCatalogoCentroCosto] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
SELECT 
		Codigo
		,Descripcion
		,CuentaContable as [Cuenta Contable]
	FROM RH.[tblCatCentroCosto]
GO
