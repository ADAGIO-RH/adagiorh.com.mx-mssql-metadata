USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec Nomina.spBuscarCatConceptos

CREATE proc [Reportes].[spConceptosPorPeriodo](
	@IDPeriodo int
	,@ListaConceptos varchar(max)
) as
	
	select e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,c.Codigo
		,c.Descripcion as Concepto
		,dp.CantidadMonto
		,dp.CantidadDias
		,dp.CantidadVeces
		,dp.CantidadOtro1
		,dp.CantidadOtro2
		,dp.ImporteGravado
		,dp.ImporteExcento
		,dp.ImporteOtro
		,dp.ImporteTotal1
		,dp.ImporteTotal2
	from [Nomina].[tblDetallePeriodo] dp with (nolock)
		join [RH].[tblEmpleadosMaster] e on dp.IDEmpleado = e.IDEmpleado
		join [Nomina].[tblCatConceptos] c on dp.IDConcepto = c.IDConcepto
	where dp.IDConcepto in (select cast(item as int) from app.Split(@ListaConceptos,','))
		and dp.IDPeriodo = @IDPeriodo
		and (dp.CantidadMonto
			+dp.CantidadDias
			+dp.CantidadVeces
			+dp.CantidadOtro1
			+dp.CantidadOtro2
			+dp.ImporteGravado
			+dp.ImporteExcento
			+dp.ImporteOtro
			+dp.ImporteTotal1
			+dp.ImporteTotal2) > 0
GO
