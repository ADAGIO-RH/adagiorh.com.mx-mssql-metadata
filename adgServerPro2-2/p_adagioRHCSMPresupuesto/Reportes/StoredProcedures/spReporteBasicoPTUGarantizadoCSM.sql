USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteBasicoPTUGarantizadoCSM](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as

	--declare	
	--	@dtFiltros Nomina.dtFiltrosRH
	--	,@IDUsuario int = 1
	--insert @dtFiltros
	--values ('IDPTU',3)
		  

	declare 
		@empleados [RH].[dtEmpleados]      
		,@empleadosTemp [RH].[dtEmpleados]        
		,@IDPeriodoSeleccionado int=0      
		,@periodo [Nomina].[dtPeriodos]      
		,@configs [Nomina].[dtConfiguracionNomina]      
		,@Conceptos [Nomina].[dtConceptos]      
		,@IDTipoNomina int   
		,@fechaIniPeriodo  date      
		,@fechaFinPeriodo  date     
		,@IDPeriodoInicial int
		,@IDCliente int
		,@Cerrado bit = 1
		,@IDConcepto540 int
		,@IDPTU int
		,@DiasAnio int
	;  

	set @IDPTU = case when exists (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPTU'),',')) 
								THEN (Select top 1 cast(item as int) 
										from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDPTU'),','))
						else 0 END


	select @DiasAnio = datediff(day,Cast(Cast(Ejercicio as Varchar(4)) +'-01-01' as date),Cast(Cast(Ejercicio as Varchar(4)) +'-12-31' as date))+1
	from Nomina.tblPTU with(nolock)
	where IDPTU = @IDPTU


	select 
		m.ClaveEmpleado as CLAVE,
		M.NOMBRECOMPLETO as NOMBRE,
		M.TipoNomina as TIPO_NOMINA,
		ptue.TotalPTU AS TOTAL_PTU,
		ptue.DiasTrabajados as DIAS_TRABAJADOS,
		(CAST(isnull(DEE.Valor,0) as int) * isnull(m.SalarioDiario,0))  as PTU_GARANTIZADO,
		CAST(isnull(DEE.Valor,0) as int) DIAS_GARANTIZADOS,
		cast(((CAST(isnull(DEE.Valor,0) as decimal(18,2)) / @DiasAnio ) * ptue.DiasTrabajados) as decimal(18,2)) as FACTOR,
		CAST((((CAST(isnull(DEE.Valor,0) as decimal(18,2)) / @DiasAnio ) * ptue.DiasTrabajados) * M.SalarioDiario)- ptue.TotalPTU as DECIMAL(18,2)) as TOTAL_GRATIFICACION
	from Nomina.tblPTU ptu
		inner join Nomina.tblPTUEmpleados ptue
			on ptu.IDPTU = ptue.IDPTU
		inner join RH.tblEmpleadosMaster m
			on ptue.IDEmpleado = m.IDEmpleado
		inner join RH.tblCatDatosExtra CDE
			on CDE.IDDatoExtra = 3
		inner join RH.tblDatosExtraEmpleados DEE
			on DEE.IDEmpleado = m.IDEmpleado
			and DEE.IDDatoExtra = CDE.IDDatoExtra
			and CAST(isnull(DEE.Valor,0) as int	) > 0
	where ptu.IDPTU = @IDPTU
		and isnull(m.Vigente,0) = 1
	order by m.ClaveEmpleado asc




		


	

GO
