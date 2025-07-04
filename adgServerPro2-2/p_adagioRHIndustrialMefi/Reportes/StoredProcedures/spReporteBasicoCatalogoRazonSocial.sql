USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoRazonSocial] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

   SELECT     
		C.RFC as [RFC ]    
		,C.NombreComercial as [Nombre Comercial]   
		,C.RegFonacot as [Reg Foncat]   
		,C.RegInfonavit as [Reg Infonavit]   
		,C.RegSIEM as [Reg SIEM]   
		,C.RegEstatal as [Reg Estatal]    	   
		,CP.CodigoPostal as [Codigo Postal]   		
		,'['+E.Codigo+'] '+E.NombreEstado as Estado  	
		,'['+M.Codigo+'] '+M.Descripcion as Municipio  	
		,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia  	 
		,'['+P.Codigo+'] '+P.Descripcion as Pais    
		,C.Calle    
		,C.Exterior    
		,C.Interior       
		,RF.Descripcion as [Regimen Fiscal]    		
		,OrigenRecurso.Descripcion as [Origen Recurso]
		,C.PasswordInfonavit as [Password Infonavit]
		,'['+C.RFC+'] - '+ C.NombreComercial as [Full Empresa Descripcion]
		, C.CURP  	
	FROM RH.[tblEmpresa] C with(nolock)    
		LEFT join Sat.tblCatCodigosPostales CP  with(nolock) on c.IDCodigoPostal = CP.IDCodigoPostal    
		LEFT join Sat.tblCatPaises P    with(nolock) on c.IDPais = p.IDPais    
		LEFT join Sat.tblCatEstados E   with(nolock) on C.IDEstado = E.IDEstado    
		LEFT join Sat.tblCatMunicipios M   with(nolock) on c.IDMunicipio = m.IDMunicipio    
		LEFT join Sat.tblCatColonias CL    with(nolock) on c.IDColonia = CL.IDColonia    
		Left Join Sat.tblCatRegimenesFiscales RF  with(nolock) on C.IDRegimenFiscal = RF.IDRegimenFiscal    
		Left Join Sat.tblCatOrigenesRecursos OrigenRecurso with(nolock) on OrigenRecurso.IDOrigenRecurso = C.IDOrigenRecurso
GO
