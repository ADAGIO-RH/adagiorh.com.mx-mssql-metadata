USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Reportes].[spReporteBasicoCatalogoDivisiones] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as
    -- declare  	 
	--    @IDIdioma varchar(max)
	-- ;
	-- select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	Select    	 
		Codigo    
		,Descripcion    
		,CuentaContable	as [Cuenta Contable]	
		,JefeDivision as [Jefe División]
	from RH.tblCatDivisiones  with(nolock)
GO
