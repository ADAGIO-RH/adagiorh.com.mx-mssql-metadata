USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Nomina].[spBuscarTotalesNominaUltimos4Meses]( 
	@IDEmpleado int,
	@IDUsuario int
) as
	
	declare 
		@thedate date = getdate(),
		@IDIdioma Varchar(5)
	;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if OBJECT_ID('tempdb..#tempMeses') is not null drop table #tempMeses;

	;with CTEDates As  
	(  
		select DATEADD(MONTH, -1, @thedate) as TheDate
		UNION ALL  
		select DATEADD(MONTH, -1, TheDate)
		from CTEDates  
		where datediff(month, TheDate, @thedate) < 4
	)

	select *, DATEPART(MONTH, TheDate) as IDMes, DATEPART(YEAR, TheDate) as Ejercicio
	INTO #tempMeses
	from CTEDates

	select
		m.IDMes,
		JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Mes,
		(
			select *
			from (
				select 
					(
						select  ISNULL(SUM(DP.ImporteTotal1),0)  as total
						from Nomina.tblCatPeriodos P with (nolock)
							join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDPeriodo = P.IDPeriodo and DP.IDEmpleado = @IDEmpleado
							join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo like '%550'
						where (p.Ejercicio = last4Months.Ejercicio ) and (p.IDMes = last4Months.IDMes) and isnull(p.Cerrado, 0) = 1
					) as TotalPercepciones,
					(
						select ISNULL(SUM(DP.ImporteTotal1),0) as total
						from Nomina.tblCatPeriodos P with (nolock)
							join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDPeriodo = P.IDPeriodo and DP.IDEmpleado = @IDEmpleado
							join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo like '%560'
						where (p.Ejercicio = last4Months.Ejercicio ) and (p.IDMes = last4Months.IDMes)  and isnull(p.Cerrado, 0) = 1
					) as TotalDeducciones,
					(
						select isnull(sum(dp.ImporteTotal1),0) as total
						from Nomina.tblCatPeriodos P with (nolock)
							join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDPeriodo = P.IDPeriodo and DP.IDEmpleado = @IDEmpleado
							join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.IDTipoConcepto = 5
						where (p.Ejercicio = last4Months.Ejercicio ) and (p.IDMes = last4Months.IDMes) and isnull(p.Cerrado, 0) = 1
					) as TotalPagado
			) as info
			FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
		) as Totales
	from #tempMeses as last4Months 
		join Nomina.tblCatMeses m with (nolock) on last4Months.IDMes = m.IDMes
	order by last4Months.TheDate
GO
