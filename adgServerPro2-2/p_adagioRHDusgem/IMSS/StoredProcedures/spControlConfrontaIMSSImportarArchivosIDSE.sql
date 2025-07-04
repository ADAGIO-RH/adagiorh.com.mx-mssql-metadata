USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE IMSS.spControlConfrontaIMSSImportarArchivosIDSE
(
	@ArchivoEmaIDSE IMSS.dtDetalleConfrontaEMAIDSE readonly,
	@ArchivoEbaIDSE IMSS.dtDetalleConfrontaEBAIDSE readonly,
	@IDControlConfrontaIMSS int,
	@IDUsuario int
)
AS
BEGIN
	IF((SELECT count(*) from @ArchivoEmaIDSE) > 0 )
	BEGIN
		DELETE IMSS.tblDetalleConfrontaEMAIDSE
		WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

		INSERT INTO IMSS.tblDetalleConfrontaEMAIDSE(
			IDControlConfrontaIMSS
			,NSS
			,Nombre
			,OrigenMovimiento
			,TipoMovimiento
			,FechaMovimiento
			,Dias
			,SalarioDiario
			,CuotaFija
			,ExcedentePatronal
			,ExcedenteObrera
			,PrestacionesDineroPatronal
			,PrestacionesDineroObrera
			,GastosMedicosPensionadosPatronal
			,GastosMedicosPensionadosObrera
			,RiesgoTrabajo
			,InvalidezVidaPatronal
			,InvalidezVidaObreara
			,GuarderiasPrestacionesSociales
			,Total
		)
		SELECT 
			@IDControlConfrontaIMSS
			,NSS
			,Nombre
			,OrigenMovimiento
			,TipoMovimiento
			,CASE WHEN ISNULL(FechaMovimiento,'0001-01-01') = '0001-01-01' THEN NULL ELSE FechaMovimiento END
			,Dias
			,SalarioDiario
			,CuotaFija
			,ExcedentePatronal
			,ExcedenteObrera
			,PrestacionesDineroPatronal
			,PrestacionesDineroObrera
			,GastosMedicosPensionadosPatronal
			,GastosMedicosPensionadosObrera
			,RiesgoTrabajo
			,InvalidezVidaPatronal
			,InvalidezVidaObreara
			,GuarderiasPrestacionesSociales
			,Total
		FROM @ArchivoEmaIDSE
	END

	IF((SELECT count(*) from @ArchivoEbaIDSE) > 0 )
	BEGIN
		DELETE IMSS.tblDetalleConfrontaEBAIDSE
		WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

		INSERT INTO IMSS.tblDetalleConfrontaEBAIDSE(
			IDControlConfrontaIMSS
			,NSS
			,Nombre
			,OrigenMovimiento
			,TipoMovimiento
			,FechaMovimiento
			,Dias
			,SalarioDiario
			,Retiro
			,CesantiaVejezPatronal
			,CesantiaVejezObrero
			,SubTotalRCV
			,AportacionPatronal
			,TipoDescuento
			,ValorDescuento
			,NumeroCredito
			,Amortizacion
			,SubtotalInfornavit
			,Total
		)
		SELECT 	
			@IDControlConfrontaIMSS
			,NSS
			,Nombre
			,OrigenMovimiento
			,TipoMovimiento
			,CASE WHEN ISNULL(FechaMovimiento,'0001-01-01') = '0001-01-01' THEN NULL ELSE FechaMovimiento END
			,Dias
			,SalarioDiario
			,Retiro
			,CesantiaVejezPatronal
			,CesantiaVejezObrero
			,SubTotalRCV
			,AportacionPatronal
			,TipoDescuento
			,ValorDescuento
			,NumeroCredito
			,Amortizacion
			,SubtotalInfornavit
			,Total
		FROM @ArchivoEbaIDSE
	END

END
GO
