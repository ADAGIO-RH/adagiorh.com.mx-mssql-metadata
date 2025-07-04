USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoSucursales] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	SELECT       
		S.Codigo       
		,S.Descripcion       
		,S.CuentaContable as [Cuenta Contable]     		 
		,CP.CodigoPostal as [Código Postal]    	  
		,'['+E.Codigo+'] '+E.NombreEstado as Estado  
    	,'['+M.Codigo+'] '+M.Descripcion as Municipio      
   		,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia   	  
		,'['+P.Codigo+'] '+P.Descripcion as Pais      
		,S.Calle      
		,S.Exterior      
		,S.Interior      
		,S.Telefono    
		,S.Responsable      
		,S.Email      
		,S.ClaveEstablecimiento as [Clave Establecimiento]        
		,'['+STPSEstados.Codigo+'] '+STPSEstados.Descripcion as [Estado STPS]           
		,'['+STPSMunicipios.Codigo+'] '+STPSMunicipios.Descripcion as [Municipio STPS] 
		,isnull(S.Latitud, 19.435717) as Latitud
		,isnull(S.Longitud, -99.073410) as Longitud
		,Cast(isnull(S.Fronterizo,0) as bit) as Fronterizo
	FROM [RH].[tblCatSucursales] S with (nolock)     
		left join Sat.tblCatCodigosPostales CP with (nolock) on S.IDCodigoPostal = CP.IDCodigoPostal      
		left join Sat.tblCatPaises P with (nolock) on S.IDPais = p.IDPais      
		left join Sat.tblCatEstados E with (nolock) on S.IDEstado = E.IDEstado      
		left join Sat.tblCatMunicipios M with (nolock) on S.IDMunicipio = m.IDMunicipio      
		left join Sat.tblCatColonias CL with (nolock) on S.IDColonia = CL.IDColonia      
		Left Join STPS.tblCatEstados STPSEstados with (nolock) on S.IDEstadoSTPS = STPSEstados.IDEstado      
		Left Join STPS.tblCatMunicipios STPSMunicipios with (nolock) on S.IDMunicipioSTPS = STPSMunicipios.IDMunicipio
GO
