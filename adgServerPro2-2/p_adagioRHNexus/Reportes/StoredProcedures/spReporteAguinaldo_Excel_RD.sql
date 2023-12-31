USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReporteAguinaldo_Excel_RD](
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
 ,@TipoIncapacidad varchar(max)
 ;    
  
  select top 1 @IDConceptoAguinaldo = IDConcepto from Nomina.tblCatConceptos where Codigo = 'RD142' -- AGUINALDO

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
		, FORMAT(Empleados.FechaAntiguedad,'dd/MM/yyyy') as [FECHA ANTIGUEDAD]
		, [Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin) as [ANIOS CUMPLIDOS]
		, [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) as [TOTAL VACACIONES]
		, [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) * Empleados.SalarioDiario as [VACACIONES ORDINARIAS] 

		,[SALARIO DIARIO] = Empleados.SalarioDiario
		,[INGRESO ACUMULADO ENERO-NOV] = CASE WHEN (ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1) < (Empleados.SalarioDiario*30) THEN (Empleados.SalarioDiario*30) ELSE ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1 END 
		,[DICIEMBRE PROM] = CASE WHEN ([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)>1) THEN ((ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1) / 11)  ELSE ACUM2.ImporteTotal1/(([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin))*12) end
			--,[INGRESOS ACUMULADOS BASE RD] = (ACUM.ImporteTotal1 +  CASE WHEN ([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)>1) THEN ACUM.ImporteTotal1 / 11  ELSE ACUM2.ImporteTotal1/(([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin))*12) end)
		,[INGRESO ACUMULADO MERCURY] = ACUMMERCURY.ImporteTotal1
		--,[INGRESOS ACUMULADOS BASE RD] = [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
		--	   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
		--	   ELSE @fechaIni
		--	   END,@fechaFin) * Empleados.SalarioDiario
		--	   +
		--	CASE WHEN ACUM.ImporteTotal1 < (Empleados.SalarioDiario*30) THEN (Empleados.SalarioDiario*30) ELSE ACUM.ImporteTotal1 END 
		--	+
		--	CASE WHEN ([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)>1) THEN ACUM.ImporteTotal1 / 11  ELSE ACUM2.ImporteTotal1/(([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin))*12) end
		
		,[INGRESOS ACUMULADOS BASE RD] = ((CASE WHEN (ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1) < (Empleados.SalarioDiario*30) THEN (Empleados.SalarioDiario*30) ELSE ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1 END 
		+
		CASE WHEN ([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)>1) THEN ((ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1) / 11)  ELSE ACUM2.ImporteTotal1/(([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin))*12) end)
		+
		[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) * Empleados.SalarioDiario)

		,[IMPORTE AGUINALDO RD] = (((CASE WHEN (ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1) < (Empleados.SalarioDiario*30) THEN (Empleados.SalarioDiario*30) ELSE ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1 END 
		+
		CASE WHEN ([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin)>1) THEN ((ACUM.ImporteTotal1+ACUMMERCURY.ImporteTotal1) / 11)  ELSE ACUM2.ImporteTotal1/(([Asistencia].[fnBuscarAniosDiferencia](Empleados.FechaAntiguedad,@fechaFin))*12) end)
		+
		[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			   ELSE @fechaIni
			   END,@fechaFin) * Empleados.SalarioDiario))/12	
		
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
		CROSS APPLY  Nomina.[fnObtenerAcumuladoRangoFecha](Empleados.idempleado, 'RD550', '2022-01-01','2022-11-30') AS ACUM
		CROSS APPLY  Nomina.[fnObtenerAcumuladoRangoFecha](Empleados.idempleado, 'RD550', Empleados.FechaIngreso,'2022-11-30') AS ACUM2
		CROSS APPLY  Nomina.[fnObtenerAcumuladoRangoFecha](Empleados.idempleado, 'RD154', '2022-01-01','2022-11-30') AS ACUMMERCURY
		CROSS APPLY  Nomina.[fnObtenerAcumuladoRangoFecha](Empleados.idempleado, 'RD154', Empleados.FechaIngreso,'2022-11-30') AS ACUMMERCURY2



	ORDER BY Empleados.ClaveEmpleado ASC

	SELECT 
		[Clave]
		, [NOMBRE COMPLETO]
		, [FECHA ANTIGUEDAD]
		, [ANIOS CUMPLIDOS]
		, [TOTAL VACACIONES]
		, [VACACIONES ORDINARIAS]
		, [SALARIO DIARIO] 
		, [INGRESO ACUMULADO ENERO-NOV]
	  	, [INGRESO ACUMULADO MERCURY]
		, [DICIEMBRE PROM]
		, [INGRESOS ACUMULADOS BASE RD]
		, [IMPORTE AGUINALDO RD]
		
	FROM #TempDatosAfectar
	ORDER BY Clave ASC

	IF(@Afectar = 'TRUE')
	BEGIN
		MERGE Nomina.tblDetallePeriodo AS TARGET
		USING #TempDatosAfectar AS SOURCE
			ON TARGET.IDPeriodo = @IDPeriodoInicial
				and TARGET.IDConcepto = @IDConceptoAguinaldo
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.CantidadMonto  = isnull(SOURCE.[IMPORTE AGUINALDO RD] ,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto, CantidadMonto)  
			VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoAguinaldo,  
			isnull(SOURCE.[IMPORTE AGUINALDO RD] ,0)
			)
		;
	END
GO
