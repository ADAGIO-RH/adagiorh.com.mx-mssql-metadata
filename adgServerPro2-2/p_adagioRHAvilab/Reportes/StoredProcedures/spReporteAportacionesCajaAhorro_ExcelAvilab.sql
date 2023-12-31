USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAportacionesCajaAhorro_ExcelAvilab]
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
			and cFEmpleado.Codigo = '320' 
		inner join  Nomina.tblCatPeriodos p
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
			and cFEmpleado.Codigo = '146' 
		inner join Nomina.tblCatPeriodos p
			on p.IDPeriodo = dp.IDPeriodo
	where M.IDEmpleado = @IDEmpleado

	select m.ClaveEmpleado,
		m.NOMBRECOMPLETO as NombreCompleto,
		caja.Monto,
		CASE WHEN caja.IDEstatus = 1 THEN 'SI' ELSE 'NO' END as Activa,
		p.ClavePeriodo +' - '+p.Descripcion as Periodo,
		p.FechaFinPago as Fecha,
		data.ImporteAbono,
		data.ImporteCargo,
		data.Concepto
	from #tempData data
		inner join RH.tblEmpleadosMaster m
			on data.IDEmpleado = m.IDEmpleado
		inner join  Nomina.tblCatPeriodos p
			on p.IDPeriodo = data.IDPeriodo
		inner join Nomina.tblCajaAhorro Caja
			on caja.IDEmpleado = m.IDEmpleado
	where p.idperiodo <> 297
	order by p.FechaFinPago asc
		
END
GO
