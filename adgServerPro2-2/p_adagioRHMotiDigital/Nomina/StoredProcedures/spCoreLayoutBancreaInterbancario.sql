USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCoreLayoutBancreaInterbancario](    
	@IDPeriodo int,    
	@FechaDispersion date,    
	@IDLayoutPago int,
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly,
	@MarcarPagados bit = 0,     
	@IDUsuario int      
)    
AS    
BEGIN  

	DECLARE     
		@empleados [RH].[dtEmpleados]      
		,@ListaEmpleados VARCHAR(max)    
		,@periodo [Nomina].[dtPeriodos]  
		,@fechaIniPeriodo  DATE                  
		,@fechaFinPeriodo  DATE
		,@IDTipoNomina INT 

		--PARAMETROS  
		,@CuentaCargo VARCHAR(11)  
		,@Referencia VARCHAR(7)  
		,@Concepto VARCHAR(60)  
	;

 	INSERT INTO @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,Especial)                  
	SELECT IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,Cerrado,General,Finiquito,isnull(Especial,0)
	FROM Nomina.TblCatPeriodos WITH(NOLOCK)                 
	WHERE IDPeriodo = @IDPeriodo                  
                  
	SELECT TOP 1 @IDTipoNomina = IDTipoNomina ,@fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago                  
	FROM @periodo                  
	              
                
	/* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */                  
	INSERT INTO @empleados                  
	EXEC [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros ,@IDUsuario= @IDUsuario   
  
	SELECT  @CuentaCargo = lpp.Valor  
	FROM Nomina.tblLayoutPago lp  
		INNER JOIN Nomina.tblLayoutPagoParametros lpp ON lp.IDLayoutPago = lpp.IDLayoutPago  
		INNER JOIN Nomina.tblCatTiposLayoutParametros ctlp ON ctlp.IDTipoLayout = lp.IDTipoLayout  
			AND ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	WHERE lp.IDLayoutPago = @IDLayoutPago AND ctlp.Parametro = 'Cuenta Cargo'  
  
	SELECT  @Referencia = lpp.Valor  
	FROM Nomina.tblLayoutPago lp  
		INNER JOIN Nomina.tblLayoutPagoParametros lpp ON lp.IDLayoutPago = lpp.IDLayoutPago  
		INNER JOIN Nomina.tblCatTiposLayoutParametros ctlp ON ctlp.IDTipoLayout = lp.IDTipoLayout  
			AND ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	WHERE lp.IDLayoutPago = @IDLayoutPago AND ctlp.Parametro = 'Referencia'  
     
	SELECT  @Concepto = lpp.Valor  
	FROM Nomina.tblLayoutPago lp  
		INNER JOIN Nomina.tblLayoutPagoParametros lpp ON lp.IDLayoutPago = lpp.IDLayoutPago  
		INNER JOIN Nomina.tblCatTiposLayoutParametros ctlp ON ctlp.IDTipoLayout = lp.IDTipoLayout  
			AND ctlp.IDTipoLayoutParametro = lpp.IDTipoLayoutParametro  
	WHERE lp.IDLayoutPago = @IDLayoutPago AND ctlp.Parametro = 'Concepto'     
	  
	DECLARE 
		@SumAll DECIMAL(16,2),
		@TotalRegistros INT = 0
	;

	SELECT @SumAll =  SUM(case when lp.ImporteTotal = 1 then isnull(dp.ImporteTotal1,0) else isnull(dp.ImporteTotal2,0) end)
		, @TotalRegistros = count(*)
	FROM @empleados e    
		INNER join Nomina.tblCatPeriodos p ON  p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe ON pe.IDEmpleado = e.IDEmpleado  
		LEFT JOIN Sat.tblCatBancos b ON pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp ON lp.IDLayoutPago = pe.IDLayoutPago    
		LEFT JOIN Nomina.tblCatTiposLayout tl ON tl.TipoLayout = 'BANCREA INTERBANCARIO'    
			AND lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp ON dp.IDPeriodo = @IDPeriodo    
			AND dp.IDConcepto = CASE WHEN ISNULL(p.Finiquito,0) = 0 THEN lp.IDConcepto ELSE lp.IDConceptoFiniquito END
			AND dp.IDEmpleado = e.IDEmpleado    
	WHERE pe.IDLayoutPago = @IDLayoutPago    

    
    IF object_id('tempdb..#tempHeader1') is not null DROP TABLE #tempHeader1;    
	IF object_id('tempdb..#tempempleados') IS NOT NULL DROP TABLE #tempempleados;    
    IF object_id('tempdb..#tempempleadosMarcables') is not null DROP TABLE #tempempleadosMarcables;    
    
    CREATE TABLE #tempHeader1(Respuesta VARCHAR(MAX));    
	CREATE TABLE #tempempleados(Respuesta VARCHAR(max)); 
	CREATE TABLE #tempempleadosMarcables(IDEmpleado INT,IDPeriodo INT, IDLayoutPago INT, IDBanco int, CuentaBancaria Varchar(18)); 
   
	INSERT INTO #tempHeader1(Respuesta)   
    SELECT     
	  replace([App].[fnAddString](8,FORMAT(getdate(),'ddMMyyyy'),'0',1)+'|'     
	  +[App].[fnAddString](11,@CuentaCargo,'0',1)  +'|'      
	  +[App].[fnAddString](21,Cast(@SumAll AS VARCHAR(MAX)),'',1) +'|'       
	  +[App].[fnAddString](5,Cast(@TotalRegistros AS VARCHAR(MAX)),'',1)+'|'           
    ,' ','')
    
	IF(ISNULL(@MarcarPagados,0) = 1)
	BEGIN 
		INSERT INTO  #tempempleadosMarcables(IDEmpleado, IDPeriodo, IDLayoutPago,  IDBanco, CuentaBancaria)
		SELECT e.IDEmpleado, p.IDPeriodo, lp.IDLayoutPago, b.IDBanco,
		CASE WHEN pe.IDBanco = tl.IDBanco AND (ISNULL(pe.Cuenta,'')<> '' or ISNULL(pe.Tarjeta,'') <> '') then 
											CASE WHEN ISNULL(pe.Cuenta,'')<> '' THEN [App].[fnAddString](11,ISNULL(REPLACE( pe.Cuenta,' ',''),''),'',1)      
											ELSE [App].[fnAddString](16,ISNULL(REPLACE( pe.Tarjeta,' ',''),''),'',1)    
											END
										ELSE [App].[fnAddString](18,ISNULL(REPLACE( pe.Interbancaria,' ',''),''),'',1) 
										END
		FROM  @empleados e     
			INNER join Nomina.tblCatPeriodos p ON p.IDPeriodo = @IDPeriodo   
			INNER JOIN RH.tblPagoEmpleado pe ON pe.IDEmpleado = e.IDEmpleado
			LEFT JOIN Sat.tblCatBancos b ON pe.IDBanco = b.IDBanco    
			INNER JOIN  Nomina.tblLayoutPago lp ON lp.IDLayoutPago = pe.IDLayoutPago    
			INNER JOIN Nomina.tblCatTiposLayout tl ON lp.IDTipoLayout = tl.IDTipoLayout    
			INNER JOIN Nomina.tblDetallePeriodo dp ON dp.IDPeriodo = @IDPeriodo    
				AND dp.IDConcepto = CASE WHEN ISNULL(p.Finiquito,0) = 0 THEN lp.IDConcepto ELSE lp.IDConceptoFiniquito END
				AND dp.IDEmpleado = e.IDEmpleado    
		WHERE  pe.IDLayoutPago = @IDLayoutPago  

		MERGE Nomina.tblControlLayoutDispersionEmpleado AS TARGET
			USING #tempempleadosMarcables AS SOURCE
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
  
	INSERT INTO #tempempleados(Respuesta)  
	SELECT replace(     
		[App].[fnAddString](8,FORMAT(getdate(),'ddMMyyyy'),'0',1)+'|'    
		+[App].[fnAddString](8,FORMAT(@FechaDispersion,'ddMMyyyy'),'0',1)   +'|'      
		+[App].[fnAddString](1,ISNULL(CASE WHEN pe.IDBanco = tl.IDBanco and (isnull(pe.Cuenta,'')<> '' or ISNULL(pe.Tarjeta,'') <> '') THEN 
										CASE WHEN isnull(pe.Cuenta,'')<> '' THEN '1' ELSE '3'END
									ELSE '2' 
									END ,'0'),'0',1)     +'|'   
		+ CASE WHEN pe.IDBanco = tl.IDBanco AND (ISNULL(pe.Cuenta,'')<> '' or ISNULL(pe.Tarjeta,'') <> '') then 
											CASE WHEN ISNULL(pe.Cuenta,'')<> '' THEN [App].[fnAddString](11,ISNULL(REPLACE( pe.Cuenta,' ',''),''),'',1)      
											ELSE [App].[fnAddString](16,ISNULL(REPLACE( pe.Tarjeta,' ',''),''),'',1)    
											END
										ELSE [App].[fnAddString](18,ISNULL(REPLACE( pe.Interbancaria,' ',''),''),'',1) 
										END  +'|'   
			+[App].[fnAddString](21,CAST(ISNULL(CASE WHEN lp.ImporteTotal = 1 THEN dp.ImporteTotal1 ELSE dp.ImporteTotal2 END,0) AS VARCHAR(max)),'',1)   +'|'     
			+[App].[fnAddString](7,ISNULL(@Referencia,''),'',2)     +'|'   
			+[App].[fnAddString](60,ISNULL(@Concepto,''),'',2)  +'|'      
			+[App].[fnAddString](21,'0','',2)     +'|'   
		,' ','')
	FROM  @empleados e     
		INNER join Nomina.tblCatPeriodos p ON p.IDPeriodo = @IDPeriodo   
		INNER JOIN RH.tblPagoEmpleado pe ON pe.IDEmpleado = e.IDEmpleado
		LEFT JOIN Sat.tblCatBancos b ON pe.IDBanco = b.IDBanco    
		INNER JOIN  Nomina.tblLayoutPago lp ON lp.IDLayoutPago = pe.IDLayoutPago    
		INNER JOIN Nomina.tblCatTiposLayout tl ON lp.IDTipoLayout = tl.IDTipoLayout    
		INNER JOIN Nomina.tblDetallePeriodo dp ON dp.IDPeriodo = @IDPeriodo    
			AND dp.IDConcepto = CASE WHEN ISNULL(p.Finiquito,0) = 0 THEN lp.IDConcepto ELSE lp.IDConceptoFiniquito END
			AND dp.IDEmpleado = e.IDEmpleado    
	WHERE pe.IDLayoutPago = @IDLayoutPago    
  
	IF object_id('tempdb..#tempResp') IS NOT NULL DROP TABLE #tempResp;    
	CREATE TABLE #tempResp(Respuesta VARCHAR(MAX), ID INT IDENTITY(1,1));    
  
	INSERT INTO #tempResp(Respuesta)  
	SELECT respuesta FROM #tempHeader1  
	UNION ALL
	SELECT respuesta FROM #tempempleados  
     
	SELECT Respuesta FROM #tempResp   ORDER BY ID asc 
    
END
GO
