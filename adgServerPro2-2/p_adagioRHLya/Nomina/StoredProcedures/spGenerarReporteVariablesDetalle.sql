USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spGenerarReporteVariablesDetalle] --2018,1,20314,80.36,1617.91,60
(
	@Ejercicio int,
	@IDBimestre int, 
	@IDEmpleado int,
	@UMA decimal(18,2),
	@SalarioIntegrado decimal(18,2),
	@Dias int
) 
AS
BEGIN

DECLARE @fechaInicioBimestre date,  
		@fechaFinBimestre date, 
		@diasBimestre int
		
	select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0)))   
		, @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0))))   
	from Nomina.tblCatMeses with (nolock)  
	where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
   
	set @diasBimestre = DATEDIFF(DAY, @fechaInicioBimestre, @fechaFinBimestre) + 1 


--case when Vales > ((@UMA * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.40) then Vales - ((@UMA * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.40)
--			  else 0 end as ConceptosValesDespensa
-- ,case when PremioPuntualidad > (( SalarioIntegrado * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10) then PremioPuntualidad - (( SalarioIntegrado * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10)
--			  else 0 end as ConceptosPremioPuntualidad
		
--		,case when PremioAsistencia > (( SalarioIntegrado * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10) then PremioAsistencia - (( SalarioIntegrado * case when CriterioDias = 0 then Dias else @diasBimestre end)*0.10)
--			  else 0 end as ConceptosPremioAsistencia

		select 
			c.Codigo,c.Descripcion 
			,case when SUM(dp.Importetotal1) > ((@UMA * @diasBimestre)*0.40) then SUM(dp.Importetotal1) - ((@UMA * @diasBimestre)*0.40) else 0 end  as Integrable
			,SUM(Importetotal1) Importetotal1
		from Nomina.tblDetallePeriodo dp with (nolock)
			inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))
					and p.Cerrado = 1
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
		where dp.IDEmpleado = @IDEmpleado 
			and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosValesDespensa from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ',')) 
		GROUP BY c.Codigo, c.Descripcion
		
		UNION ALL

		select 
			c.Codigo,c.Descripcion 
			,case when SUM(dp.Importetotal1) > ((@SalarioIntegrado * @Dias)*0.10) then SUM(dp.Importetotal1) - ((@SalarioIntegrado * @Dias)*0.10) else 0 end as integrable
			,SUM(Importetotal1) Importetotal1
		from Nomina.tblDetallePeriodo dp with (nolock)
			inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))
					and p.Cerrado = 1
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
		where dp.IDEmpleado = @IDEmpleado 
		and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosPremioPuntualidad from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ',')) 
		GROUP BY c.Codigo, c.Descripcion
		
		UNION ALL

		select 
			c.Codigo,c.Descripcion 
			,case when SUM(dp.Importetotal1) > ((@SalarioIntegrado * @Dias)*0.10) then SUM(dp.Importetotal1) - ((@SalarioIntegrado * @Dias)*0.10) else 0 end as integrable
			,SUM(Importetotal1) Importetotal1
		from Nomina.tblDetallePeriodo dp with (nolock)
			inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))
					and p.Cerrado = 1
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
		where dp.IDEmpleado = @IDEmpleado 
		and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosPremioAsistencia from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ',')) 
		GROUP BY c.Codigo, c.Descripcion
		
		UNION ALL
		
		select 
			c.Codigo
			,c.Descripcion
			,SUM(Importetotal1) as integrable,SUM(ImporteGravado) Importetotal1
		from Nomina.tblDetallePeriodo dp with (nolock)
			inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))
					and p.Cerrado = 1
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
		where dp.IDEmpleado = @IDEmpleado 
		and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosHorasExtrasDobles from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ',')) 
		GROUP BY c.Codigo, c.Descripcion
		
		UNION ALL
		
		select 
			c.Codigo
			,c.Descripcion 
			,SUM(Importetotal1) as integrable
			,SUM(Importetotal1) Importetotal1
		from Nomina.tblDetallePeriodo dp with (nolock)
			inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))
					and p.Cerrado = 1
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
		where dp.IDEmpleado = @IDEmpleado 
			and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosIntegrablesVariables from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ','))
		GROUP BY c.Codigo, c.Descripcion

		--UNION ALL
		--select c.Codigo,c.Descripcion , SUM(Importetotal1) as integrable,SUM(Importetotal1) Importetotal1
		--		from Nomina.tblDetallePeriodo dp
		--			inner join Nomina.tblCatPeriodos p 
		--				on dp.IDPeriodo = p.IDPeriodo
		--			and p.Ejercicio = @Ejercicio
		--			and p.IDMes in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres where IDBimestre = @IDBimestre),','))
		--			and p.Cerrado = 1
		--			inner join Nomina.tblCatConceptos c
		--				on c.IDConcepto = dp.IDConcepto
		--		where dp.IDEmpleado = @IDEmpleado 
		--			and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosDias from Nomina.tblConfigReporteVariablesBimestrales), ','))
		--			GROUP BY c.Codigo, c.Descripcion

	
END
GO
