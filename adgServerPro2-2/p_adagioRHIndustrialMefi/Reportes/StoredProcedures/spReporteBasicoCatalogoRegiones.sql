USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoRegiones] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    declare  	 
	   @IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	Select
		Codigo
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
		,CuentaContable as [Cuenta Contable]
		,JefeRegion  as [Jefe de Region]
	From RH.tblCatRegiones
GO
