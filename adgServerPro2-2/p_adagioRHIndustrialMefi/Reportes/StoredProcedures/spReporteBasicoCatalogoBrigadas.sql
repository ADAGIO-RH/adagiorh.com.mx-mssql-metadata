USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC  [Reportes].[spReporteBasicoCatalogoBrigadas] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
DECLARE 
@IDIdioma varchar(max);

select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


SELECT IDBrigada as [ID Brigada],
		  UPPER (JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Descripcion 
	FROM RH.tblCatBrigadas
GO
