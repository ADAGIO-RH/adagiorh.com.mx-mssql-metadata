USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC  [Reportes].[spReporteBasicoCatalogoParentescos] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
DECLARE 
@IDIdioma VARCHAR(max);

select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

SELECT  IDParentesco as [ID Parentesco],
		   JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
	FROM [RH].[TblCatParentescos]
GO
