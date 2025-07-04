USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[Intranet].[spDetalleDashboardNominaMes] 1279,2021,11

CREATE procedure [Intranet].[spDetalleDashboardNominaMes]
(
	@IDEmpleado int, 
	@Ejercicio int =0, 
	@IDMes int=0
)
AS BEGIN
	
	if OBJECT_ID('tempdb..#tempPeriodos') is not null drop table #tempPeriodos;

	select IDPeriodo
	INTO #tempPeriodos
	from  Nomina.tblCatPeriodos P with (nolock)
	where (p.Ejercicio = @Ejercicio or @Ejercicio=0 ) and (p.IDMes = @IDMes or @IDMes = 0) and isnull(p.Cerrado, 0) = 1

	select 
		(
			select  ISNULL(SUM(DP.ImporteTotal1),0)  as total
			from #tempPeriodos P with (nolock)
				join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDPeriodo = P.IDPeriodo 
					and DP.IDEmpleado = @IDEmpleado
				join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo like '%550'
			--where (p.Ejercicio = @Ejercicio or @Ejercicio=0 ) and (p.IDMes = @IDMes or @IDMes = 0) and isnull(p.Cerrado, 0) = 1
		) as TotalPercepciones,
		(
			select ISNULL(SUM(DP.ImporteTotal1),0) as total
			from #tempPeriodos P with (nolock)
				join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDPeriodo = P.IDPeriodo 
					and DP.IDEmpleado = @IDEmpleado
				join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo like '%560'
			--where (p.Ejercicio = @Ejercicio or @Ejercicio=0 ) and (p.IDMes = @IDMes or @IDMes = 0)  and isnull(p.Cerrado, 0) = 1
		) as TotalDeducciones,
		(
			select isnull(sum(dp.ImporteTotal1),0) as total
			from #tempPeriodos P with (nolock)
				join Nomina.tblDetallePeriodo DP with (nolock) on DP.IDPeriodo = P.IDPeriodo 
					and DP.IDEmpleado = @IDEmpleado
				join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.IDTipoConcepto = 5
			--where (p.Ejercicio = @Ejercicio or @Ejercicio=0 ) and (p.IDMes = @IDMes or @IDMes = 0)  and isnull(p.Cerrado, 0) = 1
		) as TotalPagado

END
GO
