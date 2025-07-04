USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------BLOQUE ACTUALIZACION ISR---------------
/*
El procedimiento no es para ejecutarse con parametros, hay que ejecutarlo como el del calculo 'indivicual'.
Asi mimso, cada  año hay que asegurarnos de meter correctamente los valores de todas las tablas de ISR. 

Se le añadio un pequeño Scrip para que genere en automatico la tabla inversa de cada periodicidad de pago. Esto para que en caso de qe se utiice el calculo 
inverso consulte dichas tablas. Si no se utilia no afecta en nada. 

IMPORTANTE, EN LAS BASES QUE NO SE ENCUENTREN ACTUALIZADAS, SE DEBE QUITAR EL PARAMETRO ID PAIS, REVISAR COMO ESTA LA ESTRUCTURA
DE LA TABLA ANTES DE CORRER EL SCRIPT.
*/

--EXECUTE sp_refreshsqlmodule N'[Utilerias].[spAperturaAnual]';

CREATE proc [Utilerias].[spAperturaAnual] as
--------RESPALDO DE INFORMACION
	SELECT *
	INTO BK.tblTablasImpuestosPrevioActualizacion
	FROM NOMINA.tblTablasImpuestos

	SELECT * 
	INTO BK.tblDetalleTablasImpuestosPrevioActualizacion
	FROM NOMINA.tblDetalleTablasImpuestos
--------RESPALDO DE INFORMACION

---Variables Generales
	DECLARE 
		@Ejercicio int =2023,
		@IDPais int=0,
		@IDCalculoISRSueldos int=0,
		@IDCalculoISRInverso int=0,
		@IDCalculoSubsidio int=0,
		@IDPPDiario int =0,
		@IDPPSemanal int=0,
		@IDPPDecenal int =0,
		@IDPPCatorcenal int=0,
		@IDPPQuincenal int=0,
		@IDPPMensual int=0,
		@IDPPBimestral int=0,
		@IDPPAnual int=0,
		
		@IDTablaImpuestoDiario int = 0,
        @IDTablaSubsidioDiario int=0,
        @IDTablaInversoDiario int = 0
	;

	SELECT @IDCalculoISRSueldos=IDCalculo FROM NOMINA.tblCatTipoCalculoISR WHERE CODIGO='ISR_SUELDOS'
	SELECT @IDCalculoISRInverso=IDCalculo FROM NOMINA.tblCatTipoCalculoISR WHERE CODIGO='ISR_INVERSO'
	SELECT @IDCalculoSubsidio=IDCalculo FROM NOMINA.tblCatTipoCalculoISR WHERE Codigo='CALCULO_SUBSIDIO'
	SELECT @IDPPDiario=IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion='Diario'
	SELECT @IDPPSemanal=IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion='Semanal'
	SELECT @IDPPDecenal=IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion='Decenal'
	SELECT @IDPPCatorcenal=IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion='Catorcenal'
	SELECT @IDPPQuincenal=IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion='Quincenal'
	SELECT @IDPPMensual=IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion='Mensual'
	SELECT @IDPPBimestral=IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion='Bimestral'
	SELECT @IDPPAnual=IDPeriodicidadPago FROM SAT.tblCatPeriodicidadesPago WHERE Descripcion='Anual'
	SELECT @IDPais=IDPais FROM SAT.tblCatPaises WHERE Codigo='MEX'

---------------------Tabla Diaria---------------------------------------



