USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAportacionesFondoAhorro_ExcelAVILAB]
(
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @Ejercicio int,
	@ClaveEmpleadoInicial varchar(20),
	@IDTipoNomina int,
	@IDEmpleado int, 
	@dtPeriodos nomina.dtPeriodos,
	@FechaInicial date,
	@fechaFinal date,
	@IDPeriodoPago int

	select top 1 @Ejercicio = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'Ejercicio'),',')
	select top 1 @ClaveEmpleadoInicial = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')

	SELECT @IDEmpleado = IDEmpleado, @IDTipoNomina = IDTipoNomina from RH.tblEmpleadosMaster WHERE ClaveEmpleado = @ClaveEmpleadoInicial

	select  @FechaInicial = p1.FechaInicioPago
			,@fechaFinal = p2.FechaFinPago
			,@IDPeriodoPago = f.IDPeriodoPago
	from Nomina.tblCatFondosAhorro f
		inner join nomina.tblCatPeriodos P1
			on f.IDPeriodoInicial = P1.IDPeriodo
		inner join Nomina.tblCatPeriodos p2
			on f.IDPeriodoFinal = p2.IDPeriodo
	WHERE f.Ejercicio = @Ejercicio and f.IDTipoNomina = @IDTipoNomina

	insert into @dtPeriodos
	select * 
	from Nomina.tblCatPeriodos p
	where p.IDTipoNomina = @IDTipoNomina
	and p.FechaInicioPago >= @FechaInicial and p.FechaFinPago <= @fechaFinal
	union
	select * 
	from Nomina.tblCatPeriodos p
	where p.IDPeriodo = @IDPeriodoPago


	if OBJECT_ID('tempdb..#tempData') is not null drop table #tempData 
	
	CREATE TABLE #tempData(
		IDEmpleado int,
		IDPeriodo int,
		ImporteAbono decimal(18,2),
		ImporteCargo decimal(18,2),
		Concepto varchar(100)
	)

	insert into #tempData
	select m.IDEmpleado
		,dp.IDPeriodo
		,dp.ImporteTotal1
		,0.00
		,cFEmpleado.Descripcion
	from RH.tblEmpleadosMaster M
		inner join Nomina.tblDetallePeriodo dp
			on m.IDEmpleado = dp.IDEmpleado
		inner join Nomina.tblCatConceptos cFEmpleado
			on cFEmpleado.IDConcepto = dp.IDConcepto
			and cFEmpleado.Codigo = '308' 
		inner join @dtPeriodos p
			on p.IDPeriodo = dp.IDPeriodo
	where M.IDEmpleado = @IDEmpleado
	union
	select m.IDEmpleado
		,dp.IDPeriodo
		,dp.ImporteTotal1
		,0.00
		,cFEmpleado.Descripcion
	from RH.tblEmpleadosMaster M
		inner join Nomina.tblDetallePeriodo dp
			on m.IDEmpleado = dp.IDEmpleado
		inner join Nomina.tblCatConceptos cFEmpleado
			on cFEmpleado.IDConcepto = dp.IDConcepto
			and cFEmpleado.Codigo = '309' 
		inner join @dtPeriodos p
			on p.IDPeriodo = dp.IDPeriodo
	where M.IDEmpleado = @IDEmpleado
	union
	select m.IDEmpleado
		,dp.IDPeriodo
		,0.00
		,dp.ImporteTotal1
		,cFEmpleado.Descripcion
	from RH.tblEmpleadosMaster M
		inner join Nomina.tblDetallePeriodo dp
			on m.IDEmpleado = dp.IDEmpleado
		inner join Nomina.tblCatConceptos cFEmpleado
			on cFEmpleado.IDConcepto = dp.IDConcepto
			and cFEmpleado.Codigo = '162' 
		inner join @dtPeriodos p
			on p.IDPeriodo = dp.IDPeriodo
	where M.IDEmpleado = @IDEmpleado
	union
	select m.IDEmpleado
		,dp.IDPeriodo
		,0.00
		,dp.ImporteTotal1
		,cFEmpleado.Descripcion
	from RH.tblEmpleadosMaster M
		inner join Nomina.tblDetallePeriodo dp
			on m.IDEmpleado = dp.IDEmpleado
		inner join Nomina.tblCatConceptos cFEmpleado
			on cFEmpleado.IDConcepto = dp.IDConcepto
			and cFEmpleado.Codigo = '163' 
		inner join @dtPeriodos p
			on p.IDPeriodo = dp.IDPeriodo
	where M.IDEmpleado = @IDEmpleado

	select m.ClaveEmpleado,
		m.NOMBRECOMPLETO as NombreCompleto,
		p.ClavePeriodo +' - '+p.Descripcion as Periodo,
		p.FechaFinPago as Fecha,
		data.ImporteAbono,
		data.ImporteCargo,
		data.Concepto
	from #tempData data
		inner join RH.tblEmpleadosMaster m
			on data.IDEmpleado = m.IDEmpleado
		inner join @dtPeriodos p 
			on p.IDPeriodo = data.IDPeriodo
	where p.idperiodo <> 297
	order by p.FechaFinPago asc
		
END
GO
