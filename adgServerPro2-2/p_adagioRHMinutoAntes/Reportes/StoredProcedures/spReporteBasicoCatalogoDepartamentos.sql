USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoDepartamentos] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	SELECT     		
		 d.Codigo    
		,d.Descripcion    
		,d.CuentaContable as [Cuenta Contable]   	
		,d.JefeDepartamento as [Jefe de Departamento]     	
	FROM [RH].[tblCatDepartamentos] d with(nolock)
GO
