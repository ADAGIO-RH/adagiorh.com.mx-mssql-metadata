USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Reportes].[spReporteBasicoCatalogoTiposPrestaciones] (
	@dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    declare 
    @IDIdioma VARCHAR(max);

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SELECT 
		tp.Codigo AS CODIGO
		,JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))AS PRESTACION
		--,tp.ConfianzaSindical
		,case when isnull(tp.Sindical, 0) = 1 then 'SI' else 'NO' end AS SINDICAL
		,cast(
			cast((tp.PorcentajeFondoAhorro * 100.00) as decimal(18, 2))
			as varchar(100)) + '%' as [% DE FONDO DE AHORRO]
		--,tp.IDsConceptosFondoAhorro
		,[CONCEPTOS INTEGRAN EL FONDE DE AHORRO] = ISNULL( STUFF(
								(   SELECT ','+ c.Codigo +'-'+ CONVERT(NVARCHAR(100), c.Descripcion) 
									FROM Nomina.tblCatConceptos c
									WHERE IDConcepto in (select cast(Item as int) from App.Split(tp.IDsConceptosFondoAhorro, ','))
									ORDER BY isnull(c.OrdenCalculo,0) desc
									FOR xml path('')
								)
								, 1
								, 1
								, ''), 'NO TIENE CONCEPTOS RELACIONADOS')
		,[TOPAR FONDO DE AHORRO] = case when isnull(tp.ToparFondoAhorro, 0) = 1 then 'SI' else 'NO' end 
	FROM RH.tblCatTiposPrestaciones tp
GO
