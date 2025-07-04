USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Nomina].[spBuscarPTUEmpleados](
	@IDPTU int
) as
select
	ptu.IDPTUEmpleado
	,ptu.IDPTU
	,ptu.IDEmpleado
	,e.ClaveEmpleado
	,e.NOMBRECOMPLETO as Colaborador
	,e.Cliente
	,e.TipoNomina
	,ptu.SalarioDiario
	,ptu.FechaInicio
	,ptu.FechaFin
	,ptu.Sindical
	,ptu.SalarioAcumuladoReal
	,ptu.SalarioAcumuladoTopado
	,ptu.DiasVigencia
	,isnull(ptu.DiasADescontar, 0) as DiasADescontar
	,isnull(ptu.Incapacidades, 0) as Incapacidades
	,ptu.DiasTrabajados
	,ptu.PTUPorSalario
	,ptu.PTUPorDias
	,isnull(ptu.TotalPTU, 0) as TotalPTU
	,isnull(ptu.PromedioSueldo3Meses, 0) as PromedioSueldo3Meses
	,isnull(ptu.PromedioPTU3Anios, 0) as PromedioPTU3Anios
	,isnull(ptu.PTURecomendado, 0) as PTURecomendado
	,isnull(ptu.Ptufinanciero, 0) as PTUFinanciero
	,CASE WHEN isnull(e.Vigente,0) = 0 THEN 'NO' ELSE 'SI' END as Vigente
from Nomina.tblPTUEmpleados ptu with (nolock)
	join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = ptu.IDEmpleado
where ptu.IDPTU = @IDPTU
order by e.ClaveEmpleado asc


GO
