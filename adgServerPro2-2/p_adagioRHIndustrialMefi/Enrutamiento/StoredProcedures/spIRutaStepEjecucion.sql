USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spIRutaStepEjecucion]
(
	@IDRutaStep int,
	@IDPosicion int = null,
	@IDUsuario int
)
AS
BEGIN

	INSERT INTO [Enrutamiento].[tblRutaStepsEjecucion](
	 IDRutaStep
	,IDPosicion
	)
	VALUES(
		@IDRutaStep
		,@IDPosicion
	)
END;
GO
