USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarConfiguracionAvanzadaProyecto](
	@IDProyecto int
) as

	select 
	 ca.IDConfiguracionAvanzada
	,ca.Descripcion
	,ca.TipoDato
	,@IDProyecto as IDProyecto
	,cap.Valor
	,ca.IDTemplate
	,ca.Info
	from [Evaluacion360].[tblConfiguracionesAvanzadas] ca
		left join [Evaluacion360].[tblConfiguracionAvanzadaProyecto] cap on ca.IDConfiguracionAvanzada = cap.IDConfiguracionAvanzada and cap.IDProyecto = isnull(@IDProyecto,0)
	WHERE @IDProyecto IS NOT null and ca.Activa = 1
GO
