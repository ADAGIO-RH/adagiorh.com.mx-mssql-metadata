USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoPuestos] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    declare  	 
	   @IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
SELECT     
	   
		p.Codigo    
		,JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
		,p.DescripcionPuesto as [Descirpcion del Puesto]  
		,isnull(p.TopeSalarial,0.00) as [Tope Salarial]
		,isnull(p.SueldoBase,0.00) as [Sueldo Base]    	
		,'['+o.Codigo+'] - '+o.Descripcion as Ocupacion 		
	FROM [RH].[tblCatPuestos] p with (nolock)    
		left join STPS.tblCatOcupaciones O with (nolock) on P.IDOcupacion = o.IDOcupaciones
GO
