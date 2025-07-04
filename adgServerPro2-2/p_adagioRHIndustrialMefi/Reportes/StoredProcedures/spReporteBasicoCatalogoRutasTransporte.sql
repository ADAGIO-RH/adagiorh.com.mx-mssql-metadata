USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC  [Reportes].[spReporteBasicoCatalogoRutasTransporte] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
declare 
@IDIdioma varchar(max)

select @IDIdioma=App.fnGetPreferencia('Idioma',@IDUsuario,'esmx')
SELECT IDRuta as [ID Ruta],
		   JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', +lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
	FROM RH.tblCatRutasTransporte
GO
