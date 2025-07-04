USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoClientes] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    declare  	 
	   @IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')


   SELECT   
   		ISNULL(C.Codigo,'') as Codigo    
		,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))as [Nombre Comercial]	
		,cast(isnull(C.GenerarNoNomina,0) as bit) as [Generar No. Nomina]    
		,isnull(C.LongitudNoNomina,0) as [Longitud No. Nomina]    
		,isnull(C.Prefijo,'') as Prefijo    		
		,isnull(RBTimbrado.NombreReporte,'')  as [Path Recibo Nomina]
		,isnull(RBNoTimbrado.NombreReporte,'')  as [Path Recibo Nomina No Timbrado]	
	FROM RH.[tblCatClientes] C  with(nolock)   
		 left join Reportes.tblCatReportesBasicos RBTimbrado 
			on RBTimbrado.IDReporteBasico = COALESCE(JSON_VALUE(C.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'IDReporteNominaTimbrado')),'') 
		 left join Reportes.tblCatReportesBasicos RBNoTimbrado 
			on RBNoTimbrado.IDReporteBasico = COALESCE(JSON_VALUE(C.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'IDReporteNominaNoTimbrado')),'')
--	WHERE (c.IDCliente = @IDCliente ) OR (isnull(@IDCliente,0) = 0)    
GO
