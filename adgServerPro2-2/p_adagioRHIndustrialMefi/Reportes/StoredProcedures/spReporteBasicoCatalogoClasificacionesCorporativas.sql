USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoClasificacionesCorporativas] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
     declare  	 
	    @IDIdioma varchar(max)
	 ;
	 select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

  	select  
		Codigo  
		--,Descripcion  
		, ISNULL(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Descripcion
		,CuentaContable  as [Cuenta Contable]
	from RH.tblCatClasificacionesCorporativas  with(nolock)
GO
