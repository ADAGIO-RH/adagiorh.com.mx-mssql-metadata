USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spControlConfrontaIMSSImportarArchivosSUA]
(
	@ArchivoSUA IMSS.dtDetalleConfrontaSUA readonly,
	@IDControlConfrontaIMSS int,
	@IDUsuario int
)
AS
BEGIN
	IF((SELECT count(*) from @ArchivoSUA where Dias > 0) > 0 )
	BEGIN
		DELETE IMSS.tblDetalleConfrontaEMASUA
		WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

		INSERT INTO IMSS.tblDetalleConfrontaEMASUA(
			IDControlConfrontaIMSS
			,NSS
			,Nombre
			,Dias
			,SalarioDiario
			,CuotaFija
			,Excedentes
			,PrestacionesDinero
			,GastosMedicosPensionados
			,RiesgoTrabajo
			,InvalidezVida
			,GuarderiasPrestacionesSociales
			,Total
		)
		SELECT 
			@IDControlConfrontaIMSS
			,NSS
			,Nombre
			,Dias
			,SalarioDiario
			,CuotaFija
			,Excedentes
			,PrestacionesDinero
			,GastosMedicosPensionados
			,RiesgoTrabajo
			,InvalidezVida
			,Guarderia
			,0.00

		FROM @ArchivoSUA
	END

	IF((SELECT count(*) from @ArchivoSUA where DiasBimestre > 0) > 0 )
	BEGIN
		DELETE IMSS.tblDetalleConfrontaEBASUA
		WHERE IDControlConfrontaIMSS = @IDControlConfrontaIMSS

		INSERT INTO IMSS.tblDetalleConfrontaEBASUA(
			IDControlConfrontaIMSS
			,NSS
			,Nombre
			,Dias
			,SalarioDiario
			,Retiro
			,CesantiaVejezPatronal
			,CesantiaVejezObrero
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
			,DiasBimestre
			,SalarioDiario
			,Retiro
			,CesantiaVejezPatronal
			,CesantiaVejezObrera
			,InfonavitPatronal
			,''
			,0.00
			,NumeroInfonavit
			,Amortizacion
			,0.00
			,0.00
		FROM @ArchivoSUA
	END

END
GO
