USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DECLARE @dtFiltros [Nomina].[dtFiltrosRH]
	insert into @dtFiltros(Catalogo,Value)
	Values('IDPTU',5)

EXEC [Reportes].[spReporteBasicoBuscarPTUEmpleados]@dtFiltros,1
*/


CREATE   proc [Reportes].[spReporteBasicoBuscarPTUEmpleados](
    @dtFiltros [Nomina].[dtFiltrosRH] readonly,
    @IDUsuario INT
) 
AS
begin
	declare @IDPTU int;
	select @IDPTU = (SELECT TOP 1 TRY_CAST([Value] as int) FROM @dtFiltros WHERE Catalogo = 'IDPTU')
	declare @tempPTU as table (
		IDPTU int
		,IDEmpresa int
		,NombreComercial varchar(max)
		,RFC varchar(max)
		,Ejercicio int
		,ConceptosIntegranSueldo varchar(max)
		,DiasMinimosTrabajados int
		,DiasDescontar varchar(max)
		,DescontarIncapacidades bit
		,TiposIncapacidadesADescontar varchar(max)
		,CantidadGanancia decimal(18, 2)
		,CantidadRepartir decimal(18, 2)
		,CantidadPendiente decimal(18, 2)
		,EjercicioPago int 
		,IDPeriodo int
		,Periodo varchar(max)
		,MontoSueldo decimal(18, 2)
		,MontoDias decimal(18, 2)
		,FactorSueldo decimal(18, 2)
		,FactorDias decimal(18, 2)
		,IDEmpleadoTipoSalarioMensualConfianza int
		,ColaboradorTopeMaximoConfianza varchar(max)
		,TopeSalarioMensualConfianza decimal(18, 2)
		,TopeConfianza decimal(18, 2)
		,AplicarReforma bit
		,AplicarPtuFinanciero bit
		,ROWNUMBER int
		,TotalPaginas int
		,TotalRegistros int
	)

	insert into @tempPTU
	exec [Nomina].[spBuscarPTU]@IDPTU = @IDPTU

	--select 
	--	(CantidadRepartir + CantidadPendiente) as MontoARepartir
	--	,MontoSueldo
	--	,MontoDias
	--	,FactorSueldo
	--	,FactorDias
	--	,TopeConfianza
	--from @tempPTU

	select
		(tptu.CantidadRepartir + tptu.CantidadPendiente) as [Monto A Repartir]
		,tptu.MontoSueldo as [Monto Sueldo]
		,tptu.MontoDias as [Monto Dias]
		,tptu.FactorSueldo as [Factor Sueldo]
		,tptu.FactorDias as [Factor Dias]
		,tptu.TopeConfianza as [Tope Confianza]
	    ,e.Cliente
		,e.TipoNomina as [Tipo Nómina]
		,e.ClaveEmpleado as [Clave]
		,e.NOMBRECOMPLETO as Colaborador
		,ptu.SalarioDiario as [Salario]
		,ptu.FechaInicio as [Fecha Inicio]
		,ptu.FechaFin as [Fecha Fin]
		,ptu.Sindical
		,ptu.SalarioAcumuladoReal as [Acumulado]
		,ptu.SalarioAcumuladoTopado as [Acumulado Topado]
		,ptu.DiasVigencia as [Dias De Vigencia]
		,isnull(ptu.DiasADescontar, 0) as [Dias A Descontar]
		,isnull(ptu.Incapacidades, 0) as [Incapacidades]
		,ptu.DiasTrabajados as [Dias Trabajados]
		,ptu.PTUPorSalario as [PTU Por Salario]
		,ptu.PTUPorDias as [PTU Por Dias]
		,isnull(ptu.TotalPTU, 0) as [Total PTU]
		,isnull(ptu.PromedioSueldo3Meses, 0) as [Promedio Sueldo 3 Meses]
		,isnull(ptu.PromedioPTU3Anios, 0) as [Promedio De PTU 3 Años]
		,isnull(ptu.PTUFinanciero, 0) as [PTU Financiero]
		,isnull(ptu.PTURecomendado, 0) as [PTU Recomendado Del Ejercicio]
		,CASE WHEN isnull(e.Vigente,0) = 0 THEN 'NO' ELSE 'SI' END as Vigente
	from Nomina.tblPTUEmpleados ptu with (nolock)
		join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = ptu.IDEmpleado
		join @tempPTU tptu on ptu.IDPTU = tptu.IDPTU
	where ptu.IDPTU = @IDPTU
	order by e.ClaveEmpleado asc
end
GO
