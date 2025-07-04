USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec Procom.spAutoConsolidarFacturas 2,1
CREATE PROCEDURE Procom.spAutoConsolidarFacturas
(
	@IDFactura int,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE @TotalConciliado decimal(18,2),
	@TotalPendiente decimal(18,2),
	@Total decimal(18,2),
	@Consolidado int = 0


	IF OBJECT_ID('tempdb..#TempFactura') IS NOT NULL DROP TABLE #TempFactura

	IF OBJECT_ID('tempdb..#TempSugerencias') IS NOT NULL DROP TABLE #TempSugerencias

	CREATE TABLE #TempFactura (
		 IDFactura int   
		,Fecha date
		,Folio VArchar(50)
		,RFC varchar(20)
		,RazonSocial varchar(255)
		,Total decimal(18,2)
		,TotalConciliado decimal(18,2)
		,TotalPendiente decimal(18,2)
		,Consolidado int
		,TotalPaginas int
		,TotalRegistros int
	)

	
	CREATE TABLE #TempSugerencias (
		IDPeriodo int,
		ClavePeriodo varchar(50),
		PeriodoDescripcion varchar(255),
		FechaInicioPago date,
		FechaFinPago date,
		TotalPeriodo decimal(18,2),
		IDTipoNomina int,
		TipoNomina varchar(255),
		IDCliente int,
		Cliente varchar(255),
		Ranking int
	)


	insert into  #TempFactura
	Exec [PROCOM].[spBuscarFacturas] @IDFactura = @IDFactura
		,@IDUsuario = @IDUsuario
		


	SELECT TOP 1 
		@TotalConciliado = TotalConciliado,
		@Total = Total,
		@TotalPendiente = TotalPendiente,
		@Consolidado = Consolidado
	FROM #TempFactura
	

	IF(@Consolidado = 1)
	BEGIN
		RETURN;
	END
	
	IF((@Consolidado = 0) )
	BEGIN
		
		INSERT into #TempSugerencias
		EXEC [PROCOM].[spSugererirPeriodosFacturaRanking] @IDFactura = @IDFactura, @IDUsuario = @IDUsuario

	

		IF  ((Select count(*) from #TempSugerencias WHERE Ranking = 3) = 1)
		BEGIN
			INSERT INTO PROCOM.TblFacturasPeriodos(IDFactura, IDPeriodo)
			SELECT TOP 1 @IDFactura,
				IDPeriodo
			from #TempSugerencias 
			WHERE Ranking = 3

			UPDATE Procom.TblFacturas
			set Consolidado = 1
			WHERE IDFactura = @IDFactura
		END
	END
END



--EXEC [PROCOM].[spSugererirPeriodosFacturaRanking] @IDFactura = 2, @IDUsuario = 1

--update Procom.TblFacturas
--	set Total = 27253.50
--where IDFactura = 2
GO
