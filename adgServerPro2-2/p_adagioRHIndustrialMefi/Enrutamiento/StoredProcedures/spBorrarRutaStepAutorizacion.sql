USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Enrutamiento].[spBorrarRutaStepAutorizacion]
(
	@IDRutaStepsAutorizacion int,
	@IDUsuario int
)
AS
BEGIN
	DELETE [Enrutamiento].[tblRutaStepsAutorizacion]
	WHERE IDRutaStepsAutorizacion = @IDRutaStepsAutorizacion
END
GO
