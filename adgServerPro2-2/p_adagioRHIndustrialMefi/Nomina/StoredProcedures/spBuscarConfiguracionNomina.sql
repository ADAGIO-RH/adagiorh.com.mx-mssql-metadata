USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarConfiguracionNomina] --@ConfiguracionNomina = 'ISRProporcional'
(
	@IDConfiguracionNomina varchar(100) = null,
	@ConfiguracionNomina varchar(100) = null
)
AS
BEGIN

	select 
		IDConfiguracionNomina
		,Configuracion
		,Valor
		,TipoDato
		,Descripcion 
		,ROW_NUMBER()over(ORDER BY IDConfiguracionNomina) as ROWNUMBER
	From [Nomina].[tblConfiguracionNomina]
	where ((IDConfiguracionNomina = @IDConfiguracionNomina) OR (@IDConfiguracionNomina is null))
	AND ((Configuracion = @ConfiguracionNomina) OR (@ConfiguracionNomina is null))

END
GO
