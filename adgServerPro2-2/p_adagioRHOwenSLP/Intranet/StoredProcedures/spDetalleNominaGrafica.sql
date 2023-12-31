USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [Intranet].[spDetalleNominaGrafica] --1279,2022
		@IDEmpleado int
		,@Ejercicio int
as BEGIN

with  TOTALPERCEPCIONES as (
Select 
	M.IDMes as [Order]
	,P.Descripcion as PeriodoNomina
	,DP.ImporteTotal1 as  TotalPercepciones
	,P.ClavePeriodo
	,DP.IDEmpleado
	
from Nomina.tblCatMeses m with (nolock)
	left join Nomina.tblCatPeriodos P with (nolock)
		on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1  
	left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
	and DP.IDEmpleado = @IDEmpleado 
	join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo = '550' 		 	 

	), TOTALPAGADO as
			(
			Select 
	M.IDMes as [Order]
	,P.Descripcion as PeriodoNomina
	, DP.ImporteTotal1 as  TotalPagado
	,P.ClavePeriodo
	,DP.IDEmpleado
from Nomina.tblCatMeses m with (nolock)
	left join Nomina.tblCatPeriodos P with (nolock)
		on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1  
	left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
	and DP.IDEmpleado = @IDEmpleado
	join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.IDTipoConcepto = 5
	), TOTALDEDUCCIONES as
			(
			Select 
	M.IDMes as [Order]
	,P.Descripcion as PeriodoNomina
	, DP.ImporteTotal1 as  TotalDeducciones
	,P.ClavePeriodo
	,DP.IDEmpleado
from Nomina.tblCatMeses m with (nolock)
	left join Nomina.tblCatPeriodos P with (nolock)
		on m.IDMes = p.IDMes AND P.Ejercicio = @Ejercicio and P.Cerrado = 1  
	left join Nomina.tblDetallePeriodo DP with (nolock)	on DP.IDPeriodo = P.IDPeriodo 
	and DP.IDEmpleado = @IDEmpleado
	join Nomina.tblCatConceptos c on c.IDConcepto = DP.IDConcepto and c.Codigo = '560' 	
			)	
			select         
							
				isnull(SUM(TP.TotalPercepciones),0) as TotalPercepciones, 
				isnull(SUM(TPA.TotalPagado),0) as TotalPagado,
				isnull(SUM(TD.TotalDeducciones),0) as TotalDeducciones	
			from TOTALPERCEPCIONES TP
				left join TOTALPAGADO TPA on TPA.ClavePeriodo = TP.ClavePeriodo
				left join TOTALDEDUCCIONES TD on TD.ClavePeriodo = TP.ClavePeriodo
		
	

END
GO