INSERT INTO NOMINA.tblTablasImpuestos (
	IDPeriodicidadPago
	,Ejercicio
	,IDCalculo
	,Descripcion
	,IDPais
)
VALUES (@IDPPDiario,@Ejercicio,@IDCalculoISRSueldos,CONCAT('ISR DIARIO ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
SET @IDTablaImpuestoDiario=@@IDENTITY

INSERT INTO NOMINA.tblTablasImpuestos(
	IDPeriodicidadPago
	,Ejercicio
	,IDCalculo
	,Descripcion
	,IDPais
)
VALUES (@IDPPDiario,@Ejercicio,@IDCalculoSubsidio,CONCAT('SUBSIDIO DIARIO ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
SET @IDTablaSubsidioDiario=@@IDENTITY

INSERT INTO NOMINA.tblTablasImpuestos(
	IDPeriodicidadPago
	,Ejercicio
	,IDCalculo
	,Descripcion
	,IDPais
) 
VALUES (@IDPPDiario,@Ejercicio,@IDCalculoISRInverso,CONCAT('ISR INVERSO DIARIO ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
SET @IDTablaInversoDiario=@@IDENTITY

	IF object_ID('TEMPDB..#TempISRDiario') IS NOT NULL  
		DROP TABLE #TempISRDiario;

	IF object_ID('TEMPDB..#TempSubsidioDiario') IS NOT NULL  
		DROP TABLE #TempSubsidioDiario;

	IF object_ID('TEMPDB..#TempISRInversoDiario') IS NOT NULL  
		DROP TABLE #TempISRInversoDiario;

	CREATE TABLE #TempISRDiario(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	CREATE TABLE #TempSubsidioDiario(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	CREATE TABLE #TempISRInversoDiario(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija]		[decimal](18, 4),
		[Porcentaje]	[decimal](18, 4)
	)

	INSERT INTO #TempISRDiario 
	values 
		(@IDTablaImpuestoDiario,0.01,24.54,0,0.0192)
		,(@IDTablaImpuestoDiario,24.54,208.29,0.47,0.064)
		,(@IDTablaImpuestoDiario,208.3,366.05,12.23,0.1088)
		,(@IDTablaImpuestoDiario,366.06,425.52,29.4,0.16)
		,(@IDTablaImpuestoDiario,425.53,509.46,38.91,0.1792)
		,(@IDTablaImpuestoDiario,509.47,1027.52,53.95,0.2136)
		,(@IDTablaImpuestoDiario,1027.53,1619.51,164.61,0.2352)
		,(@IDTablaImpuestoDiario,1619.52,3091.9,303.85,0.3)
		,(@IDTablaImpuestoDiario,3091.91,4122.54,745.56,0.32)
		,(@IDTablaImpuestoDiario,4122.55,12367.62,1075.37,0.34)
		,(@IDTablaImpuestoDiario,12367.63,999999999,3878.69,0.35)

	INSERT INTO #TempSubsidioDiario 
	VALUES
		(@IDTablaSubsidioDiario,0.01,58.19,13.39,0)
		,(@IDTablaSubsidioDiario,58.2,87.28,13.38,0)
		,(@IDTablaSubsidioDiario,87.29,114.24,13.38,0)
		,(@IDTablaSubsidioDiario,114.25,116.38,12.92,0)
		,(@IDTablaSubsidioDiario,116.39,146.25,12.58,0)
		,(@IDTablaSubsidioDiario,146.26,155.17,11.65,0)
		,(@IDTablaSubsidioDiario,155.18,175.51,10.69,0)
		,(@IDTablaSubsidioDiario,175.52,204.76,9.69,0)
		,(@IDTablaSubsidioDiario,204.77,234.01,8.34,0)
		,(@IDTablaSubsidioDiario,234.02,242.84,7.16,0)
		,(@IDTablaSubsidioDiario,242.85,999999999,0,0)

	INSERT INTO NOMINA.tblDetalleTablasImpuestos
	SELECT * FROM #TempISRDiario
	UNION
	SELECT * FROM #TempSubsidioDiario


	INSERT INTO #TempISRInversoDiario (
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	Select 
		@IDTablaInversoDiario,
		[LimiteInferior],
		case when [LimiteSuperior] is null then 999999999.0000 
										   else LimiteSuperior end 
										   as LimiteSuperior,
		case when LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
																		ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
																		AS CuotaFija,
		[Porcentaje] 
	from ( 
		Select 
			 LimiteInferior - CoutaFija as limiteInferior
			,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
			,LimiteSuperior as CuotaFija 
			,1 - Porcentaje as Porcentaje
		from Nomina.tblDetalleTablasImpuestos 
		where IDTablaImpuesto = @IDTablaImpuestoDiario 
	) a

	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	SELECT 
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	FROM #TempISRInversoDiario

-------------------------------------Tabla Semanal---------------------------------------

	DECLARE @IDTablaImpuestoSemanal int = 0,
			@IDTablaInversoSemanal int = 0,
			@IDTablaSubsidioSemanal int=0;

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPSemanal,@Ejercicio,@IDCalculoISRSueldos,CONCAT('ISR SEMANAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaImpuestoSemanal=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPSemanal,@Ejercicio,@IDCalculoSubsidio,CONCAT('SUBSIDIO SEMANAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaSubsidioSemanal=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPSemanal,@Ejercicio,@IDCalculoISRInverso,CONCAT('ISR INVERSO SEMANAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaInversoSemanal=@@IDENTITY

	IF object_ID('TEMPDB..#TempISRSemanal') IS NOT NULL  
		DROP TABLE #TempISRSemanal

	CREATE TABLE #TempISRSemanal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	IF object_ID('TEMPDB..#TempSubsidioSemanal') IS NOT NULL  
		DROP TABLE #TempSubsidioSemanal

	IF object_ID('TEMPDB..#TempISRInversoSemanal') IS NOT NULL  
		DROP TABLE #TempISRInversoSemanal

	CREATE TABLE #TempSubsidioSemanal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	CREATE TABLE #TempISRInversoSemanal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	INSERT INTO #TempISRSemanal 
	values 
		(@IDTablaImpuestoSemanal,0.01,171.78,0,0.0192)
		,(@IDTablaImpuestoSemanal,171.79,1458.03,3.29,0.064)
		,(@IDTablaImpuestoSemanal,1458.04,2562.35,85.61,0.1088)
		,(@IDTablaImpuestoSemanal,2562.36,2978.64,205.8,0.16)
		,(@IDTablaImpuestoSemanal,2978.65,3566.22,272.37,0.1792)
		,(@IDTablaImpuestoSemanal,3566.23,7192.64,377.65,0.2136)
		,(@IDTablaImpuestoSemanal,7192.65,11336.57,1152.27,0.2352)
		,(@IDTablaImpuestoSemanal,11336.58,21643.3,2126.95,0.3)
		,(@IDTablaImpuestoSemanal,21643.31,28857.78,5218.92,0.32)
		,(@IDTablaImpuestoSemanal,28857.79,86573.34,7527.59,0.34)
		,(@IDTablaImpuestoSemanal,86573.35,999999999,27150.83,0.35)



	INSERT INTO #TempSubsidioSemanal 
	VALUES
		(@IDTablaSubsidioSemanal,0.01,407.33,93.73,0)
		,(@IDTablaSubsidioSemanal,407.34,610.96,93.66,0)
		,(@IDTablaSubsidioSemanal,610.97,799.68,93.66,0)
		,(@IDTablaSubsidioSemanal,799.69,814.66,90.44,0)
		,(@IDTablaSubsidioSemanal,814.67,1023.75,88.06,0)
		,(@IDTablaSubsidioSemanal,1023.76,1086.19,81.55,0)
		,(@IDTablaSubsidioSemanal,1086.2,1228.57,74.83,0)
		,(@IDTablaSubsidioSemanal,1228.58,1433.32,67.83,0)
		,(@IDTablaSubsidioSemanal,1433.33,1638.07,58.38,0)
		,(@IDTablaSubsidioSemanal,1638.08,1699.88,50.12,0)
		,(@IDTablaSubsidioSemanal,1699.89,999999999,0,0)

	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto
		,LimiteInferior
		,LimiteSuperior
		,CoutaFija
		,Porcentaje
	)
	SELECT * FROM #TempISRSemanal
	UNION
	SELECT * FROM #TempSubsidioSemanal

	INSERT INTO #TempISRInversoSemanal 
	Select 
		@IDTablaInversoSemanal,
		[LimiteInferior],

		case when [LimiteSuperior] is null then 999999999.0000 
										   else LimiteSuperior end 
										   as LimiteSuperior,

		CASE WHEN LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
																		ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
																		AS CuotaFija,
		[Porcentaje] 
	from ( 
		Select 
			 LimiteInferior - CoutaFija as limiteInferior
			,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
			,LimiteSuperior as CuotaFija 
			,1 - Porcentaje as Porcentaje
		from Nomina.tblDetalleTablasImpuestos 
		where IDTablaImpuesto = @IDTablaImpuestoSemanal 
	) a

	INSERT INTO NOMINA.tblDetalleTablasImpuestos
	SELECT * FROM #TempISRInversoSemanal

--------------------------------------Tabla Decenal-----------------------------------------------

	DECLARE @IDTablaImpuestoDecenal int = 0,
			@IDTablaInversoDecenal int = 0,
			@IDTablaSubsidioDecenal int=0;

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPDecenal,@Ejercicio,@IDCalculoISRSueldos,CONCAT('ISR DECENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaImpuestoDecenal=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPDecenal,@Ejercicio,@IDCalculoSubsidio,CONCAT('SUBSIDIO DECENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaSubsidioDecenal=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPDecenal,@Ejercicio,@IDCalculoISRInverso,CONCAT('ISR INVERSO DECENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaInversoDecenal=@@IDENTITY

	IF object_ID('TEMPDB..#TempISRDecenal') IS NOT NULL  
		DROP TABLE #TempISRDecenal

	IF object_ID('TEMPDB..#TempSubsidioDecenal') IS NOT NULL  
		DROP TABLE #TempSubsidioDecenal
	
	IF object_ID('TEMPDB..#TempISRInversoDecenal') IS NOT NULL  
		DROP TABLE #TempISRInversoDecenal

	CREATE TABLE #TempISRDecenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	CREATE TABLE #TempSubsidioDecenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	CREATE TABLE #TempISRInversoDecenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	INSERT INTO #TempISRDecenal 
	VALUES 
		(@IDTablaImpuestoDecenal,0.01,245.4,0,0.0192)
		,(@IDTablaImpuestoDecenal,245.41,2082.9,4.7,0.064)
		,(@IDTablaImpuestoDecenal,2082.91,3660.5,122.3,0.1088)
		,(@IDTablaImpuestoDecenal,3660.51,4255.2,294,0.16)
		,(@IDTablaImpuestoDecenal,4255.21,5094.6,389.1,0.1792)
		,(@IDTablaImpuestoDecenal,5094.61,10275.2,539.5,0.2136)
		,(@IDTablaImpuestoDecenal,10275.21,16195.1,1646.1,0.2352)
		,(@IDTablaImpuestoDecenal,16195.11,30919,3038.5,0.3)
		,(@IDTablaImpuestoDecenal,30919.01,41225.4,7455.6,0.32)
		,(@IDTablaImpuestoDecenal,41225.41,123676.2,10753.7,0.34)
		,(@IDTablaImpuestoDecenal,123676.21,999999999,38786.9,0.35)

 

	INSERT INTO #TempSubsidioDecenal 
	VALUES
		(@IDTablaSubsidioDecenal,0.01,581.9,133.9,0)
		,(@IDTablaSubsidioDecenal,581.91,872.8,133.8,0)
		,(@IDTablaSubsidioDecenal,872.81,1142.4,133.8,0)
		,(@IDTablaSubsidioDecenal,1142.41,1163.8,129.2,0)
		,(@IDTablaSubsidioDecenal,1163.81,1462.5,125.8,0)
		,(@IDTablaSubsidioDecenal,1462.51,1551.7,116.5,0)
		,(@IDTablaSubsidioDecenal,1551.71,1755.1,106.9,0)
		,(@IDTablaSubsidioDecenal,1755.11,2047.6,96.9,0)
		,(@IDTablaSubsidioDecenal,2047.61,2340.1,83.4,0)
		,(@IDTablaSubsidioDecenal,2340.11,2428.4,71.6,0)
		,(@IDTablaSubsidioDecenal,2428.41,999999999,0,0)


	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	SELECT * FROM #TempISRDecenal
	UNION
	SELECT * FROM #TempSubsidioDecenal

	INSERT INTO #TempISRInversoDecenal 
	Select 
		@IDTablaInversoDecenal,
		[LimiteInferior],

		case when [LimiteSuperior] is null then 999999999.0000 
										   else LimiteSuperior end 
										   as LimiteSuperior,

		CASE WHEN LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
																		ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
																		AS CuotaFija,
		[Porcentaje] 
	from ( 
		Select 
			 LimiteInferior - CoutaFija as limiteInferior
			,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
			,LimiteSuperior as CuotaFija 
			,1 - Porcentaje as Porcentaje
		from Nomina.tblDetalleTablasImpuestos 
		where IDTablaImpuesto = @IDTablaImpuestoDecenal 
	) a


	INSERT INTO NOMINA.tblDetalleTablasImpuestos
	SELECT * FROM #TempISRInversoDecenal

--------------------------------------Tabla Catorcenal-----------------------------------------------

	DECLARE @IDTablaImpuestoCatorcenal int = 0,
			@IDTablaInversoCatorcenal int = 0,
			@IDTablaSubsidioCatorcenal int=0;

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	)
	VALUES (@IDPPCatorcenal,@Ejercicio,@IDCalculoISRSueldos,CONCAT('ISR CATORCENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaImpuestoCatorcenal=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	)
	VALUES (@IDPPCatorcenal,@Ejercicio,@IDCalculoSubsidio,CONCAT('SUBSIDIO CATORCENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaSubsidioCatorcenal=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	)
	VALUES (@IDPPCatorcenal,@Ejercicio,@IDCalculoISRInverso,CONCAT('ISR INVERSO CATORCENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaInversoCatorcenal=@@IDENTITY

	IF object_ID('TEMPDB..#TempISRCatorcenal') IS NOT NULL  
	DROP TABLE #TempISRCatorcenal


	CREATE TABLE #TempISRCatorcenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	IF object_ID('TEMPDB..#TempSubsidioCatorcenal') IS NOT NULL  
	DROP TABLE #TempSubsidioCatorcenal


	CREATE TABLE #TempSubsidioCatorcenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)


	IF object_ID('TEMPDB..#TempISRInversoCatorcenal') IS NOT NULL  
	DROP TABLE #TempISRInversoCatorcenal


	CREATE TABLE #TempISRInversoCatorcenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)


	INSERT INTO #TempISRCatorcenal 
	VALUES 
		( @IDTablaImpuestoCatorcenal,0.01,343.56,0,0.0192)
		,(@IDTablaImpuestoCatorcenal,245.41,2082.9,4.7,0.064)
		,(@IDTablaImpuestoCatorcenal,2082.91,3660.5,122.3,0.1088)
		,(@IDTablaImpuestoCatorcenal,3660.51,4255.2,294,0.16)
		,(@IDTablaImpuestoCatorcenal,4255.21,5094.6,389.1,0.1792)
		,(@IDTablaImpuestoCatorcenal,5094.61,10275.2,539.5,0.2136)
		,(@IDTablaImpuestoCatorcenal,10275.21,16195.1,1646.1,0.2352)
		,(@IDTablaImpuestoCatorcenal,16195.11,30919,3038.5,0.3)
		,(@IDTablaImpuestoCatorcenal,30919.01,41225.4,7455.6,0.32)
		,(@IDTablaImpuestoCatorcenal,41225.41,123676.2,10753.7,0.34)
		,(@IDTablaImpuestoCatorcenal,123676.21,999999999,38786.9,0.35)

 

	INSERT INTO #TempSubsidioCatorcenal 
	VALUES
		( @IDTablaSubsidioCatorcenal,0.01,581.9,133.9,0)
		,(@IDTablaSubsidioCatorcenal,581.91,872.8,133.8,0)
		,(@IDTablaSubsidioCatorcenal,872.81,1142.4,133.8,0)
		,(@IDTablaSubsidioCatorcenal,1142.41,1163.8,129.2,0)
		,(@IDTablaSubsidioCatorcenal,1163.81,1462.5,125.8,0)
		,(@IDTablaSubsidioCatorcenal,1462.51,1551.7,116.5,0)
		,(@IDTablaSubsidioCatorcenal,1551.71,1755.1,106.9,0)
		,(@IDTablaSubsidioCatorcenal,1755.11,2047.6,96.9,0)
		,(@IDTablaSubsidioCatorcenal,2047.61,2340.1,83.4,0)
		,(@IDTablaSubsidioCatorcenal,2340.11,2428.4,71.6,0)
		,(@IDTablaSubsidioCatorcenal,2428.41,999999999,0,0)


	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	SELECT * FROM #TempISRCatorcenal
	UNION
	SELECT * FROM #TempSubsidioCatorcenal

	INSERT INTO #TempISRInversoCatorcenal 
	Select 
		@IDTablaInversoCatorcenal,
		[LimiteInferior],

		case when [LimiteSuperior] is null then 999999999.0000 
										   else LimiteSuperior end 
										   as LimiteSuperior,

		CASE WHEN LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
																		ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
																		AS CuotaFija,
		[Porcentaje] 
	from ( 
		Select 
			 LimiteInferior - CoutaFija as limiteInferior
			,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
			,LimiteSuperior as CuotaFija 
			,1 - Porcentaje as Porcentaje
		from Nomina.tblDetalleTablasImpuestos 
		where IDTablaImpuesto = @IDTablaImpuestoCatorcenal 
	) a



	INSERT INTO NOMINA.tblDetalleTablasImpuestos
	SELECT * FROM #TempISRInversoCatorcenal







	---------------------------tabla quincenal------------------------------------------------------


	DECLARE @IDTablaImpuestoQuincenal int = 0,
			@IDTablaInversoQuincenal int = 0 ,
			@IDTablaSubsidioQuincenal int=0;

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPQuincenal,@Ejercicio,@IDCalculoISRSueldos,CONCAT('ISR QUINCENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaImpuestoQuincenal=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPQuincenal,@Ejercicio,@IDCalculoSubsidio,CONCAT('SUBSIDIO QUINCENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaSubsidioQuincenal=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPQuincenal,@Ejercicio,@IDCalculoISRInverso,CONCAT('ISR INVERSO QUINCENAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaInversoQuincenal=@@IDENTITY

	IF object_ID('TEMPDB..#TempISRQuincenal') IS NOT NULL  
	DROP TABLE #TempISRQuincenal


	CREATE TABLE #TempISRQuincenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	IF object_ID('TEMPDB..#TempSubsidioQuincenal') IS NOT NULL  
	DROP TABLE #TempSubsidioQuincenal


	CREATE TABLE #TempSubsidioQuincenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
    
	)

	IF object_ID('TEMPDB..#TempISRInversoQuincenal') IS NOT NULL  
	DROP TABLE #TempISRInversoQuincenal


	CREATE TABLE #TempISRInversoQuincenal(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	INSERT INTO #TempISRQuincenal VALUES 
	(@IDTablaImpuestoQuincenal,0.01,368.1,0,0.0192)
	,(@IDTablaImpuestoQuincenal,368.11,3124.35,7.05,0.064)
	,(@IDTablaImpuestoQuincenal,3124.36,5490.75,183.45,0.1088)
	,(@IDTablaImpuestoQuincenal,5490.76,6382.8,441,0.16)
	,(@IDTablaImpuestoQuincenal,6382.81,7641.9,583.65,0.1792)
	,(@IDTablaImpuestoQuincenal,7641.91,15412.8,809.25,0.2136)
	,(@IDTablaImpuestoQuincenal,15412.81,24292.65,2469.15,0.2352)
	,(@IDTablaImpuestoQuincenal,24292.66,46378.5,4557.75,0.3)
	,(@IDTablaImpuestoQuincenal,46378.51,61838.1,11183.4,0.32)
	,(@IDTablaImpuestoQuincenal,61838.11,185514.3,16130.55,0.34)
	,(@IDTablaImpuestoQuincenal,185514.31,999999999,58180.35,0.35)

 

	INSERT INTO #TempSubsidioQuincenal VALUES
	(@IDTablaSubsidioQuincenal,0.01,872.85,200.85,0)
	,(@IDTablaSubsidioQuincenal,872.86,1309.2,200.7,0)
	,(@IDTablaSubsidioQuincenal,1309.21,1713.6,200.7,0)
	,(@IDTablaSubsidioQuincenal,1713.61,1745.7,193.8,0)
	,(@IDTablaSubsidioQuincenal,1745.71,2193.75,188.7,0)
	,(@IDTablaSubsidioQuincenal,2193.76,2327.55,174.75,0)
	,(@IDTablaSubsidioQuincenal,2327.56,2632.65,160.35,0)
	,(@IDTablaSubsidioQuincenal,2632.66,3071.4,145.35,0)
	,(@IDTablaSubsidioQuincenal,3071.41,3510.15,125.1,0)
	,(@IDTablaSubsidioQuincenal,3510.16,3642.6,107.4,0)
	,(@IDTablaSubsidioQuincenal,3642.61,999999999,0,0)


	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	SELECT * FROM #TempISRQuincenal
	UNION
	SELECT * FROM #TempSubsidioQuincenal

	INSERT INTO #TempISRInversoQuincenal
	Select 
	@IDTablaInversoQuincenal,
	[LimiteInferior],

	case when [LimiteSuperior] is null then 999999999.0000 
									   else LimiteSuperior end 
									   as LimiteSuperior,

	CASE WHEN LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
																	ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
																	AS CuotaFija,
	[Porcentaje] 
	from 
		( Select 
		 LimiteInferior - CoutaFija as limiteInferior
		,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
		,LimiteSuperior as CuotaFija 
		,1 - Porcentaje as Porcentaje
		from Nomina.tblDetalleTablasImpuestos 
		where IDTablaImpuesto = @IDTablaImpuestoQuincenal ) a



	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	SELECT * FROM #TempISRInversoQuincenal



	-------------------------------------TABLA MENSUAL--------------------------------------------


	DECLARE @IDTablaImpuestoMensual int = 0,
			@IDTablaInversoMensual int = 0,
			@IDTablaSubsidioMensual int=0;

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPMensual,@Ejercicio,@IDCalculoISRSueldos,CONCAT('ISR MENSUAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaImpuestoMensual=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPMensual,@Ejercicio,@IDCalculoSubsidio,CONCAT('SUBSIDIO MENSUAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaSubsidioMensual=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPMensual,@Ejercicio,@IDCalculoISRInverso,CONCAT('ISR INVERSO MENSUAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaInversoMensual=@@IDENTITY

	IF object_ID('TEMPDB..#TempISRMensual') IS NOT NULL  
	DROP TABLE #TempISRMensual


	CREATE TABLE #TempISRMensual(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	IF object_ID('TEMPDB..#TempSubsidioMensual') IS NOT NULL  
	DROP TABLE #TempSubsidioMensual


	CREATE TABLE #TempSubsidioMensual(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)


	IF object_ID('TEMPDB..#TempISRInversoMensual') IS NOT NULL  
	DROP TABLE #TempISRInversoMensual


	CREATE TABLE #TempISRInversoMensual(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)

	INSERT INTO #TempISRMensual VALUES
	(@IDTablaImpuestoMensual,0.01,746.04,0,0.0192)
	,(@IDTablaImpuestoMensual,746.05,6332.05,14.32,0.064)
	,(@IDTablaImpuestoMensual,6332.06,11128.01,371.83,0.1088)
	,(@IDTablaImpuestoMensual,11128.02,12935.82,893.63,0.16)
	,(@IDTablaImpuestoMensual,12935.83,15487.71,1182.88,0.1792)
	,(@IDTablaImpuestoMensual,15487.72,31236.49,1640.18,0.2136)
	,(@IDTablaImpuestoMensual,31236.5,49233,5004.12,0.2352)
	,(@IDTablaImpuestoMensual,49233.01,93993.9,9236.89,0.3)
	,(@IDTablaImpuestoMensual,93993.91,125325.2,22665.17,0.32)
	,(@IDTablaImpuestoMensual,125325.21,375975.61,32691.18,0.34)
	,(@IDTablaImpuestoMensual,375975.62,999999999,117912.32,0.35)


 

	INSERT INTO #TempSubsidioMensual VALUES
	(@IDTablaSubsidioMensual,0.01,1768.96,407.02,0)
	,(@IDTablaSubsidioMensual,1768.97,2653.38,406.83,0)
	,(@IDTablaSubsidioMensual,2653.39,3472.84,406.62,0)
	,(@IDTablaSubsidioMensual,3472.85,3537.87,392.77,0)
	,(@IDTablaSubsidioMensual,3537.88,4446.15,382.46,0)
	,(@IDTablaSubsidioMensual,4446.16,4717.18,354.23,0)
	,(@IDTablaSubsidioMensual,4717.19,5335.42,324.87,0)
	,(@IDTablaSubsidioMensual,5335.43,6224.67,294.63,0)
	,(@IDTablaSubsidioMensual,6224.68,7113.9,253.54,0)
	,(@IDTablaSubsidioMensual,7113.91,7382.33,217.61,0)
	,(@IDTablaSubsidioMensual,7382.34,999999999,0,0)

	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	SELECT * FROM #TempISRMensual
	UNION
	SELECT * FROM #TempSubsidioMensual

	INSERT INTO #TempISRInversoMensual
	Select 
	@IDTablaInversoMensual,
	[LimiteInferior],

	case when [LimiteSuperior] is null then 999999999.0000 
									   else LimiteSuperior end 
									   as LimiteSuperior,

	CASE WHEN LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
																	ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
																	AS CuotaFija,
	[Porcentaje] 
	from 
		( Select 
		 LimiteInferior - CoutaFija as limiteInferior
		,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
		,LimiteSuperior as CuotaFija 
		,1 - Porcentaje as Porcentaje
		from Nomina.tblDetalleTablasImpuestos 
		where IDTablaImpuesto = @IDTablaImpuestoMensual ) a


	INSERT INTO NOMINA.tblDetalleTablasImpuestos
	SELECT * FROM #TempISRInversoMensual


	----------------------------------------------TABLA ANUAL-------------------------------------------------------------------------

	DECLARE @IDTablaImpuestoAnual int = 0,
	@IDTablaInversoAnual int = 0;
        

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPAnual,@Ejercicio,@IDCalculoISRSueldos,CONCAT('ISR ANUAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaImpuestoAnual=@@IDENTITY

	INSERT INTO NOMINA.tblTablasImpuestos(
		IDPeriodicidadPago
		,Ejercicio
		,IDCalculo
		,Descripcion
		,IDPais
	) 
	VALUES (@IDPPAnual,@Ejercicio,@IDCalculoISRInverso,CONCAT('ISR INVERSO ANUAL ',CAST(@Ejercicio AS VARCHAR(4))),@IDPais)      
	SET @IDTablaInversoAnual=@@IDENTITY


	IF object_ID('TEMPDB..#TempISRAnual') IS NOT NULL  
	DROP TABLE #TempISRAnual


	CREATE TABLE #TempISRAnual(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)


	IF object_ID('TEMPDB..#TempISRInversoAnual') IS NOT NULL  
	DROP TABLE #TempISRInversoAnual


	CREATE TABLE #TempISRInversoAnual(
		IDTablaImpuesto int,
		[LimiteInferior] [decimal](18, 4),
		[LimiteSuperior] [decimal](18, 4),
		[CoutaFija] [decimal](18, 4),
		[Porcentaje] [decimal](18, 4)
	)


	INSERT INTO #TempISRAnual VALUES
	(@IDTablaImpuestoAnual,0.01,2238.12,0,0.0192)
	,(@IDTablaImpuestoAnual,8952.5,75984.55,171.88,0.064)
	,(@IDTablaImpuestoAnual,75984.56,133536.07,4461.94,0.1088)
	,(@IDTablaImpuestoAnual,133536.08,155229.8,10723.55,0.16)
	,(@IDTablaImpuestoAnual,155229.81,185852.57,14194.54,0.1792)
	,(@IDTablaImpuestoAnual,185852.58,374837.88,19682.13,0.2136)
	,(@IDTablaImpuestoAnual,374837.89,590795.99,60049.4,0.2352)
	,(@IDTablaImpuestoAnual,590796,1127926.84,110842.74,0.3)
	,(@IDTablaImpuestoAnual,1127926.85,1503902.46,271981.99,0.32)
	,(@IDTablaImpuestoAnual,1503902.47,4511707.37,392294.17,0.34)
	,(@IDTablaImpuestoAnual,4511707.38,999999999,1414947.85,0.35)


	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	SELECT * FROM #TempISRAnual

	INSERT INTO #TempISRInversoAnual
	Select 
	@IDTablaInversoAnual,
	[LimiteInferior],

	case when [LimiteSuperior] is null then 999999999.0000 
									   else LimiteSuperior end 
									   as LimiteSuperior,

	CASE WHEN LAG(CuotaFija) OVER (ORDER BY LimiteInferior) IS NULL THEN 0 
																	ELSE LAG(CuotaFija) OVER (ORDER BY LimiteInferior) END 
																	AS CuotaFija,
	[Porcentaje] 
	from 
		( Select 
		 LimiteInferior - CoutaFija as limiteInferior
		,LimiteSuperior - LEAD(CoutaFija) OVER(ORDER BY CoutaFija) as LimiteSuperior
		,LimiteSuperior as CuotaFija 
		,1 - Porcentaje as Porcentaje
		from Nomina.tblDetalleTablasImpuestos 
		where IDTablaImpuesto = @IDTablaImpuestoAnual ) a

 
	INSERT INTO NOMINA.tblDetalleTablasImpuestos(
		IDTablaImpuesto 
		,[LimiteInferior]
		,[LimiteSuperior]
		,[CoutaFija]		
		,[Porcentaje]	
	)
	SELECT * FROM #TempISRInversoAnual






	--------BLOQUE ACTUALIZACION ISR---------------

	INSERT INTO Nomina.tblSalariosMinimos(
		Fecha
		,SalarioMinimo
		,SalarioMinimoFronterizo
		,UMA
		,FactorDescuento
		,IDPais
		,AjustarUMI
	)
	SELECT TOP 1 
		'2023-01-01',
		207.44 as minimo, 
		260.00 as SalarioMinimoFronterizo ,
		UMA,
		FactorDescuento, 
		151 as idpais, 
		0 as AjustarUmi 
	FROM Nomina.tblSalariosMinimos 
	ORDER BY Fecha DESC

	delete from IMSS.tblCatPorcentajesPago where Fecha = '2023-01-01'

	INSERT INTO IMSS.tblCatPorcentajesPago
	SELECT TOP 1 
	'2023-01-01' as fecha
	,0.2040 as CuotaFija
	,ExcedentePatronal
	,0.0040 as ExcedenteObrera
	,PrestacionesDineroPatronal
	,PrestacionesDineroObrera
	,GMPensionadosPatronal
	,GMPensionadosObrera
	,RiesgosTrabajo
	,InvalidezVidaPatronal
	,0.00625 as InvalidezVidaObrera
	,GuarderiasPrestacionesSociales
	,CesantiaVejezPatron
	,SeguroRetiro
	,Infonavit
	,0.01125 as CesantiaVejezObrera
	,ReservaPensionado
	,0.00 as CuotaProporcionalObrera
	FROM IMSS.tblCatPorcentajesPago ORDER BY FECHA DESC

	DECLARE @P2 AS TABLE(
	Fecha varchar(max),
	FechaReal varchar(max),
	Descripcion varchar(max),
	Autorizado int,
	idpais int
	)

	INSERT INTO @P2 VALUES('2023-01-01','2023-01-01','AÑO NUEVO',1,151)
	INSERT INTO @P2 VALUES('2023-02-06','2023-02-05','DIA DE LA CONSTITUCION MEXICANA',1,151)
	INSERT INTO @P2 VALUES('2023-03-20','2023-03-21','NATALICIO DE BENITO JUAREZ',1,151)
	INSERT INTO @P2 VALUES('2023-05-01','2023-05-01','DIA DEL TRABAJO',1,151)
	INSERT INTO @P2 VALUES('2023-09-16','2023-09-16','INDEPENDENCIA DE MEXICO',1,151)
	INSERT INTO @P2 VALUES('2023-11-20','2023-11-20','REVOLUCION MEXICANA',1,151)
	INSERT INTO @P2 VALUES('2023-12-25','2023-12-25','NAVIDAD',1,151)


	/*FALTA LA TRADUCCION*/
	INSERT INTO ASISTENCIA.TblCatDiasFestivos(Fecha, FechaReal, Descripcion, Autorizado, IDPais)
	SELECT T.Fecha,T.FechaReal,T.Descripcion,T.Autorizado, T.idpais
	FROM @P2 T
GO
