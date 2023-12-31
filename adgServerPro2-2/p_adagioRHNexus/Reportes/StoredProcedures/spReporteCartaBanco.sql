USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spReporteCartaBanco]   
(      
  @IDPeriodoInicial Varchar(max),  
  @IDUsuario int        
)      
AS      
BEGIN      
	select SUM(importeTotal1) as TOTAL,
			p.FechaFinPago as FechaFin,
			FORMAT(SUM(ImporteTotal1) ,'C','En-Us')+' ('+[Utilerias].[fnConvertNumerosALetras](cast( ISNULL(SUM(ImporteTotal1) ,0.00) as varchar(max)))+')' TotalLetras
	from Nomina.tblDetallePeriodo dp WITH(NOLOCK)
		inner join rh.tblPagoEmpleado PE WITH(NOLOCK)
			on PE.IDEmpleado = dp.IDEmpleado and PE.IDBanco = 1009 --Banco Popular
		inner join Nomina.tblCatConceptos c WITH(NOLOCK)
			on c.IDConcepto = dp.IDConcepto
		inner join Nomina.tblCatPeriodos p WITH(NOLOCK)
			on p.IDPeriodo = dp.IDPeriodo
	where dp.IDPeriodo = @IDPeriodoInicial and c.Codigo = 'RD601' --CONCEPTO DE NET PAY DE RD
	group by p.FechaFinPago
END
GO
