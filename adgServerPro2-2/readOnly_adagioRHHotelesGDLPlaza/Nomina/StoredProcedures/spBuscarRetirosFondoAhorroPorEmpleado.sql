USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

/**************************************************************************************************** 
** Descripción		: Buscar el detalle de retiros por Tipo (Empleado o Trabajador)
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-08-30
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?

[Nomina].[spBuscarRetirosFondoAhorroPorEmpleado]
		@IDFondoAhorro	= 4
		,@IDEmpleado	= 1279
		,@IDUsuario		= 1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarRetirosFondoAhorroPorEmpleado](
		@IDFondoAhorro	int	--= 2
		,@IDEmpleado	int	--= 1279
		,@IDUsuario		int
) as
	--declare @IDFondoAhorro	int = 4
	--		,@IDEmpleado	int = 1279
	--		,@IDUsuario		int = 1
	declare  
			@IDPeriodoInicial	   int
			,@IDPeriodoFinal	   int 
			,@CodigoConceptoRetiroFondoAhorroEmpresa varchar(100) = '165' -- RETIRO FONDO DE AHORRO EMPRESA
			,@CodigoConceptoRetiroFondoAhorroTrabajador varchar(100) = '166' -- RETIRO FONDO DE AHORRO TRABAJADOR
			,@FechaIni date --= '2019-01-01'
			,@FechaFin date --= '2019-12-31'
	;

	--if object_id('tempdb..#tempListaRetiros') is not null drop table #tempListaRetiros
	declare @tempListaRetiros table(
		ID int
		,IDEmpleado  	 int
		,IDConcepto  	 int
		,Codigo			 varchar(20)
		,Fecha			 date
		,Periodo		 varchar(20)
		,Importe		 decimal(18,2)
		,Descripcion	 varchar(250)
		,Estatus varchar(20)
		,Pagado bit
	);
	
	select @IDPeriodoInicial = IDPeriodoInicial
		  ,@IDPeriodoFinal = IDPeriodoFinal
	from Nomina.tblCatFondosAhorro with (nolock)
	where IDFondoAhorro = @IDFondoAhorro

	select @FechaIni= FechaInicioPago	from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoInicial
	select @FechaFin= FechaFinPago		from [Nomina].[tblCatPeriodos] where IDPeriodo = @IDPeriodoFinal

	INSERT @tempListaRetiros
	Select	dp.IDDetallePeriodo as ID
			,IDEmpleado  
			,DP.IDConcepto  
			,c.Codigo
			, p.FechaFinPago as Fecha
			, p.ClavePeriodo as Periodo
			,ISNULL(DP.ImporteTotal1,0) as Importe
			,c.Descripcion
			,'Aplicado' as Estatus
			,cast(1 as bit) as Pagado
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
	where c.Codigo in ('165','166')
		and p.FechaFinPago between @FechaIni and isnull(@FechaFin,'9999-12-31')   
	--order by p.FechaInicioPago asc
	UNION
	select 
		 rfa.IDRetiroFondoAhorro as ID
		,rfa.IDEmpleado
		,c.IDConcepto  
		,c.Codigo
		, p.FechaFinPago as Fecha
		, p.ClavePeriodo as Periodo
		,ISNULL(rfa.MontoEmpresa,0) as Importe
		,c.Descripcion
		,'Pendiente' as Estatus
		,cast(0 as bit) as Pagado
	from Nomina.tblRetirosFondoAhorro rfa
		Inner join Nomina.tblCatPeriodos P on rfa.IDPeriodo = P.IDPeriodo AND rfa.IDEmpleado = @IDEmpleado AND P.Cerrado = 0  
		,Nomina.tblCatConceptos c 
	where c.Codigo = @CodigoConceptoRetiroFondoAhorroEmpresa and rfa.IDEmpleado = @IDEmpleado
	--order by p.FechaInicioPago asc
	UNION
	select 
		 rfa.IDRetiroFondoAhorro as ID
		,rfa.IDEmpleado
		,c.IDConcepto  
		,c.Codigo
		, p.FechaFinPago as Fecha
		, p.ClavePeriodo as Periodo
		,ISNULL(rfa.MontoEmpresa,0) as Importe
		,c.Descripcion
		,'Pendiente' as Estatus
		,cast(0 as bit) as Pagado
	from Nomina.tblRetirosFondoAhorro rfa
		Inner join Nomina.tblCatPeriodos P on rfa.IDPeriodo = P.IDPeriodo AND rfa.IDEmpleado = @IDEmpleado AND P.Cerrado = 0 
		,Nomina.tblCatConceptos c 
	where c.Codigo = @CodigoConceptoRetiroFondoAhorroTrabajador and rfa.IDEmpleado = @IDEmpleado
	--order by p.FechaInicioPago asc

	select * from @tempListaRetiros
 -- exec nomina.spBuscarCatConceptos
GO
