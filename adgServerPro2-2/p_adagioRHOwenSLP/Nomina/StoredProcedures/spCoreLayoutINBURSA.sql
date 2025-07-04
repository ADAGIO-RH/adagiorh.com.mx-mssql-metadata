USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCoreLayoutINBURSA](
	
	@IDPeriodo INT
   ,@FechaDispersion DATE
   ,@IDLayoutPago INT
   ,@dtFiltros [Nomina].[dtFiltrosRH] READONLY
   ,@MarcarPagados BIT = 0 
   ,@IDUsuario INT

) AS

BEGIN

	DECLARE 
		 @Empleados [RH].[dtEmpleados]
		,@Periodo [Nomina].[dtPeriodos]
		,@FechaIniPeriodo DATE
		,@FechaFinPeriodo DATE
		,@IDTipoNomina INT
	;

	INSERT INTO @Periodo
	SELECT *
	FROM Nomina.tblCatPeriodos
	WHERE IDPeriodo = @IDPeriodo

	SELECT @FechaIniPeriodo = FechaInicioPago
		  ,@FechaFinPeriodo = FechaFinPago
		  ,@IDTipoNomina    = IDTipoNomina
	FROM @Periodo

	INSERT INTO @Empleados 
	EXECUTE [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina, @FechaIni = @FechaIniPeriodo, @FechaFin = @FechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario
	
	DECLARE @EmpleadosMarcables AS TABLE (
		IDEmpleado INT 
	   ,IDPeriodo INT 
	   ,IDLayoutPago INT
	   ,IDBanco int
	   , CuentaBancaria Varchar(18)
	);

		IF (ISNULL(@MarcarPagados,0) = 1)
		BEGIN
			INSERT INTO @EmpleadosMarcables (IDEmpleado,IDPeriodo,IDLayoutPago, IDBanco, CuentaBancaria)
			SELECT 
				 E.IDEmpleado
				,P.IDPeriodo
				,LP.IDLayoutPago
				,B.IDBanco
				,PE.Cuenta
			FROM @Empleados E
				INNER JOIN Nomina.tblCatPeriodos P ON P.IDPeriodo = @IDPeriodo
				INNER JOIN RH.tblPagoEmpleado PE ON PE.IDEmpleado = E.IDEmpleado
				LEFT JOIN Sat.tblCatBancos B ON PE.IDBanco = B.IDBanco
				INNER JOIN Nomina.tblLayoutPago LP ON LP.IDLayoutPago = PE.IDLayoutPago
				INNER JOIN Nomina.tblCatTiposLayout TL ON LP.IDTipoLayout = TL.IDTipoLayout    
				INNER JOIN Nomina.tblDetallePeriodo DP ON DP.IDPeriodo = @IDPeriodo
					AND LP.IDConcepto = DP.IDConcepto    
					AND DP.IDEmpleado = E.IDEmpleado 
			WHERE PE.IDLayoutPago = @IDLayoutPago

			MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET
			USING @EmpleadosMarcables AS SOURCE
				ON TARGET.IDPeriodo = SOURCE.IDPeriodo
					and TARGET.IDEmpleado = SOURCE.IDEmpleado
					and TARGET.IDLayoutPago = SOURCE.IDLayoutPago
			WHEN MATCHED THEN
				update                  
			Set                       
				TARGET.IDBanco  = SOURCE.IDBanco                 
				,TARGET.CuentaBancaria   = SOURCE.CuentaBancaria            
			WHEN NOT MATCHED BY TARGET THEN 
				INSERT(IDEmpleado,IDPeriodo,IDLayoutPago, IDBanco, CuentaBancaria)  
				VALUES(SOURCE.IDEmpleado,SOURCE.IDPeriodo,SOURCE.IDLayoutPago, SOURCE.IDBanco, SOURCE.CuentaBancaria);
		END

	DECLARE @TempRespuesta AS TABLE (
		Respuesta NVARCHAR(MAX)
	);

	INSERT INTO @TempRespuesta(Respuesta)
	SELECT 
		 TRIM([App].[fnAddString](6,ROW_NUMBER() OVER(ORDER BY (SELECT 1)),'',1))
		+TRIM([App].[fnAddString](1,',','',1))
		+TRIM([App].[fnAddString](7,ISNULL(SUBSTRING(E.ClaveEmpleado,4,4),''),'',1))
		+TRIM([App].[fnAddString](1,',','',1))
        +TRIM([App].[fnAddString](255,(isnull(E.Nombre,'')+isnull(e.SegundoNombre,'')+' '+isnull(e.Paterno,'')+' '+isnull(e.Materno,'')) COLLATE Cyrillic_General_CI_AI,'',1))    				 
		+TRIM([App].[fnAddString](1,',','',1))
		+TRIM([App].[fnAddString](20,ISNULL(PE.Cuenta,''),'',1))
		+TRIM([App].[fnAddString](1,',','',1))
		+TRIM([App].[fnAddString](20,CAST(ISNULL(CASE WHEN LP.ImporteTotal = 1 THEN DP.ImporteTotal1 ELSE DP.ImporteTotal2 END,0) AS VARCHAR(MAX)),'',1))
	FROM @Empleados E
		INNER JOIN Nomina.tblCatPeriodos P ON P.IDPeriodo = @IDPeriodo
		INNER JOIN RH.tblPagoEmpleado PE ON PE.IDEmpleado = E.IDEmpleado
		LEFT JOIN Sat.tblCatBancos B ON PE.IDBanco = B.IDBanco
		INNER JOIN Nomina.tblLayoutPago LP ON LP.IDLayoutPago = PE.IDLayoutPago
		INNER JOIN Nomina.tblCatTiposLayout TL ON LP.IDTipoLayout = TL.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo DP ON DP.IDPeriodo = @IDPeriodo
			AND LP.IDConcepto = DP.IDConcepto    
			AND DP.IDEmpleado = E.IDEmpleado 
	WHERE PE.IDLayoutPago = @IDLayoutPago

	SELECT * FROM @TempRespuesta

END
GO
