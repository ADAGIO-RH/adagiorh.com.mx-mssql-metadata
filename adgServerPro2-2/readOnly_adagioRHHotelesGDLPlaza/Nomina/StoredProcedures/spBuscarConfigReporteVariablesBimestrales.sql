USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarConfigReporteVariablesBimestrales]
AS
BEGIN
	Select TOP 1 
	
	c.ConceptosValesDespensa
	,c.ConceptosPremioPuntualidad
	,c.ConceptosPremioAsistencia
	,c.ConceptosHorasExtrasDobles
	,c.ConceptosIntegrablesVariables
	,c.ConceptosDias
	,isnull(c.IDRazonMovimiento,0) as IDRazonMovimiento
	,rm.Codigo as CodigoRazonMoviento 
	,rm.Descripcion as RazonMoviento 
	,c.CriterioDias 
	from Nomina.tblConfigReporteVariablesBimestrales c
		left join IMSS.tblCatRazonesMovAfiliatorios rm
			on rm.IDRazonMovimiento = c.IDRazonMovimiento
END
GO
