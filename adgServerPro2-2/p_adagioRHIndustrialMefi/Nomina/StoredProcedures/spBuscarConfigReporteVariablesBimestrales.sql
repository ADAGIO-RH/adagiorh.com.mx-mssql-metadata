USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarConfigReporteVariablesBimestrales]
AS
BEGIN
	
	DECLARE 
		@ConceptosValesDespensa Varchar(MAX),
		@ConceptosPremioPuntualidad Varchar(MAX),
		@ConceptosPremioAsistencia Varchar(MAX),
		@ConceptosHorasExtrasDobles Varchar(MAX),
		@ConceptosIntegrablesVariables Varchar(MAX),
		@ConceptosDias Varchar(MAX),
		@IDRazonMovimiento int,
		@CodigoRazonMoviento Varchar(MAX),
		@RazonMoviento Varchar(MAX),
		@CriterioDias bit,
		@PromediarUMA int,
		@TopePremioPuntualidadAsistencia int
	
	
	Select TOP 1 
	
	@ConceptosValesDespensa  = isnull(c.ConceptosValesDespensa,'') 
	,@ConceptosPremioPuntualidad  = isnull(c.ConceptosPremioPuntualidad,'') 
	,@ConceptosPremioAsistencia = isnull(c.ConceptosPremioAsistencia,'') 
	,@ConceptosHorasExtrasDobles  = isnull(c.ConceptosHorasExtrasDobles,'') 
	,@ConceptosIntegrablesVariables  = isnull(c.ConceptosIntegrablesVariables,'')
	,@ConceptosDias  = isnull(c.ConceptosDias,'') 
	,@IDRazonMovimiento  = isnull(c.IDRazonMovimiento,0) 
	,@CodigoRazonMoviento  = rm.Codigo 
	,@RazonMoviento= rm.Descripcion 
	,@CriterioDias = c.CriterioDias 
	,@PromediarUMA=  isnull(c.PromediarUMA,0)
	,@TopePremioPuntualidadAsistencia  =  isnull(c.TopePremioPuntualidadAsistencia,0)
	from Nomina.tblConfigReporteVariablesBimestrales c
		left join IMSS.tblCatRazonesMovAfiliatorios rm
			on rm.IDRazonMovimiento = c.IDRazonMovimiento

	
	SELECT 
	 ISNULL(@ConceptosValesDespensa,'')  as ConceptosValesDespensa
	,ISNULL(@ConceptosPremioPuntualidad,'')  as ConceptosPremioPuntualidad
	,ISNULL(@ConceptosPremioAsistencia,'')  as ConceptosPremioAsistencia
	,ISNULL(@ConceptosHorasExtrasDobles,'') as ConceptosHorasExtrasDobles
	,ISNULL(@ConceptosIntegrablesVariables,'') as ConceptosIntegrablesVariables
	,ISNULL(@ConceptosDias,'')   as ConceptosDias
	,ISNULL(@IDRazonMovimiento,0)  as IDRazonMovimiento
	,ISNULL(@CodigoRazonMoviento,'') as CodigoRazonMoviento 
	,ISNULL(@RazonMoviento,'') as RazonMoviento 
	,ISNULL(@CriterioDias,0) as CriterioDias 
	,ISNULL(@PromediarUMA,0) as PromediarUMA
	,ISNULL(@TopePremioPuntualidadAsistencia,0) as TopePremioPuntualidadAsistencia


END
GO
