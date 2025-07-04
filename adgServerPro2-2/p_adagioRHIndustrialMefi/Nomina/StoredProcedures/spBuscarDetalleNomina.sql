USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Nomina].[spBuscarDetalleNomina](
	@IDPeriodo int
)
AS
BEGIN
	declare 
	   @IDTipoNomina int,
	   @FI date,
	   @FF date,
	   @dtEmpleado [RH].[dtEmpleados]

	select @IDTipoNomina=IDTipoNomina,@FI=FechaInicioPago, @FF=FechaFinPago 
	from Nomina.tblCatPeriodos
	where IDPeriodo=@IDPeriodo

	--insert into @dtEmpleado
	--Exec RH.spBuscarEmpleados 
 --    @FechaIni = @FI
	--,@Fechafin = @FF
	--,@IDUsuario = 1
	--,@IDTipoNomina = @IDTipoNomina

	SELECT p.IDPeriodo,
		   p.Ejercicio,
		   p.ClavePeriodo,
		   p.Descripcion Periodo,
		   E.IDEmpleado,
		   E.ClaveEmpleado,
		   E.Nombre,
		   E.SegundoNombre,
		   E.Paterno,
		   E.Materno,
		   c.IDConcepto,
		   C.Codigo,
		   C.Descripcion Concepto,
		   C.bCantidadMonto,
		   C.bCantidadDias,
		   C.bCantidadVeces,
		   C.bCantidadOtro1,
		   C.bCantidadOtro2,
		   ISNULL(dp.IDDetallePeriodo,0) as IDDetallePeriodo, 
		   ISNULL(dp.CantidadMonto,0) as CantidadMonto	,
		   ISNULL(dp.CantidadDias ,0) as CantidadDias	,
		   ISNULL(dp.CantidadVeces,0) as CantidadVeces	,
		   ISNULL(dp.CantidadOtro1,0) as CantidadOtro1	,
		   ISNULL(dp.CantidadOtro2,0) as CantidadOtro2	,	
		   ISNULL(dp.ImporteTotal1,0) as ImporteTotal1	,	
		   ISNULL(dp.ImporteTotal2,0) as ImporteTotal2	,
		   ISNULL(dp.ImporteAcumuladoTotales,0) as ImporteAcumuladoTotales	

	FROM Nomina.tbldetallePeriodo dp
		join Nomina.tblCatPeriodos p on dp.IDPeriodo = p.IDPeriodo
		join RH.tblEmpleadosMaster e on dp.IDEmpleado = e.IDEmpleado
		join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto
	where p.IDPeriodo = @IDPeriodo and c.Estatus = 1-- and p.Cerrado = 0
	ORDER BY e.IDEmpleado, C.OrdenCalculo

end
GO
