USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar el acumulado de Fondo de ahorro de un colaborador
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-04-30
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?

exec [Nomina].[spBuscarAcumuladoFondoAhorro] 2,1279,1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAcumuladoFondoAhorro](
		@IDFondoAhorro	int	--= 2
		,@dtEmpleados	RH.dtEmpleados readonly
) as

	--declare
	--	@IDFondoAhorro	int	= 4
	--	,@dtEmpleados	RH.dtEmpleados 
	--	,@IDUsuario		int = 1
	--;

	--select * from Nomina.tblCatFondosAhorro

	--161	FONDO DE AHORRO EMPRESA				|	PERCEPCION

	--162	DEV. FONDO DE AHORRO EMPRESA		|	PERCEPCION
	--163	DEV. FONDO AHORRO TRABAJADOR		|	PERCEPCION
	--164	INTERESES FONDO DE AHORRO			|	PERCEPCION
	--165	RETIRO FONDO DE AHORRO EMPRESA		|	PERCEPCION
	--166	RETIRO FONDO DE AHORRO TRABAJADOR	|	PERCEPCION
	--167	PRESTAMO FONDO DE AHORRO			|	PERCEPCION

	--308	FONDO DE AHORRO EMPRESA				|	DEDUCCION
	--309	FONDO DE AHORRO TRABAJADOR			|	DEDUCCION
	--310	PRÉSTAMO DE FONDO DE AHORRO			|	DEDUCCION

	declare  
		@IDPeriodoInicial	   int
		,@IDPeriodoFinal	   int 
        ,@IDTipoNomina int

		,@ConceptoAportacionEmpresa		varchar(10) = '308'
		,@ConceptoAportacionTrabajador	varchar(10) = '309'

		,@ConceptoDevolucionEmpresa		varchar(10) = '162'
		,@ConceptoDevolucionTrabajador  varchar(10) = '163'

		,@ConceptoRetirosEmpresa		varchar(10) = '165'
		,@ConceptoRetirosTrabajador		varchar(10) = '166'

		,@ConceptoPrestamoFondoAhorro	varchar(10) = '310' -- PRÉSTAMO DE FONDO DE AHORRO

		,@FechaIni date --= '2019-01-01'
		,@FechaFin date --= '2019-12-31'

		,@TotalAportacionesEmpresa		decimal(18,2)
		,@TotalAportacionesTrabajador	decimal(18,2)
		
		,@TotalDevolucionesEmpresa		decimal(18,2)
		,@TotalDevolucionesTrabajador	decimal(18,2)

		,@TotalRetirosEmpresa			decimal(18,2)
		,@TotalRetirosTrabajador		decimal(18,2)
		
		,@TotalAcumulado				decimal(18,2)
		,@TotalPrestamosFondoAhorro		decimal(18,2)
		,@TotalSaldoPendienteADescontar	decimal(18,2)
	;

	
	DECLARE @tempResp TABLE(    
		IDEmpleado					decimal(18,2),
		TotalAportaciones			decimal(18,2), 
		TotalDevoluciones			decimal(18,2),
		TotalRetiros				decimal(18,2),    
		TotalPrestamosFondoAhorro	decimal(18,2),
		TotalADevolver				as TotalAportaciones -(TotalDevoluciones+TotalRetiros+TotalPrestamosFondoAhorro)
	);

	if object_id('tempdb..#tempPrestamos') is not null drop table #tempPrestamos;

	select @IDPeriodoInicial = IDPeriodoInicial
		  ,@IDPeriodoFinal = IDPeriodoFinal
          ,@IDTipoNomina = IDTipoNomina
	from Nomina.tblCatFondosAhorro with (nolock)
	where IDFondoAhorro = @IDFondoAhorro

	select @FechaIni=FechaInicioPago	from [Nomina].[tblCatPeriodos] with (nolock) where IDPeriodo = @IDPeriodoInicial
	select @FechaFin=FechaFinPago		from [Nomina].[tblCatPeriodos] with (nolock) where IDPeriodo = @IDPeriodoFinal
	
	set @FechaFin = isnull(@FechaFin,'9999-12-31')

	--insert @dtEmpleados
	--exec RH.spBuscarEmpleados @IDTipoNomina = 4,@FechaIni=@FechaIni,@FechaFin=@FechaFin,@IDUsuario=@IDUsuario

	--IF object_ID('TEMPDB..#TempSaldosPendientesADescontar') IS NOT NULL DROP TABLE #TempSaldosPendientesADescontar
	IF object_ID('TEMPDB..#TempTotalDeApartaciones') IS NOT NULL		DROP TABLE #TempTotalDeApartaciones
	IF object_ID('TEMPDB..#TempTotalDeDevoluciones') IS NOT NULL		DROP TABLE #TempTotalDeDevoluciones
	IF object_ID('TEMPDB..#TempTotalDeRetiros') IS NOT NULL				DROP TABLE #TempTotalDeRetiros
	IF object_ID('TEMPDB..#TempTotalPrestamosFondoAhorro') IS NOT NULL	DROP TABLE #TempTotalPrestamosFondoAhorro

	---- TOTAL DE SALDO PENDIENTE A DESCONTAR en RETIROS
	--select 
	--	 rfa.IDEmpleado
	--	 ,rfa.MontoEmpresa + rfa.MontoTrabajador as TotalSaldoPendienteADescontar
	--INTO #TempSaldosPendientesADescontar
	--from Nomina.tblRetirosFondoAhorro rfa with (nolock)
	--	Inner join @dtEmpleados e on rfa.IDEmpleado = e.IDEmpleado
	--	Inner join Nomina.tblCatPeriodos P with (nolock) on rfa.IDPeriodo = P.IDPeriodo AND P.Cerrado = 0  
	--where rfa.IDFondoAhorro = @IDFondoAhorro
 
	-- TOTAL DE APORTACIONES EMPRESA Y COLABORADOR
	Select DP.IDEmpleado as IDEmpleado,  
		ISNULL(SUM(DP.ImporteGravado),0) as  ImporteGravado,  
		ISNULL(SUM(DP.ImporteExcento),0) as  ImporteExcento,  
		ISNULL(SUM(DP.ImporteTotal1),0) as  ImporteTotal1,  
		ISNULL(SUM(DP.ImporteTotal2),0) as  ImporteTotal2  
	INTO #TempTotalDeApartaciones
	from Nomina.tblDetallePeriodo DP with (nolock)  
		Inner join @dtEmpleados e on DP.IDEmpleado = e.IDEmpleado
		Inner join Nomina.tblCatPeriodos P with (nolock) on DP.IDPeriodo = P.IDPeriodo AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in (select item from app.Split(@ConceptoAportacionEmpresa+','+@ConceptoAportacionTrabajador,','))  
		and p.FechaFinPago between @FechaIni and @FechaFin  
        and p.IDTipoNomina=@IDTipoNomina
	group by DP.IDEmpleado

	-- TOTAL DEVOLUCIONES EMPRESA Y COLABORADOR
	Select DP.IDEmpleado as IDEmpleado,  
		ISNULL(SUM(DP.ImporteGravado),0) as  ImporteGravado,  
		ISNULL(SUM(DP.ImporteExcento),0) as  ImporteExcento,  
		ISNULL(SUM(DP.ImporteTotal1),0) as  ImporteTotal1,  
		ISNULL(SUM(DP.ImporteTotal2),0) as  ImporteTotal2  
	INTO #TempTotalDeDevoluciones
	from Nomina.tblDetallePeriodo DP with (nolock)  
		Inner join @dtEmpleados e on DP.IDEmpleado = e.IDEmpleado
		Inner join Nomina.tblCatPeriodos P with (nolock) on DP.IDPeriodo = P.IDPeriodo AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in (select item from app.Split(@ConceptoDevolucionEmpresa+','+@ConceptoDevolucionTrabajador,','))  
		and p.FechaFinPago between @FechaIni and @FechaFin  
        and p.IDTipoNomina=@IDTipoNomina
	group by DP.IDEmpleado

	-- TOTAL RETIROS EMPRESA Y COLABORADOR
	Select DP.IDEmpleado as IDEmpleado,  
		ISNULL(SUM(DP.ImporteGravado),0) as  ImporteGravado,  
		ISNULL(SUM(DP.ImporteExcento),0) as  ImporteExcento,  
		ISNULL(SUM(DP.ImporteTotal1),0) as  ImporteTotal1,  
		ISNULL(SUM(DP.ImporteTotal2),0) as  ImporteTotal2  
	INTO #TempTotalDeRetiros
	from Nomina.tblDetallePeriodo DP with (nolock)  
		Inner join @dtEmpleados e on DP.IDEmpleado = e.IDEmpleado
		Inner join Nomina.tblCatPeriodos P with (nolock) on DP.IDPeriodo = P.IDPeriodo AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c with (nolock) on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in (select item from app.Split(@ConceptoRetirosEmpresa+','+@ConceptoRetirosTrabajador,','))  
		and p.FechaFinPago between @FechaIni and @FechaFin  
        and p.IDTipoNomina=@IDTipoNomina
	group by DP.IDEmpleado

	select IDEmpleado,sum(Balance) as TotalPrestamosFondoAhorro
	INTO #TempTotalPrestamosFondoAhorro
	from (
		select     
			p.IDEmpleado
			,P.MontoPrestamo - isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance   
		from [Nomina].[tblPrestamos] p    
		inner join [Nomina].[tblCatTiposPrestamo] TP with (nolock) on p.IDTipoPrestamo = TP.IDTipoPrestamo
		inner join [Nomina].[tblPrestamosFondoAhorro] pfa with (nolock) on p.IDPrestamo = pfa.IDPrestamo
		inner join [Nomina].[tblCatEstatusPrestamo] EP  with (nolock) on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
		inner join @dtEmpleados e on P.IDEmpleado = e.IDEmpleado    
		where (pfa.IDFondoAhorro = @IDFondoAhorro)  
			and TP.Codigo = 'PF'
			and p.IDEstatusPrestamo in (2,1,3)
		--order by p.FechaCreacion desc  
	) prestamos
	group by IDEmpleado

	insert @tempResp
	select 
		e.IDEmpleado
		,isnull(totalAportaciones.ImporteTotal1,0)					as TotalAportaciones
		,isnull(totalDevoluciones.ImporteTotal1,0)					as TotalDevoluciones
		,isnull(totalRetiros.ImporteTotal1,0)						as TotalRetiros
		,isnull(totalPrestamos.TotalPrestamosFondoAhorro,0)			as TotalPrestamosFondoAhorro
	from @dtEmpleados e
		left join #TempTotalDeApartaciones		  totalAportaciones on e.IDEmpleado = totalAportaciones.IDEmpleado
		left join #TempTotalDeDevoluciones		  totalDevoluciones on e.IDEmpleado = totalDevoluciones.IDEmpleado
		left join #TempTotalDeRetiros			  totalRetiros		on e.IDEmpleado = totalRetiros.IDEmpleado
		left join #TempTotalPrestamosFondoAhorro  totalPrestamos	on e.IDEmpleado = totalPrestamos.IDEmpleado 
	order by e.IDEmpleado

	select * from @tempResp
	
	--return
	--select  isnull(@TotalAportacionesEmpresa	 ,0) 	as TotalAportacionesEmpresa		
	--	   ,isnull(@TotalAportacionesTrabajador	 ,0)	as TotalAportacionesTrabajador	
	--	   ,isnull(@TotalDevolucionesEmpresa	 ,0)	as TotalDevolucionesEmpresa	
	--	   ,isnull(@TotalDevolucionesTrabajador	 ,0)	as TotalDevolucionesTrabajador	
	--	   ,isnull(@TotalRetirosEmpresa			 ,0)	as TotalRetirosEmpresa			
	--	   ,isnull(@TotalRetirosTrabajador		 ,0) 	as TotalRetirosTrabajador		
	--	   ,isnull(@TotalAcumulado				 ,0) 	as TotalAcumulado				
	--	   ,isnull(@TotalPrestamosFondoAhorro	 ,0) 	as TotalPrestamosFondoAhorro		
	--	   ,isnull(@TotalSaldoPendienteADescontar,0) 	as TotalSaldoPendienteADescontar		

	--select * from Nomina.tblCatFondosAhorro	
	--select * from Nomina.tblPrestamosFondoAhorro

	--exec nomina.spBuscarCatConceptos

	--alter table Nomina.tblPrestamosFondoAhorro
	--	alter column Monto decimal(18,2) not null

	--exec utilerias.spBuscarSQLObjectsFilter @filter = 'IDEstatusPrestamo = 4'
GO
