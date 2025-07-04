USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoRegPatronal] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
SELECT     
		RP.RegistroPatronal as [Registro Patronal]
		,RP.RazonSocial as [Razon Social]    
		,RP.ActividadEconomica as [Actividade Economica] 		   
		,'['+CR.Codigo+'] '+CR.Descripcion AS [Clase Riesgo]  		
		,CP.CodigoPostal as [Codigo Postal]	
		,'['+E.Codigo+'] '+E.NombreEstado as Estado  	
		,'['+M.Codigo+'] '+M.Descripcion as Municipio    
		,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia		   
		,'['+P.Codigo+'] '+P.Descripcion as Pais    
		,RP.Calle    
		,RP.Exterior    
		,RP.Interior    
		,RP.Telefono    
		,isnull(RP.ConvenioSubsidios,cast(0 as bit)) as [Convenio Subsidios]    
		,RP.DelegacionIMSS as[Delegacion IMSS]   
		,RP.SubDelegacionIMSS as [Subdelegacion IMSS]   
		,RP.FechaAfiliacion as [Fecha Afiliacion]
		,RP.RepresentanteLegal as[Representante Legal]
		,RP.OcupacionRepLegal as [Ocupacion Representante Legal]   	
	FROM [RH].[tblCatRegPatronal] RP with(nolock)   
		LEFT join Sat.tblCatCodigosPostales CP with(nolock) on RP.IDCodigoPostal = CP.IDCodigoPostal    
		LEFT join Sat.tblCatPaises P with(nolock) on RP.IDPais = p.IDPais    
		LEFT join Sat.tblCatEstados E with(nolock) on RP.IDEstado = E.IDEstado    
		LEFT join Sat.tblCatMunicipios M with(nolock) on RP.IDMunicipio = m.IDMunicipio    
		LEFT join Sat.tblCatColonias CL with(nolock) on RP.IDColonia = CL.IDColonia    
		LEFT join IMSS.tblCatClaseRiesgo CR with(nolock) on CR.IDClaseRiesgo = RP.IDClaseRiesgo
GO
