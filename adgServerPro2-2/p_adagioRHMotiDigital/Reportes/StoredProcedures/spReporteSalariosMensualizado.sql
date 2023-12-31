USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Reportes].[spReporteSalariosMensualizado](
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
  
  select top 1 @IDConceptoAguinaldo = IDConcepto from Nomina.tblCatConceptos where Codigo = '130' -- AGUINALDO

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


	if object_id('tempdb..#tempDatosExtraEmpleados')is not null drop table #tempDatosExtraEmpleados
 Select dee.IdDatoExtraEmpleado, cde.IdDatoExtra, cde.Descripcion, dee.valor, dee.idempleado
	 into #tempDatosExtraEmpleados
	 from rh.tbldatosextraempleados dee with (nolock) 
		inner join rh.tblcatdatosextra cde with (nolock) 
			on dee.idDatoExtra = cde.idDatoExtra


	select
		  Empleados.IDEmpleado
		, Empleados.ClaveEmpleado as [Clave]
		, Empleados.NOMBRECOMPLETO as [NOMBRE COMPLETO]
		, depto.Codigo +' - '+ depto.Descripcion as [DEPTO]
		, Suc.Codigo +' - '+ Suc.Descripcion as [SUCURSAL]
		, Puestos.Codigo +' - '+ Puestos.Descripcion as [PUESTO]
		, tp.Codigo +' - '+tp.Descripcion as [PRESTACION]
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

		, INC_GEN.Valor as [INCAPACIDADES DE]
		--, [Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
		--	   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
		--	   ELSE @fechaIni
		--	   END,@fechaFin) as [INCIDENCIAS]
		, AUSENTISMO.Valor as [AUSENTISMOS DE]

		, [DIAS A PAGAR] = ((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-ISNULL(AUSENTISMO.Valor,0) - ISNULL(INC_GEN.Valor,0))-- + ISNULL(INC_GEN.Valor,0)))
			   -([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
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
			   END,@fechaFin))

			  --([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			  -- WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			  -- ELSE @fechaIni
			  -- END,@fechaFin)
					--+[Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Ausentismos ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			  -- WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			  -- ELSE @fechaIni
			  -- END,@fechaFin)
			  -- +[Asistencia].[fnBuscarIncapacidadEmpleado](Empleados.IDEmpleado,@TipoIncapacidad ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
			  -- WHEN Empleados.FechaAntiguedad <= @fechaIni THEN @fechaIni
			  -- ELSE @fechaIni
			  -- END,@fechaFin)
			  -- ))
		, [DIAS PRESTACION AGUINALDO] = TPD.DiasAguinaldo

		,[DIAS A PAGAR AGUINALDO] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-
			   ( ([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
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
			   + isnull(AUSENTISMO.Valor,0)
			   +isnull(INC_GEN.Valor,0))))
		,[SALARIO DIARIO] = Empleados.SalarioDiario

		,[SALARIO DIARIO REAL] = Empleados.SalarioDiarioReal
		,[SALARIO OPTIMO MENSUAL] = OPMES.Valor
		,[SALARIO OPTIMO] = CASE WHEN (isnull(OPMES.Valor,0)) <= 0 THEN 0 ELSE (isnull(OPMES.Valor,0) / 30 + isnull(SalarioDiarioReal,0)) END

		,[IMPORTE AGUINALDO] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-
			  ( ([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
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
			   + isnull(AUSENTISMO.Valor,0)
			   +isnull(INC_GEN.Valor,0)))) * Empleados.SalarioDiario
			    

		,[IMPORTE AGUINALDO REAL] = (CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-
			  ( ([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
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
			   + isnull(AUSENTISMO.Valor,0)
			   +isnull(INC_GEN.Valor,0)))) * Empleados.SalarioDiarioReal

			,CASE WHEN (isnull(OPMES.Valor,0)) <=0 THEN 0  ELSE 
			((CAST(isnull(TPD.DiasAguinaldo,0) as decimal(18,2))/cast(DATEDIFF(DAY,@fechaIni,@fechaFin)+1 as decimal(18,2)))*
		((CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN DATEDIFF(DAY, Empleados.FechaAntiguedad, @fechaFin)+1
			   WHEN Empleados.FechaAntiguedad <= @fechaIni THEN DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   ELSE DATEDIFF(DAY, @fechaIni, @fechaFin)+1
			   END)-
			  ( ([Asistencia].[fnBuscarIncidenciasEmpleado](Empleados.IDEmpleado,@Incidencias ,CASE WHEN Empleados.FechaAntiguedad > @fechaIni THEN Empleados.FechaAntiguedad
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
			   + isnull(AUSENTISMO.Valor,0)
			   +isnull(INC_GEN.Valor,0))))
			   *  (isnull(OPMES.Valor,0) / 30)) 
			   + isnull(SalarioDiarioReal,0) END AS [IMPORTE AGUINALDO OPTIMO]
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
		left join #tempDatosExtraEmpleados AUSENTISMO
				on AUSENTISMO.idempleado = Empleados.idempleado and AUSENTISMO.Descripcion = 'AUSENTISMOS'
		left join #tempDatosExtraEmpleados INC_GEN
				on INC_GEN.idempleado = Empleados.idempleado and INC_GEN.Descripcion = 'INC_GENERAL'
		left join #tempDatosExtraEmpleados OPMES
				on OPMES.idempleado = Empleados.idempleado and OPMES.Descripcion = 'OPTIMO_MENSUAL'

	ORDER BY Empleados.ClaveEmpleado ASC

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
		, [INCAPACIDADES DE]
		, [AUSENTISMOS DE]
		, [DIAS A PAGAR]
		, [DIAS PRESTACION AGUINALDO] 
		, [DIAS A PAGAR AGUINALDO] 
		, [SALARIO DIARIO] 
		, [SALARIO DIARIO REAL]
		, [SALARIO OPTIMO MENSUAL]
		, [SALARIO OPTIMO]
		, [IMPORTE AGUINALDO]
		, [IMPORTE AGUINALDO REAL]
		,[IMPORTE AGUINALDO OPTIMO]
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
				Set TARGET.CantidadMonto  = isnull(SOURCE.[IMPORTE AGUINALDO] ,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto, CantidadMonto)  
			VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoAguinaldo,  
			isnull(SOURCE.[IMPORTE AGUINALDO] ,0)
			)
		;
	END
GO
