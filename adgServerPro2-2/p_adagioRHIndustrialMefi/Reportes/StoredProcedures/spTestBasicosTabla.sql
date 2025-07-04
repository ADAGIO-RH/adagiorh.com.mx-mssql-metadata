USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spTestBasicosTabla](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as

declare @empleados [RH].[dtEmpleados]    
	,@IDPeriodoSeleccionado int=0    
	,@periodo [Nomina].[dtPeriodos]    
	,@configs [Nomina].[dtConfiguracionNomina]    
	,@Conceptos [Nomina].[dtConceptos]    
	 
	,@fechaIniPeriodo  date    
	,@fechaFinPeriodo  date    
	;

  /* Se buscan todos los empleados vigentes del tipo de nómina seleccionado */    
    insert into @empleados    
    exec [RH].[spBuscarEmpleados] @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario 

	select 
		ClaveEmpleado
		, NOMBRECOMPLETO
		, Departamento
		, Sucursal
		, Puesto
		, SalarioDiario
		, SalarioIntegrado
	from @empleados
GO
