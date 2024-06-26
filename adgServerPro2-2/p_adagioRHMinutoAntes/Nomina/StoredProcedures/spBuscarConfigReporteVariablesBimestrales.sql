USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarConfigReporteVariablesBimestrales]
AS
BEGIN
	Select TOP 1 
	
	isnull(c.ConceptosValesDespensa,'') as ConceptosValesDespensa
	,isnull(c.ConceptosPremioPuntualidad,'') as ConceptosPremioPuntualidad
	,isnull(c.ConceptosPremioAsistencia,'') as ConceptosPremioAsistencia
	,isnull(c.ConceptosHorasExtrasDobles,'') as ConceptosHorasExtrasDobles
	,isnull(c.ConceptosIntegrablesVariables,'') as ConceptosIntegrablesVariables
	,isnull(c.ConceptosDias,'') as ConceptosDias
	,isnull(c.IDRazonMovimiento,0) as IDRazonMovimiento
	,rm.Codigo as CodigoRazonMoviento 
	,rm.Descripcion as RazonMoviento 
	,c.CriterioDias 
	, isnull(c.PromediarUMA,0) as PromediarUMA
	, isnull(c.TopePremioPuntualidadAsistencia,0) as TopePremioPuntualidadAsistencia
	from Nomina.tblConfigReporteVariablesBimestrales c
		left join IMSS.tblCatRazonesMovAfiliatorios rm
			on rm.IDRazonMovimiento = c.IDRazonMovimiento
END
GO
