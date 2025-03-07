USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAguinaldo_Excel_DUSGEM](
  @dtFiltros Nomina.dtFiltrosRH readonly    
 ,@IDUsuario int    
) as    
    
declare @empleados [RH].[dtEmpleados]        
 ,@IDPeriodoSeleccionado int=0        
 ,@periodo [Nomina].[dtPeriodos]        
 ,@configs [Nomina].[dtConfiguracionNomina]        
 ,@Conceptos [Nomina].[dtConceptos]        
 ,@IDTipoNomina int     
 ,@fechaIni  date        
 ,@fechaFin  date  
 ,@FechaIniVigencia date
 ,@FechaFinVigencia date
 ,@Incidencias varchar(max)
 ,@Ausentismos varchar(max)
 ,@Ejercicio int
 ,@Afectar Varchar(10) = 'FALSE'
 ,@IDPeriodoInicial int
 ,@IDConceptoAguinaldo int
 ,@IDConceptoAguinaldoComplemento INT
 ,@TipoIncapacidad varchar(max)
 ,@IDIdioma varchar(20)
 ,@DiasEjercicio INT
;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

  
  select top 1 @IDConceptoAguinaldo = IDConcepto from Nomina.tblCatConceptos where Codigo = '130' -- AGUINALDO
  select top 1 @IDConceptoAguinaldoComplemento = IDConcepto from Nomina.tblCatConceptos where Codigo = '729' -- AGUINALDO COMPLEMENTO

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
					  else 0  
					END  
 
	set @Ejercicio = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))  
					  else DATEPART(YEAR, GETDATE()) 
					END  
	set @fechaIni = cast(@Ejercicio as varchar(4))+'-01-01';
	set @fechaFin = cast(@Ejercicio as varchar(4))+'-12-31';
  
	set @FechaIniVigencia = case when exists (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) THEN (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))  
					  else getdate() 
					END  
	set @FechaFinVigencia = case when exists (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) THEN (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))  
					  else getdate() 
					END  
  
  	set @Incidencias = case when exists (Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Incidencias'),',')) THEN ((Select top 1 Value from @dtFiltros where Catalogo = 'Incidencias'))  
					  else ''
					END  
  	set @Ausentismos = case when exists (Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),',')) THEN ((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'))  
					  else ''
					END 
	 set @TipoIncapacidad = case when exists (Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoIncapacidad'),',')) THEN ((Select top 1 Value from @dtFiltros where Catalogo = 'TipoIncapacidad'))  
					  else ''
					END 

	set @IDPeriodoInicial = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))  
					  else 0  
					END  
	set @Afectar = case when exists (Select top 1 cast(item as varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),',')) THEN (Select top 1 cast(item as Varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),','))  
					  else 'FALSE' 
					END  

	SELECT @DiasEjercicio = DATEDIFF(DAY,@FechaIni,@FechaFin)+1


			if object_id('tempdb..#TempCatTiposPrestacionesDetalle') is not null
				drop table #TempCatTiposPrestacionesDetalle

				select * 
					into #TempCatTiposPrestacionesDetalle
				from RH.tblCatTiposPrestacionesDetalle
  
 -- /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */        
    insert into @empleados        
    exec [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,@FechaIni=@FechaIniVigencia, @Fechafin = @FechaFinVigencia ,@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario     


	
			if object_id('tempdb..#TempDatosAfectar') is not null
				drop table #TempDatosAfectar



	select
		  Empleados.IDEmpleado
		, Empleados.ClaveEmpleado as [Clave]
		, Empleados.NOMBRECOMPLETO as [NOMBRE COMPLETO]
		, depto.Codigo +' - '+ JSON_VALUE(depto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [DEPTO]
		, Suc.Codigo +' - '+ Suc.Descripcion as [SUCURSAL]
		, Puestos.Codigo +' - '+ JSON_VALUE(Puestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [PUESTO]
		, tp.Codigo +' - '+ JSON_VALUE(tp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as [PRESTACION]
		, FORMAT(Empleados.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
		, [Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin) as [ANIOS CUMPLIDOS]
		, CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin) + 1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+ 1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END [DIAS TRABAJADOS EJERCICIO]
		, [Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) as [INCAPACIDADES]
		, [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) as [INCIDENCIAS]
		, [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) as [AUSENTISMOS]

		, [DIAS A PAGAR] = ((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			   +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			   ))
		, [DIAS PRESTACION AGUINALDO] = TPD.DiasAguinaldo

		,[DIAS A PAGAR AGUINALDO] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			    +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			   ))

		,[SALARIO DIARIO] = Empleados.SalarioDiario

		--,[SALARIO DIARIO REAL] = Empleados.SalarioDiarioReal

		,[SALARIO DIARIO REAL] = (CAST(ISNULL(DEE.Valor,0) AS decimal(18,2)) / 2)

		,[IMPORTE AGUINALDO] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			    +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin))) * Empleados.SalarioDiario

		/*,[IMPORTE AGUINALDO REAL] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
					+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin)
			    +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin))) * Empleados.SalarioDiarioReal*/
		 ,CAST(0 AS decimal(18,2)) AS [IMPORTE AGUINALDO REAL]
		into #TempDatosAfectar
	from @empleados Empleados
		left join RH.tblCatDepartamentos depto with(nolock)
			on Empleados.IDDepartamento = depto.IDDepartamento
		left join RH.tblCatSucursales Suc with(nolock)
			on Empleados.IDSucursal = Suc.IDSucursal
		left join RH.tblCatPuestos Puestos with(nolock)
			on Empleados.IDPuesto = Puestos.IDPuesto
		left join RH.tblCatTiposPrestaciones TP with(nolock)
			on tp.IDTipoPrestacion = Empleados.IDTipoPrestacion
		LEFT JOIN RH.tblCatTiposPrestacionesDetalle TPD
			on Empleados.IDTipoPrestacion = TPD.IDTipoPrestacion
			and TPD.Antiguedad = CEILING([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)) 
		LEFT JOIN [RH].[tblDatosExtraEmpleados] DEE
			ON DEE.IDEmpleado = Empleados.IDEmpleado
			AND DEE.IDDatoExtra = 3
			
	ORDER BY Empleados.ClaveEmpleado ASC

	UPDATE #TempDatosAfectar
		 SET [SALARIO DIARIO REAL] = (([SALARIO DIARIO REAL] / @DiasEjercicio) * [DIAS A PAGAR])

	UPDATE #TempDatosAfectar
		SET [IMPORTE AGUINALDO REAL] = CASE WHEN ISNULL([SALARIO DIARIO REAL],0) = 0 THEN 0.00 ELSE ISNULL([SALARIO DIARIO REAL],0) - ISNULL([IMPORTE AGUINALDO],0) END

	SELECT 
		  [Clave]
		, [NOMBRE COMPLETO]
		, [DEPTO]
		, [SUCURSAL]
		, [PUESTO]
		, [PRESTACION]
		, [FECHA ANTIGUEDAD]
		, [ANIOS CUMPLIDOS]
		, [DIAS TRABAJADOS EJERCICIO]
		, [INCAPACIDADES]
		, [INCIDENCIAS]
		, [AUSENTISMOS]
		, [DIAS A PAGAR]
		, [DIAS PRESTACION AGUINALDO] 
		, [DIAS A PAGAR AGUINALDO] 
		, [SALARIO DIARIO] 
		, [SALARIO DIARIO REAL]
		, [IMPORTE AGUINALDO]
		, [IMPORTE AGUINALDO REAL] AS [AGUINALDO COMPLEMENTO]
	FROM #TempDatosAfectar
	ORDER BY Clave ASC


	IF OBJECT_ID('TempDB..#TempAguinaldo') IS NOT NULL DROP TABLE #TempAguinaldo;

	CREATE TABLE #TempAguinaldo 
	(
		IDPeriodo INT
	   ,IDEmpleado INT
	   ,IDConcepto INT
	   ,CantidadMonto DECIMAL(18,2)
	);

	INSERT INTO #TempAguinaldo
	SELECT 
		@IDPeriodoInicial
	   ,IDEmpleado
	   ,@IDConceptoAguinaldo
	   ,ISNULL([IMPORTE AGUINALDO],0) --FISCAL
	FROM #TempDatosAfectar

	INSERT INTO #TempAguinaldo
	SELECT 
		@IDPeriodoInicial
	   ,IDEmpleado
	   ,@IDConceptoAguinaldoComplemento
	   ,ISNULL([IMPORTE AGUINALDO REAL],0) --COMPLEMENTO
	FROM #TempDatosAfectar
	
	--SELECT * FROM #TempAguinaldo RETURN

	IF(@Afectar = 'TRUE')
	BEGIN

	PRINT 'AFECTAR FISCAL Y COMPLEMENTO'

		MERGE Nomina.tblDetallePeriodo AS TARGET
		USING #TempAguinaldo AS SOURCE
			ON TARGET.IDPeriodo = SOURCE.IDPeriodo
				AND TARGET.IDConcepto = SOURCE.IDConcepto
				AND TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED THEN
			UPDATE
				SET TARGET.CantidadMonto  = ISNULL(SOURCE.CantidadMonto,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado, IDPeriodo, IDConcepto, CantidadMonto)  
			VALUES(SOURCE.IDEmpleado, SOURCE.IDPeriodo , SOURCE.IDConcepto,  ISNULL(SOURCE.CantidadMonto,0)
			)
		/*WHEN NOT MATCHED BY SOURCE THEN
			DELETE*/;
	END

	/*IF(@Afectar = 'TRUE')
	BEGIN
		MERGE Nomina.tblDetallePeriodo AS TARGET
		USING #TempDatosAfectar AS SOURCE
			ON TARGET.IDPeriodo = @IDPeriodoInicial
				and TARGET.IDConcepto = @IDConceptoAguinaldo
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.CantidadMonto  = isnull(SOURCE.[IMPORTE AGUINALDO] ,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto, CantidadMonto)  
			VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoAguinaldo,  
			isnull(SOURCE.[IMPORTE AGUINALDO] ,0)
			)
		;
	END*/
GO
