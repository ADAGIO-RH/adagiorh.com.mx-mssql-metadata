USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spBorrarRutaStepEjecucion]
(
	@IDRutaStepsEjecucion int,
	@IDUsuario int
)
AS
BEGIN
	DELETE [Enrutamiento].[tblRutaStepsEjecucion]
	WHERE IDRutaStepsEjecucion = @IDRutaStepsEjecucion
END
GO
