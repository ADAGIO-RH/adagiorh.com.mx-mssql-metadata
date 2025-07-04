USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spCopiarRutaAutorizacionUnidadProceso](
	@IDUnidad int,
	@IDCatTipoProceso int,
	@IDCliente int 
)
AS
BEGIN
	DECLARE @IDRutaUnidadProceso int

	INSERT INTO [Enrutamiento].[tblRutaUnidadProceso](
		IDUnidad
		,IDCatRuta
		,Ruta
		,IDCatTipoProceso
		,TipoProceso
		,IDRutaStep
		,IDCatTipoStep
		,TipoStep
		,Orden
	)

	SELECT 
		 @IDUnidad
		,R.IDCatRuta
		,R.Nombre
		,TP.IDCatTipoProceso
		,TP.Codigo
		,RS.IDRutaStep
		,RS.IDCatTipoStep
		,TS.Codigo
		,RS.Orden
	FROM [Enrutamiento].[tblCatTiposProcesos] TP
		inner join [Enrutamiento].[tblCatRutas] R
			on TP.IDCatTipoProceso = R.IDCatTipoProceso
		INNER JOIN [Enrutamiento].[tblRutaSteps] RS
			on RS.IDCatRuta = R.IDCatRuta
		INNER JOIN [Enrutamiento].[tblCatTiposSteps] TS
			on ts.IDCatTipoStep = RS.IDCatTipoStep
	WHERE TP.IDCatTipoProceso = @IDCatTipoProceso
		and R.IDCliente = @IDCliente
	order by RS.Orden asc

	set @IDRutaUnidadProceso = @@IDENTITY

	update rup
		set rup.Completado = 1
		, rup.FechaHoraCompletado = getdate()
	from [Enrutamiento].[tblRutaUnidadProceso] rup
	where IDUnidad = @IDUnidad
	and Orden = 1

	INSERT INTO [Enrutamiento].[tblAutorizacionUnidadProceso](
	IDRutaUnidadProceso
	,IDSecuencia
	,IDUsuario 
	)
	SELECT RUP.IDRutaUnidadProceso
		,1
		,CASE WHEN ISNULL(A.IDPosicion,0) <> 0 THEN U.IDUsuario
			 ELSE A.IDUsuario
			 END
	FROM [Enrutamiento].[tblRutaUnidadProceso] RUP
		inner join [Enrutamiento].tblRutaStepsAutorizacion A
			on RUP.IDRutaStep = A.IDRutaStep
		left join [RH].[tblCatPosiciones] P
			on P.IDPosicion = A.IDPosicion
		left join [Seguridad].[tblUsuarios] U
			on P.IDEmpleado = U.IDEmpleado
	WHERE RUP.IDUnidad = @IDUnidad

	INSERT INTO [Enrutamiento].[tblEjecucionUnidadProceso](
	IDRutaUnidadProceso
	,u.IDUsuario 
	)
	SELECT RUP.IDRutaUnidadProceso
		,U.IDUsuario
	FROM [Enrutamiento].[tblRutaUnidadProceso] RUP
		inner join [Enrutamiento].tblRutaStepsEjecucion A
			on RUP.IDRutaStep = A.IDRutaStep
		inner join [RH].[tblCatPosiciones] P
			on P.IDPosicion = A.IDPosicion
		inner join [Seguridad].[tblUsuarios] U
			on P.IDEmpleado = U.IDEmpleado
	WHERE RUP.IDUnidad = @IDUnidad

END
GO
