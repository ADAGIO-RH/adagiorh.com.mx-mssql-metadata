USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Enrutamiento].[spIRutaStepAutorizacion]
(
	@IDRutaStep int,
	@IDPosicion int = null,
	@IDUsuario int = null
)
AS
BEGIN
 if OBJECT_ID('tempdb..#tblTempRutaStepAutorizacion') is not null
	   drop table #tblTempRutaStepAutorizacion;

	INSERT INTO [Enrutamiento].[tblRutaStepsAutorizacion](
	
	 IDRutaStep
	,IDPosicion
	,IDUsuario
	)
	VALUES(
		@IDRutaStep
		,@IDPosicion
		,@IDUsuario
	)
	select IDRutaStepsAutorizacion,IDRutaStep ,IDPosicion,IDUsuario,Orden, ROW_NUMBER() over(order by IDRutaStepsAutorizacion asc) as ID
		INTO #tblTempRutaStepAutorizacion
		from Enrutamiento.[tblRutaStepsAutorizacion]
		WHERE IDRutaStep = @IDRutaStep

		update rs
		set rs.Orden = t.ID
		from Enrutamiento.[tblRutaStepsAutorizacion] rs
		inner join #tblTempRutaStepAutorizacion t
		on rs.IDRutaStep = t.IDRutaStep
		and rs.IDRutaStepsAutorizacion = t.IDRutaStepsAutorizacion

END;
GO
