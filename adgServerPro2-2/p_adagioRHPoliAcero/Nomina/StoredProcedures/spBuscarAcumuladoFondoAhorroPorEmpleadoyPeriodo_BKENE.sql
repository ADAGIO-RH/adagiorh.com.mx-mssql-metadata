USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar el acumulado de Fondo de ahorro de un colaborador
** Autor			: Yesenia Leonel
** Email			: 
** FechaCreacion	: 2022-05-09
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2022-05-09			Yesenia Leonel	se copio el sp [Nomina].[spBuscarAcumuladoFondoAhorroPorEmpleado] pasando el ID Periodo
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAcumuladoFondoAhorroPorEmpleadoyPeriodo_BKENE](
	@IDFondoAhorro			int	--= 2
	,@IDEmpleado			int	--= 1279
	,@IDPeriodo int
	,@IDUsuario int
) as
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

		,@ConceptoAportacionEmpresa		varchar(10) = '308'
		,@ConceptoAportacionTrabajador	varchar(10) = '309'

		,@ConceptoDevolucionEmpresa		varchar(10) = '162'
		,@ConceptoDevolucionTrabajador	varchar(10) = '163'

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

		,@IDPrestamo int = 0
		,@IDTipoNomina int
		,@IdsPeriodos varchar(max)
	;

	DECLARE @tempPrestamos TABLE(    
		IDPrestamo int,    
		IDPrestamoDetalle int,         
		IDConcepto int,    
		Concepto Varchar(50),    
		IDPeriodo int,    
		ClavePeriodo varchar(25),    
		MontoCuota Decimal(18,4),    
		FechaPago date,
		Receptor Varchar(255),
		IDUsuario int,
		Usuario Varchar(255)    
	);

	if object_id('tempdb..#tempPrestamos') is not null drop table #tempPrestamos;

	select @IDPeriodoInicial = IDPeriodoInicial
		  ,@IDPeriodoFinal = IDPeriodoFinal
		  ,@IDTipoNomina = IDTipoNomina
	from Nomina.tblCatFondosAhorro with (nolock)
	where IDFondoAhorro = @IDFondoAhorro

	select @FechaIni=FechaInicioPago	from [Nomina].[tblCatPeriodos] with (nolock) where IDPeriodo = @IDPeriodoInicial
	select @FechaFin=FechaFinPago		from [Nomina].[tblCatPeriodos] with (nolock) where IDPeriodo = @IDPeriodo
	
	select @IdsPeriodos = STUFF(( 
		select ','+ cast(isnull(p.IDPeriodo,0) as varchar)
		from Nomina.tblCatPeriodos p
		where p.IDTipoNomina = @IDTipoNomina and p.FechaFinPago between @FechaIni and @FechaFin
		and p.IDPeriodo not in (select isnull(IDPeriodoPago, 0) from Nomina.tblCatFondosAhorro)
	for XML path('')
	),1,1, '')
	
	select 
		 @TotalSaldoPendienteADescontar = isnull(rfa.MontoEmpresa,0) + isnull(rfa.MontoTrabajador,0)
	from Nomina.tblRetirosFondoAhorro rfa with (nolock)
		Inner join Nomina.tblCatPeriodos P with (nolock) on rfa.IDPeriodo = P.IDPeriodo AND rfa.IDEmpleado = @IDEmpleado AND P.Cerrado = 0  
	where rfa.IDFondoAhorro = @IDFondoAhorro and rfa.IDEmpleado = @IDEmpleado

	select @TotalAportacionesEmpresa=isnull(sum(ImporteTotal1),0)
	from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos] (@IDEmpleado,
								@ConceptoAportacionEmpresa,
								@IdsPeriodos
								)
	
	select @TotalAportacionesTrabajador=isnull(sum(ImporteTotal1),0)
	from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos] (@IDEmpleado,
								@ConceptoAportacionTrabajador,
								@IdsPeriodos)
	
	select @TotalDevolucionesEmpresa=isnull(sum(ImporteTotal1),0)
	from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos] (@IDEmpleado,
								@ConceptoDevolucionEmpresa,
								@IdsPeriodos)
	
	select @TotalDevolucionesTrabajador=isnull(sum(ImporteTotal1),0)
	from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos] (@IDEmpleado,
								@ConceptoDevolucionEmpresa,
								@IdsPeriodos)

	select @TotalRetirosEmpresa=isnull(sum(ImporteTotal1),0)
	from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos] (@IDEmpleado,
								@ConceptoRetirosEmpresa,
								@IdsPeriodos)

	select @TotalRetirosTrabajador=isnull(sum(ImporteTotal1),0)
	from [Nomina].[fnObtenerAcumuladoRangoListaPeriodos] (@IDEmpleado,
								@ConceptoRetirosTrabajador,
								@IdsPeriodos)

	if exists (select top 1 1
				from Nomina.tblPrestamosFondoAhorro pfa with (nolock)
				where IDFondoAhorro = @IDFondoAhorro and IDEmpleado = @IDEmpleado)
	begin
		select @TotalPrestamosFondoAhorro = sum(Balance)
		from (
			select     
				P.MontoPrestamo - isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance   
			from [Nomina].[tblPrestamos] p    
				inner join [Nomina].[tblCatTiposPrestamo] TP		with (nolock) on p.IDTipoPrestamo = TP.IDTipoPrestamo
				inner join [Nomina].[tblPrestamosFondoAhorro] pfa	with (nolock) on p.IDPrestamo = pfa.IDPrestamo --and pfa.IDEmpleado = @IDEmpleado   
				inner join [Nomina].[tblCatEstatusPrestamo] EP		with (nolock) on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
				inner join [RH].[tblEmpleados] e					with (nolock) on P.IDEmpleado = e.IDEmpleado    
				inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario   
			where (pfa.IDFondoAhorro = @IDFondoAhorro)  
				and  (e.IDEmpleado = @IDEmpleado)
				and TP.IDTipoPrestamo = 6
				and p.IDEstatusPrestamo in (2,1,3)
			--order by p.FechaCreacion desc  
		) prestamos

	end else set @TotalPrestamosFondoAhorro = 0;

	set @TotalAcumulado = @TotalAportacionesEmpresa + @TotalAportacionesTrabajador

	select  isnull(@TotalAportacionesEmpresa	 ,0) 	as TotalAportacionesEmpresa		
		   ,isnull(@TotalAportacionesTrabajador	 ,0)	as TotalAportacionesTrabajador	
		   ,isnull(@TotalDevolucionesEmpresa	 ,0)	as TotalDevolucionesEmpresa	
		   ,isnull(@TotalDevolucionesTrabajador	 ,0)	as TotalDevolucionesTrabajador	
		   ,isnull(@TotalRetirosEmpresa			 ,0)	as TotalRetirosEmpresa			
		   ,isnull(@TotalRetirosTrabajador		 ,0) 	as TotalRetirosTrabajador		
		   ,isnull(@TotalAcumulado				 ,0) 	as TotalAcumulado				
		   ,isnull(@TotalPrestamosFondoAhorro	 ,0) 	as TotalPrestamosFondoAhorro		
		   ,isnull(@TotalSaldoPendienteADescontar,0) 	as TotalSaldoPendienteADescontar	
		   ,NetoDisponible = isnull(@TotalAcumulado, 0) - (isnull(@TotalRetirosEmpresa, 0) + isnull(@TotalRetirosTrabajador, 0) + isnull(@TotalDevolucionesEmpresa, 0) + isnull(@TotalDevolucionesTrabajador, 0) + isnull(@TotalSaldoPendienteADescontar, 0))
GO
