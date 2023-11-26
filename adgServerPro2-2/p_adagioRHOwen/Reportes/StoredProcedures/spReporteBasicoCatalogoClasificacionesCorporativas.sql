USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [Reportes].[spReporteBasicoCatalogoClasificacionesCorporativas] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

  	select  
		Codigo  
		,Descripcion  
		,CuentaContable  as [Cuenta Contable]
	from RH.tblCatClasificacionesCorporativas  with(nolock)
GO
