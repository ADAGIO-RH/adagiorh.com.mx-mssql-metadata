USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2022-04-26  Yesenia Leonel  Se obtuvo el historial del salario Diario, para calcular la parte de vales de un salario y la parte que corresponde con el otro salario 
***************************************************************************************************/  
CREATE proc [Reportes].[spReporteValesANS_TEST](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
--select * from Nomina.tblCatPeriodos
	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int
	--insert @dtFiltros
	--values ('TipoNomina',4)
	--	  ,('IDPeriodoInicial',29)

	declare 
		@empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@IDCliente int
		,@Cerrado bit = 1
		,@PeriodicidadPago Varchar(50)
		,@TopeSemanal Decimal(18,2)
		,@TopeCatocenal Decimal(18,2)
		,@DiasTopeSemanal decimal(18,2) = 30.4
		,@DiasTopeCatorcenal decimal(18,2) = 30.0
		,@UMA decimal(18,2)
		,@fechas [App].[dtFechas]   
		,@fechasUltimaVigencia [App].[dtFechas]              
		,@ListaFechasUltimaVigencia [App].[dtFechasVigenciaEmpleado]
		,@PorcentajeVales decimal(18,2) = 0.10
		,@DiasPeriodo int
        ,@IDConceptoVales int
        ,@Afectar Varchar(10) = 'FALSE'
		,@TopeVales float
		,@DiasUMAElevada int = 30
	;  

	set @IDTipoNomina = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),','))
						else 0 END

    select top 1 @IDConceptoVales = IDConcepto from Nomina.tblCatConceptos where Codigo = '135' -- Vales de despensa
	Select @IDPeriodoInicial= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPeriodoInicial'),',')
	Select @IDCliente	= cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Cliente'),',')

    set @Afectar = case when exists (Select top 1 cast(item as varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),',')) THEN (Select top 1 cast(item as Varchar(10)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Afectar'),','))  
					  else 'FALSE' 
					END 
	
	insert into @periodo
	select *
	from Nomina.tblCatPeriodos with (nolock)
	where IDTipoNomina = @IDTipoNomina and IDPeriodo = @IDPeriodoInicial

	select 
		@fechaIniPeriodo = FechaInicioPago
		,@fechaFinPeriodo = FechaFinPago 
		,@IDTipoNomina = IDTipoNomina 
		,@Cerrado = Cerrado 
		,@DiasPeriodo = Dias
	from @periodo
	where IDPeriodo = @IDPeriodoInicial

	select @PeriodicidadPago = pp.Descripcion from Nomina.tblCatTipoNomina TN
		inner join SAT.tblCatPeriodicidadesPago PP
			on TN.IDPeriodicidadPago = PP.IDPeriodicidadPago
		where TN.IDTipoNomina = @IDTipoNomina


		Select top 1 @UMA = UMA
		From Nomina.tblSalariosMinimos
		where YEAR(Fecha) <= (select top 1 Ejercicio from @periodo)
		ORDER BY Fecha Desc

		Select @TopeSemanal = Floor(@UMA * @DiasTopeSemanal)
			,@TopeCatocenal = Floor(@UMA * @DiasTopeCatorcenal) 

		select @TopeVales = floor((@UMA * @DiasUMAElevada))

		insert into @fechas
		exec [App].[spListaFechas]@fechaIniPeriodo,@fechaFinPeriodo

  
		insert into @empleados   
		exec [RH].[spBuscarEmpleados] @IDTipoNomina=@IDTipoNomina, @FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros  , @IDUsuario = @IDUsuario  


		if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados  
		if object_id('tempdb..#tempCountVigenciaEmpleados') is not null drop table #tempCountVigenciaEmpleados  
        if object_id('tempdb..#TempDatosAfectar') is not null drop table #TempDatosAfectar
		IF object_ID('TEMPDB..#TempSalarios') IS NOT NULL DROP TABLE #TempSalarios 
		IF object_ID('TEMPDB..#tempvigenciaSalario') IS NOT NULL DROP TABLE #tempvigenciaSalario
		if object_id('tempdb..#tempCountVigenciaEmpleados2') is not null drop table #tempCountVigenciaEmpleados2
		if object_id('tempdb..#TempDatosAfectarPrev') is not null drop table #TempDatosAfectarPrev

			Create Table #tempVigenciaEmpleados(    
			IDEmpleado int null,    
			Fecha Date null,    
			Vigente bit null    
		)

		insert into #tempVigenciaEmpleados   
		exec [RH].[spBuscarListaFechasVigenciaEmpleado] @empleados,@fechas,@IDUsuario


		
		select  ROW_NUMBER() over (PARTition by IDEmpleado order by Fecha Desc) as numero, m.IDEmpleado, m.Fecha, m.SalarioDiario
		into #tempSalarios
		From (select idempleado, min(Fecha) as fecha, SalarioDiario from IMSS.tblMovAfiliatorios group by IDEmpleado, SalarioDiario) as m
		WHERE m.IDEmpleado in (select IDEmpleado from #tempVigenciaEmpleados)
		

		select s.IDEmpleado, s.Fecha as Fechaini, ISNULL((select  DATEADD(DAY,-1,s2.Fecha) from #tempSalarios s2 where s2.idEmpleado = s.IDEmpleado and s2.numero = (s.numero - 1)), '9999-12-31') as FechaFin, s.SalarioDiario, s.numero
		into #tempvigenciaSalario
		from #tempSalarios s
	
		select IDEmpleado
			,count(*) Qty
			into #tempCountVigenciaEmpleados
		from #tempVigenciaEmpleados
		where Vigente = 1
		Group by IDEmpleado


		select ve.IDEmpleado, vs.SalarioDiario,vs.numero
			,cast(count(*) as float) Qty
			into #tempCountVigenciaEmpleados2
		from #tempVigenciaEmpleados ve
			inner join #tempvigenciaSalario vs
				on ve.IDEmpleado = vs.IDEmpleado and ve.Fecha between vs.Fechaini and vs.FechaFin
		where Vigente = 1
		Group by ve.IDEmpleado, vs.SalarioDiario,vs.numero


		update t 
		set t.Qty = t.Qty - case when @PeriodicidadPago = 'SEMANAL' then 0.60 else 1.00 end 
		from #tempCountVigenciaEmpleados2 t
			join (

					select *, case when numero = 1 and DiasNaturales > TopeDias then 1 else 0 end as Actualizar
					from (
							select * ,SUM(Qty) over(partition by idempleado order by idempleado) as DiasNaturales, case when @PeriodicidadPago = 'SEMANAL' then @DiasTopeSemanal else @DiasTopeCatorcenal end as TopeDias
							from #tempCountVigenciaEmpleados2 
						) x 
				 ) x on x.IDEmpleado = t.IDEmpleado and x.SalarioDiario = t.SalarioDiario
		where x.Actualizar = 1
		
		
		--select * from #tempCountVigenciaEmpleados2 

	select *  into #TempDatosAfectarPrev from 
(
    select 
        0 as IDEmpleado,
        '000' as CLAVE,
        '0' AS NOMBRE,
        0 as [Dias Vigencia],
        0 AS [Vales],
            (select Descripcion from Nomina.tblCatMeses where IDMes=(Select  Month(FechaInicioPago) from Nomina.tblCatPeriodos WHERE IDPeriodo=@IDPeriodoInicial))  as  [Mes Inicial]  ,                     
            (select Descripcion from Nomina.tblCatMeses where IDMes=(Select  Month(FechaFinPago) from Nomina.tblCatPeriodos WHERE IDPeriodo=@IDPeriodoInicial))  AS [Mes Final]
    union
    Select 
            e.IDEmpleado, 
        E.ClaveEmpleado as CLAVE	
        ,e.NOMBRECOMPLETO as NOMBRE
        ,v.Qty as [Dias Vigencia] 
        , CASE WHEN @PeriodicidadPago = 'SEMANAL' THEN  
				CASE WHEN ROUND(((CASE WHEN v.Qty >= @DiasPeriodo THEN @DiasTopeSemanal else v.Qty END) * V.SalarioDiario) * @PorcentajeVales,0) > @TopeSemanal THEN Floor(@TopeSemanal) ELSE ROUND (((CASE WHEN v.Qty >= @DiasPeriodo THEN @DiasTopeSemanal else v.Qty END) * V.SalarioDiario) * @PorcentajeVales,0) END
            WHEN @PeriodicidadPago = 'CATORCENAL' THEN  CASE WHEN ROUND (((CASE WHEN v.Qty >= @DiasPeriodo THEN @DiasTopeCatorcenal else v.Qty END) * V.SalarioDiario) * @PorcentajeVales,0) > @TopeCatocenal THEN Floor(@TopeCatocenal) ELSE ROUND (((CASE WHEN v.Qty >= @DiasPeriodo THEN @DiasTopeCatorcenal else v.Qty END) * V.SalarioDiario) * @PorcentajeVales,0) END
            ELSE 0
            END Vales
            ,'' AS [Mes Inicial]
            ,'' AS [Mes Final]
    from #tempCountVigenciaEmpleados2 V
        inner join @empleados e
            on v.IDEmpleado = e.IDEmpleado
) as temp
ORDER BY temp.CLAVE ASC

        
select IDEmpleado, CONVERT(VARCHAR,CLAVE) as CLAVE, NOMBRE, SUM(Vales) as Vales, SUM([Dias Vigencia]) as [Dias Vigencia], [Mes Inicial], [Mes Final]
into #TempDatosAfectar
from #TempDatosAfectarPrev
GROUP BY CLAVE, NOMBRE, [Mes Inicial], [Mes Final], IDEmpleado
ORDER BY CLAVE

update #TempDatosAfectar set vales = @TopeVales where vales > @TopeVales

select CONVERT(VARCHAR,CLAVE) as [CLAVE EMPLEADO],NOMBRE as NOMBRE ,Vales as Vales,CAST([Dias Vigencia] as VARCHAR(10)) as [Dias Vigencia],[Mes Inicial],[Mes Final] from #TempDatosAfectar ORDER BY CONVERT(VARCHAR,CLAVE)


    IF(@Afectar = 'TRUE')
	BEGIN

    delete top(1) from #TempDatosAfectar where CLAVE =   '000'


    MERGE Nomina.tblDetallePeriodo AS TARGET
		USING #TempDatosAfectar AS SOURCE
			ON TARGET.IDPeriodo = @IDPeriodoInicial
				and TARGET.IDConcepto = @IDConceptoVales
				and TARGET.IDEmpleado = SOURCE.IDEmpleado
		WHEN MATCHED Then
			update
				Set TARGET.CantidadMonto  = isnull(SOURCE.Vales ,0)  

		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDPeriodo,IDConcepto, CantidadMonto)  
			VALUES(SOURCE.IDEmpleado,@IDPeriodoInicial,@IDConceptoVales, isnull(SOURCE.Vales ,0)
			);
    END
        
GO
