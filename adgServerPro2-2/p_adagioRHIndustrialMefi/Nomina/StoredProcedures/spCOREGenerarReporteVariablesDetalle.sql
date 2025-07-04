USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spCOREGenerarReporteVariablesDetalle] --2018,1,20314,80.36,1617.91,60
(
	@Ejercicio int,
	@IDBimestre int, 
	@IDEmpleado int,
	@IDRegPatronal int
    
) 
AS
BEGIN
	SET FMTONLY OFF  

DECLARE @fechaInicioBimestre date,  
		@fechaFinBimestre date,
        @UMA decimal(18,2),
        @ConfigPromediarUMA int,
		@dtEmpleados RH.dtEmpleados
    
        
        -- @diasBimestre int

	select @fechaInicioBimestre = min(DATEADD(month,IDMes-1,DATEADD(year,@Ejercicio-1900,0)))   
		, @fechaFinBimestre=MAX(DATEADD(day,-1,DATEADD(month,IDMes,DATEADD(year,@Ejercicio-1900,0))))   
	from Nomina.tblCatMeses with (nolock)  
	where cast(IDMes as varchar) in (select item from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),','))  
   

		if OBJECT_ID('tempdb..#tempMovPreviosDetalle') is not null drop table #tempMovPreviosDetalle
		if OBJECT_ID('tempdb..#tempDias') is not null drop table #tempDias
	
	DECLARE @dtDataDetalle as TABLE (
		IDBimestre int,
		IDMes int,
		UMA Decimal(18,2),
		SalarioMinimo Decimal(18,2),
		IniMes date,
		FinMes date
	)

	select top 1 @ConfigPromediarUMA = isnull(PromediarUMA,1) from Nomina.tblConfigReporteVariablesBimestrales with(nolock)

	insert into @dtDataDetalle
	select @IDBimestre 
		,item
		,(Select top 1 UMA from Nomina.tblSalariosMinimos with(nolock) where Fecha <= DATEADD(day,-1,DATEADD(month,cast(item as int),DATEADD(year,@Ejercicio-1900,0))) order by Fecha desc)
		,(Select top 1 SalarioMinimo from Nomina.tblSalariosMinimos with(nolock) where Fecha <= DATEADD(day,-1,DATEADD(month,cast(item as int),DATEADD(year,@Ejercicio-1900,0))) order by Fecha desc)
		,(DATEADD(month,cast(item as int)-1,DATEADD(year,@Ejercicio-1900,0)))   
		,DATEADD(day,-1,DATEADD(month,cast(item as int),DATEADD(year,@Ejercicio-1900,0)))
	from app.Split( (select top 1 meses from Nomina.tblCatBimestres with (nolock) where IDBimestre = @IDBimestre),',')

	IF(@ConfigPromediarUMA = 2)
	BEGIN
		update @dtDataDetalle
		set UMA = (Select top 1 UMA from Nomina.tblSalariosMinimos with(nolock) where Fecha <= @fechaFinBimestre order by Fecha desc)
	END

	
	IF(@ConfigPromediarUMA = 3)
	BEGIN

		select @UMA =  (select AVG(UMA) UMA from (
							select f.FinMes,
									(select top 1 UMA from  Nomina.tblSalariosMinimos with (nolock) where Fecha <= f.FinMes order by Fecha desc) UMA
							from @dtDataDetalle f
						) info)

		update @dtDataDetalle
		set UMA =  @UMA


	END


        
	   	Insert into @dtEmpleados 
        SELECT * FROM RH.tblEmpleadosMaster WITH(NOLOCK) WHERE IDEmpleado=@IDEmpleado
		


    	select 
        d.*
		,@IDEmpleado as IDEmpleado
		,(
          SELECT top 1 IDMovAfiliatorio 
		  FROM IMSS.tblMovAfiliatorios M with(nolock) 
		  WHERE
			 M.IDEmpleado=@IDEmpleado
			 and M.IDTipoMovimiento in (Select  IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Codigo <> 'B')
			 and m.Fecha >= e.FechaAntiguedad
			 and m.Fecha <= d.FinMes
			 and m.IDRegPatronal = @IDRegPatronal
		    order by m.Fecha desc
		)IDMovAfiliatorio
        ,e.FechaAntiguedad
	    into #tempMovPreviosDetalle 
		FROM @dtEmpleados e
        cross apply @dtDataDetalle d

        -- SELECT * FROM #tempMovPreviosDetalle 
        -- return
        
	
        SELECT 
        @IDEmpleado as IDEmpleado
        ,isnull((select CAST(SUM(Importetotal1)as decimal(18,2))      
				from Nomina.tblDetallePeriodo dp with (nolock)  
				inner join Nomina.tblCatPeriodos p with (nolock)   
					on dp.IDPeriodo = p.IDPeriodo  
						and p.Ejercicio = @Ejercicio  
						and p.IDMes  =  temp.IDMes 
						and p.Cerrado = 1 
					inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = @IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
				where dp.IDEmpleado = @IDEmpleado and dp.IDConcepto in (select item from app.Split(vb.ConceptosDias,',')) ),0) as Dias  
	    ,CASE WHEN temp.FechaAntiguedad>temp.IniMes THEN DATEDIFF(DAY,temp.FechaAntiguedad,temp.FinMes)+1 ELSE DATEDIFF(DAY,temp.IniMes,temp.FinMes)+1 END AS DiasMes
        ,temp.IDMes
        INTO #tempDias
        FROM #tempMovPreviosDetalle temp            
            cross apply Nomina.tblConfigReporteVariablesBimestrales vb with(nolock)
            inner join IMSS.tblMovAfiliatorios mov with(nolock)
		    on mov.IDMovAfiliatorio = temp.IDMovAfiliatorio
            


        -- select * from #tempDias
        -- return
   
        SELECT vales.Codigo as Codigo
               ,Vales.Descripcion as Descripcion
               , CASE WHEN  SUM(Vales) > SUM(TopeVales) THEN SUM(Integrable) else 0 end as Integrable
               ,SUM(Vales.Importetotal1) as Importetotal1
        FROM
        (
            select 
			c.Codigo,c.Descripcion 
			,case when SUM(dp.Importetotal1) > ((temp.UMA * case when vb.CriterioDias = 0 then dias.Dias else dias.DiasMes end)*0.40) then SUM(dp.Importetotal1) - ((temp.UMA * case when CriterioDias = 0 then dias.Dias else dias.DiasMes end)*0.40) else 0 end  as Integrable
			,SUM(Importetotal1) Importetotal1
            ,UMA
            ,dias.Dias
            ,dias.DiasMes
            ,vb.CriterioDias
			,((temp.UMA * case when vb.CriterioDias = 0 then dias.Dias else dias.DiasMes end)*0.40) TopeVales
			,SUM(dp.Importetotal1) as Vales
		from Nomina.tblDetallePeriodo dp with (nolock)
            left join #tempMovPreviosDetalle temp
              on temp.IDEmpleado=dp.IDEmpleado
            inner join IMSS.tblMovAfiliatorios mov with(nolock)
		    on mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
            inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes =temp.IDMes
					and p.Cerrado = 1
            inner join #tempDias dias
                on dias.IDEmpleado=dp.IDEmpleado and p.IDMes=dias.IDMes
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
			inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = @IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
            
         cross apply Nomina.tblConfigReporteVariablesBimestrales vb with(nolock)       
		where dp.IDEmpleado = @IDEmpleado 
			and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosValesDespensa from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ',')) 
		GROUP BY c.Codigo, c.Descripcion,temp.UMA,dias.IDMes,dias.Dias,dias.DiasMes,VB.CriterioDias
        ) as Vales
		GROUP BY Vales.Codigo, Vales.Descripcion
		
		UNION ALL
        
		 SELECT PremioPuntualidad.Codigo as Codigo
               ,PremioPuntualidad.Descripcion as Descripcion
               ,SUM(PremioPuntualidad.Integrable) as Integrable
               ,SUM(PremioPuntualidad.Importetotal1) as Importetotal1
        FROM
        (
        select 
			c.Codigo,c.Descripcion 
			,case when SUM(dp.Importetotal1) > (( (CASE WHEN isnull(vb.TopePremioPuntualidadAsistencia,1) = 1 THEN mov.SalarioDiario ELSE mov.SalarioIntegrado END) * case when vb.CriterioDias = 0 then dias.Dias else dias.DiasMes end)*0.10) then SUM(dp.Importetotal1) - (( (CASE WHEN isnull(vb.TopePremioPuntualidadAsistencia,1) = 1 THEN mov.SalarioDiario ELSE mov.SalarioIntegrado END) * case when vb.CriterioDias = 0 then dias.Dias else dias.DiasMes end)*0.10) else 0 end as integrable
			,SUM(Importetotal1) Importetotal1
            from Nomina.tblDetallePeriodo dp with (nolock)
            left join #tempMovPreviosDetalle temp
              on temp.IDEmpleado=dp.IDEmpleado
            inner join IMSS.tblMovAfiliatorios mov with(nolock)
		    on mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
            inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes =temp.IDMes
					and p.Cerrado = 1
            inner join #tempDias dias
                on dias.IDEmpleado=dp.IDEmpleado and p.IDMes=dias.IDMes
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
			inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = @IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
        cross apply Nomina.tblConfigReporteVariablesBimestrales vb with(nolock)       
		where dp.IDEmpleado = @IDEmpleado 
        and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosPremioPuntualidad from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ',')) 
        GROUP BY c.Codigo, c.Descripcion,dias.IDMes,dias.Dias,dias.DiasMes,VB.CriterioDias,vb.TopePremioPuntualidadAsistencia,mov.SalarioDiario,mov.SalarioIntegrado
        )as PremioPuntualidad
        GROUP BY PremioPuntualidad.Codigo, PremioPuntualidad.Descripcion


		UNION ALL

         SELECT PremioAsistencia.Codigo as Codigo
               ,PremioAsistencia.Descripcion as Descripcion
               ,SUM(PremioAsistencia.Integrable) as Integrable
               ,SUM(PremioAsistencia.Importetotal1) as Importetotal1
        FROM
        (
		select 
			c.Codigo,c.Descripcion 
			,case when SUM(dp.Importetotal1) > (( (CASE WHEN isnull(vb.TopePremioPuntualidadAsistencia,1) = 1 THEN mov.SalarioDiario ELSE mov.SalarioIntegrado END) * case when vb.CriterioDias = 0 then dias.Dias else dias.DiasMes end)*0.10) then SUM(dp.Importetotal1) - (( (CASE WHEN isnull(vb.TopePremioPuntualidadAsistencia,1) = 1 THEN mov.SalarioDiario ELSE mov.SalarioIntegrado END) * case when vb.CriterioDias = 0 then dias.Dias else dias.DiasMes end)*0.10) else 0 end as integrable
			,SUM(Importetotal1) Importetotal1
            from Nomina.tblDetallePeriodo dp with (nolock)
            left join #tempMovPreviosDetalle temp
              on temp.IDEmpleado=dp.IDEmpleado
            inner join IMSS.tblMovAfiliatorios mov with(nolock)
		    on mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
            inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes =temp.IDMes
					and p.Cerrado = 1
            inner join #tempDias dias
                on dias.IDEmpleado=dp.IDEmpleado and p.IDMes=dias.IDMes
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
			inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = @IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
        cross apply Nomina.tblConfigReporteVariablesBimestrales vb with(nolock)       
		where dp.IDEmpleado = @IDEmpleado 
        and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosPremioAsistencia from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ',')) 
        GROUP BY c.Codigo, c.Descripcion,dias.IDMes,dias.Dias,dias.DiasMes,VB.CriterioDias,vb.TopePremioPuntualidadAsistencia,mov.SalarioDiario,mov.SalarioIntegrado
        )as PremioAsistencia
        GROUP BY PremioAsistencia.Codigo, PremioAsistencia.Descripcion

		UNION ALL

		SELECT HorasExtrasDobles.Codigo as Codigo
               ,HorasExtrasDobles.Descripcion as Descripcion
               ,SUM(HorasExtrasDobles.Integrable) as Integrable
               ,SUM(HorasExtrasDobles.Importetotal1) as Importetotal1
        FROM
        (
		select 
			c.Codigo
			,c.Descripcion
			,CASE WHEN SUM(ImporteTotal1) <= ((mov.SalarioDiario /  8.0)*2.0)*72.0 THEN 0
				ELSE SUM(ImporteTotal1) - ((mov.SalarioDiario /  8.0)*2.0)*72.0
				END as integrable
            ,SUM(Importetotal1) Importetotal1
        from Nomina.tblDetallePeriodo dp with (nolock)
            left join #tempMovPreviosDetalle temp
              on temp.IDEmpleado=dp.IDEmpleado
            inner join IMSS.tblMovAfiliatorios mov with(nolock)
		    on mov.IDMovAfiliatorio = temp.IDMovAfiliatorio                          
            inner join Nomina.tblCatPeriodos p with (nolock) 
				on dp.IDPeriodo = p.IDPeriodo
					and p.Ejercicio = @Ejercicio
					and p.IDMes =temp.IDMes
					and p.Cerrado = 1            
			inner join Nomina.tblCatConceptos c with (nolock)
				on c.IDConcepto = dp.IDConcepto
			inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = @IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
            where dp.IDEmpleado = @IDEmpleado 
		    and dp.IDConcepto in (select item from app.Split((select top 1 ConceptosHorasExtrasDobles from Nomina.tblConfigReporteVariablesBimestrales with (nolock)), ','))                         
            GROUP BY c.Codigo, c.Descripcion, mov.SalarioDiario
        ) HorasExtrasDobles
         GROUP BY HorasExtrasDobles.Codigo, HorasExtrasDobles.Descripcion


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
			inner join Nomina.tblHistorialesEmpleadosPeriodos HEP with(Nolock)
						on hep.IDEmpleado = @IDEmpleado
						and hep.IDPeriodo = p.IDPeriodo
						and hep.IDRegPatronal = @IDRegPatronal
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
