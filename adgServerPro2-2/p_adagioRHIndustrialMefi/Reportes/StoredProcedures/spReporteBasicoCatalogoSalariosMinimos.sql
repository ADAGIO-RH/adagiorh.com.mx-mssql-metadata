USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC  [Reportes].[spReporteBasicoCatalogoSalariosMinimos] (
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)as

declare @IDIdioma varchar(20);
select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

 select 
	
		Format(SM.Fecha,'dd/MM/yyyy') as Fecha
		,isnull(SM.SalarioMinimo, 0) as [Salario Minimo]
		,isnull(SM.SalarioMinimoFronterizo, 0) as [Salario Minimo Fronterizo]
		,isnull(SM.UMA, 0) as [UMA ]
		,isnull(SM.FactorDescuento,0) as [UMI ]	
		,P.Descripcion as Pais
		,ISNULL(SM.AjustarUMI,0) [Ajustar UMI]
		,CASE WHEN ISNULL(SM.AjustarUMI,0) = 0 THEN 'NO' ELSE 'SI' END [Ajustar UMISTR] 	
    from [Nomina].[tblSalariosMinimos] SM with(Nolock)
		left join SAT.tblCatPaises P
			on SM.IDPais = P.IDPais
GO
