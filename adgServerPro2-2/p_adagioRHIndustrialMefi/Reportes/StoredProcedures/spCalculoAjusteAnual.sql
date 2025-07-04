USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spCalculoAjusteAnual] --1,4,2019
(
  @dtFiltros Nomina.dtFiltrosRH readonly    
 ,@IDUsuario int  
)
AS
BEGIN
 SET FMTONLY OFF;
	Declare @dtEmpleados [RH].[dtEmpleados]
	,@FechaInicio date
	,@FechaFin date
	,@IDPeriodicidadPagoAnual int
	,@IDTipoNomina int      
	,@Ejercicio int
	,@IDPeriodoInicial int; 


 	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))  
					  else 0  
					END  
 
	set @Ejercicio = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),','))  
					  else DATEPART(YEAR, GETDATE()) 
					END  
	set @FechaInicio = cast(@Ejercicio as varchar(4))+'-01-01';
	set @fechaFin = cast(@Ejercicio as varchar(4))+'-12-31';

	set @IDPeriodoInicial = case when exists (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')) THEN (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),','))  
					else 0  
				END  

 select top 1 @IDPeriodicidadPagoAnual = IDPeriodicidadPago from SAT.tblCatPeriodicidadesPago where Descripcion = 'Anual' 

    IF NOT EXISTS(Select *             
			 from Nomina.tbltablasImpuestos  TI            
			 INNER JOIN Nomina.tblDetalleTablasImpuestos DTI            
			  on DTI.IDTablaImpuesto = TI.IDTablaImpuesto    
			  INNER JOIN Nomina.tblCatTipoCalculoISR CTCI    
			on CTCI.IDCalculo = TI.IDCalculo      
			WHERE TI.Ejercicio = @Ejercicio            
			 AND CTCI.Codigo = 'ISR_SUELDOS'            
			 AND TI.IDPeriodicidadPago = @IDPeriodicidadPagoAnual            
      )            
     BEGIN            
		RAISERROR('La tabla de ISR para la periodicidad de pago Anual de Ejercicio no existe.',16,1); 
		RETURN;           
	 END 


   insert into @dtEmpleados                  
   exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @FechaInicio, @Fechafin= @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario 

   delete @dtEmpleados
   where FechaAntiguedad >=@FechaInicio
	
	delete @dtEmpleados 
	where IDEmpleado in(
			select IDEmpleado 
			from IMSS.tblMovAfiliatorios 
			where Fecha Between @FechaInicio and @FechaFin
			and IDTipoMovimiento in(select IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo in ('R','B'))
	)

	if object_id('tempdb..#tempEmpleadosPercepciones') is not null      
    drop table #tempEmpleadosPercepciones  

	if object_id('tempdb..#tempEmpleadosPercepcionesSubsidioISR') is not null      
		drop table #tempEmpleadosPercepcionesSubsidioISR  
	if object_id('tempdb..#tempTotal') is not null      
		drop table #tempTotal 

		SELECT t.IDEmpleado,
			   t.ClaveEmpleado,
			   t.NOMBRECOMPLETO,
			   t.Departamento,
			   t.Sucursal,
			   t.Puesto,
			   t.ClasificacionCorporativa,
			   t.FechaAntiguedad,
			   SUM(t.ImporteGravado) as ImporteGravado,
			   SUM(t.ImporteExcento) as ImporteExcento,
			   SUM(t.ImporteTotal1) as ImporteTotal1
		into #tempEmpleadosPercepciones
		FROM (
	select e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.ClasificacionCorporativa
		,e.FechaAntiguedad
		,SUM(dp.ImporteGravado ) as ImporteGravado
		,SUM(dp.ImporteExcento ) as ImporteExcento
		,SUM(dp.ImporteTotal1 )as ImporteTotal1
	
	from @dtEmpleados e
		inner join Nomina.tblDetallePeriodo dp
			on e.IDEmpleado = dp.IDEmpleado
		inner join Nomina.tblCatConceptos c
			on c.IDConcepto = dp.IDConcepto
		inner join Nomina.tblCatTipoConcepto tc	
			on tc.IDTipoConcepto = c.IDTipoConcepto
				and tc.Descripcion = 'PERCEPCION'
		inner join Nomina.tblCatTipoCalculoISR TCI
			on TCI.IDCalculo = c.IDCalculo
			and TCI.Codigo in ('ISR_SUELDOS','ISR_AGUINALDO_PTU')
		Inner join Nomina.tblCatPeriodos p
			on p.IDPeriodo = dp.IDPeriodo
			and p.Cerrado = 1
			and p.Ejercicio = @Ejercicio
		
	GROUP BY e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.ClasificacionCorporativa
		,e.FechaAntiguedad
	UNION ALL
		select e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.ClasificacionCorporativa
		,e.FechaAntiguedad
		,SUM(dp.ImporteGravado ) as ImporteGravado
		,SUM(dp.ImporteExcento ) as ImporteExcento
		,SUM(dp.ImporteTotal1 )as ImporteTotal1
	from @dtEmpleados e
		inner join Nomina.tblDetallePeriodo dp
			on e.IDEmpleado = dp.IDEmpleado
		inner join Nomina.tblCatConceptos c
			on c.IDConcepto = dp.IDConcepto
		inner join Nomina.tblCatTipoConcepto tc	
			on tc.IDTipoConcepto = c.IDTipoConcepto
				and tc.Descripcion = 'PERCEPCION'
		inner join Nomina.tblCatTipoCalculoISR TCI
			on TCI.IDCalculo = c.IDCalculo
			and TCI.Codigo in ('ISR_SUELDOS','ISR_AGUINALDO_PTU')
		Inner join Nomina.tblCatPeriodos p
			on p.IDPeriodo = dp.IDPeriodo
			--and p.Cerrado = 1
			and p.Ejercicio = @Ejercicio
	where dp.IDPeriodo = @IDPeriodoInicial
	GROUP BY e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.ClasificacionCorporativa
		,e.FechaAntiguedad
		) T
	GROUP BY 
	t.IDEmpleado,
			   t.ClaveEmpleado,
			   t.NOMBRECOMPLETO,
			   t.Departamento,
			   t.Sucursal,
			   t.Puesto,
			   t.ClasificacionCorporativa,
			   t.FechaAntiguedad




	Select p.*
	,(      SELECT SUM(sub.SUBSIDIO) FROM (
			select  ISNULL(SUM(dp.ImporteTotal1),0)SUBSIDIO
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					and periodo.Cerrado = 1
            where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '002','005','007') -- DIAS PAGADOS
			union
            select  ISNULL(SUM(ImporteTotal1),0) SUBSIDIO    
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					--and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '002','005','007')-- DIAS PAGADOS
					and dp.IDPeriodo = @IDPeriodoInicial
            ) sub
				
		) as DIAS_PAGADOS
	
	,(      SELECT SUM(sub.SUBSIDIO) FROM (
			select  ISNULL(SUM(dp.ImporteTotal1),0)SUBSIDIO
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					and periodo.Cerrado = 1
            where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '078') -- SUBSIDIO PARA EL EMPLEO
			union
            select  ISNULL(SUM(ImporteTotal1),0) SUBSIDIO    
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					--and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '078') -- SUBSIDIO PARA EL EMPLEO
					and dp.IDPeriodo = @IDPeriodoInicial
            ) sub
				
		) as SubsidioCausado
		,(
		   SELECT SUM(sub.SUBSIDIO) FROM (
			 select  ISNULL(SUM(ImporteTotal1),0) SUBSIDIO  
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '180','184','185') -- SUBSIDIO PARA EL EMPLEO
			UNION ALL
			select  ISNULL(SUM(ImporteTotal1),0) SUBSIDIO    
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					--and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '180','184','185') -- SUBSIDIO PARA EL EMPLEO
					and dp.IDPeriodo = @IDPeriodoInicial)sub
		) as Subsidio

		,(
			SELECT SUM(subCausado.SUBSIDIO) FROM (
			select  ISNULL(SUM(ImporteTotal1),0) SUBSIDIO  
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '078'
					) 
			UNION ALL
			select  ISNULL(SUM(ImporteTotal1),0) SUBSIDIO  
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					--and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '078') 
					and dp.IDPeriodo = @IDPeriodoInicial) subCausado
		) as SUBSIDIO_CAUSADO
		,(
			SELECT SUM(ISNULL(ISRCAUSADO.ISR,0)) FROM (
			select  ISNULL(SUM(ImporteTotal1),0) ISR  
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '079'
					) 
			UNION ALL
			select  ISNULL(SUM(ImporteTotal1),0) ISR 
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					--and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '079'
					) 
					and dp.IDPeriodo = @IDPeriodoInicial)ISRCAUSADO

		) as ISR_CAUSADO
		,(
			SELECT SUM(ISNULL(ISR.isr,0)) FROM (
			select  ISNULL(SUM(ImporteTotal1),0) isr 
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '301' -- ISR
									--,'301A' -- ISR AGUINALDO PTU
									,'301C' -- ISR POR SUBSIDIO
                                    ,'384'
                                    ,'385'
					) 
			UNION ALL

			select  ISNULL(SUM(ImporteTotal1),0) isr 
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					--and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( '301' -- ISR
									--,'301A' -- ISR AGUINALDO PTU
									,'301C' -- ISR POR SUBSIDIO
                                    ,'384'
                                    ,'385'
					) 
					and dp.IDPeriodo = @IDPeriodoInicial) isr

		) as ISR_REtenido
		,(
			SELECT SUM(ISNULL(ISR.isr,0)) FROM (
			select  ISNULL(SUM(ImporteTotal1),0) isr 
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in(
									'301A' -- ISR AGUINALDO PTU
									
					) 
			UNION ALL

			select  ISNULL(SUM(ImporteTotal1),0) isr 
			from Nomina.tblDetallePeriodo dp
				inner join Nomina.tblCatConceptos c
					on dp.IDConcepto = c.IDConcepto
				inner join Nomina.tblCatPeriodos periodo 
					on periodo.IDPeriodo = dp.IDPeriodo
					and periodo.Ejercicio = @Ejercicio
					--and periodo.Cerrado = 1
				where dp.IDEmpleado = p.IDEmpleado
					and c.Codigo in( 
									'301A' -- ISR AGUINALDO PTU
									
					) 
					and dp.IDPeriodo = @IDPeriodoInicial) isr

		) as ISR_AGUINALDO_PTU
		into #tempEmpleadosPercepcionesSubsidioISR
	from #tempEmpleadosPercepciones p
	
	select t.*
		,[Nomina].[fnISRSUELDOS](@IDPeriodicidadPagoAnual,t.ImporteGravado,t.DIAS_PAGADOS,@Ejercicio,0,151) as ISR_Anual 
	into #tempTotal
	from #tempEmpleadosPercepcionesSubsidioISR t


	select ClaveEmpleado AS [Clave]
		, NOMBRECOMPLETO as [Nombre Completo]
		, Departamento as [DEPTO]
		, Sucursal as [SUCURSAL]
		, PUESTO AS [PUESTO]
		, ClasificacionCorporativa AS [CLASIF. CORP.]
		, FORMAT(FechaAntiguedad,'dd/MM/yyyy') AS [FECHA ANTIGUEDAD]
		, DATEDIFF(DAY,@FechaInicio,@FechaFin)+1 AS [DIAS VIGENCIA]
		, ImporteGravado as [IMPORTE GRAVADO]
		, ImporteExcento as [IMPORTE EXENTO]
		, ImporteTotal1 AS [IMPORTE TOTAL]
		, Subsidio AS [SUBSIDIO]
		, SUBSIDIO_CAUSADO AS [SUBSIDIO CAUSADO]
		, ISR_CAUSADO AS [ISR CAUSADO]
		, ISR_REtenido AS [ISR RETENIDO S.S]
		, ISR_AGUINALDO_PTU AS [ISR AGUINALDO PTU]
		, ISR_REtenido + ISR_AGUINALDO_PTU AS [TOTAL ISR]
		, ISR_Anual   AS [ISR ANUAL]
		,CASE WHEN (ISR_REtenido + ISR_AGUINALDO_PTU) > 0 THEN
			CASE WHEN (ISR_Anual - SUBSIDIO_CAUSADO) <= (ISR_REtenido + ISR_AGUINALDO_PTU) THEN (ISR_REtenido + ISR_AGUINALDO_PTU) - (ISR_Anual - SUBSIDIO_CAUSADO)
			ELSE  0
			END 
			ELSE 0
			END AS [ISR A FAVOR]
		, CASE WHEN (ISR_Anual - SUBSIDIO_CAUSADO) >= (ISR_REtenido + ISR_AGUINALDO_PTU) THEN (ISR_Anual - SUBSIDIO_CAUSADO) - (ISR_REtenido + ISR_AGUINALDO_PTU)  
			ELSE 0
			END  AS  [ISR A CARGO]
	from #tempTotal
	--where ImporteGravado < 400000
	ORDER BY ClaveEmpleado ASC


END
GO
